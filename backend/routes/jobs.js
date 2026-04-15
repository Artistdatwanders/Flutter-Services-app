const express = require('express');
const auth = require('../middleware/auth');
const Job = require('../models/Job');
const User = require('../models/User');

const router = express.Router();

// Create job
router.post('/', auth, async (req, res) => {
  try {
    const { serviceCategory, description, location, preferredDate, paymentMethod, contactDetails } = req.body;

    const job = new Job({
      consumerId: req.user.id,
      serviceCategory,
      description,
      location,
      preferredDate,
      paymentMethod,
      contactDetails,
    });

    await job.save();

    // Notify providers in real-time
    const io = req.app.get('io');
    const providers = await User.find({ role: 'provider', isOnline: true });
    providers.forEach(provider => {
      io.to(provider.id).emit('newJob', job);
    });

    res.json(job);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get user's jobs
router.get('/', auth, async (req, res) => {
  try {
    let jobs;
    if (req.user.role === 'consumer') {
      jobs = await Job.find({ consumerId: req.user.id }).populate('providerId', 'name phone rating');
    } else {
      jobs = await Job.find({ providerId: req.user.id }).populate('consumerId', 'name phone');
    }
    res.json(jobs);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get job leads for providers
router.get('/leads', auth, async (req, res) => {

  // console.log(`---> Request received at: /jobs/leads | UserID: ${req.user?.id} | Role: ${req.user?.role}`);

  try {
    if (req.user.role !== 'provider') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const allPending = await Job.find({ status: 'pending' });
    console.log("Total Pending Jobs in DB:", allPending.length);

    const jobs = await Job.find({ 
      status: 'pending',
      rejectedBy: { $nin: req.user.id }
    }).populate('consumerId', 'name location phone role');

    console.log("Jobs sending to frontend:", jobs.length);

    res.json(jobs);
  } catch (err) {
    console.error("Backend Error in /leads:", err.message);
    res.status(500).send('Server error');
  }
});

// Accept job
router.put('/:id/accept', auth, async (req, res) => {
  try {
    if (req.user.role !== 'provider') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const job = await Job.findById(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.status !== 'pending') {
      return res.status(400).json({ message: 'Job already processed' });
    }

    job.providerId = req.user.id;
    job.status = 'accepted';
    await job.save();

    // Notify consumer
    const io = req.app.get('io');
    io.to(job.consumerId.toString()).emit('jobAccepted', job);

    res.json(job);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Decline job
router.put('/:id/decline', auth, async (req, res) => {
  try {
    if (req.user.role !== 'provider') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const job = await Job.findById(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.status !== 'pending') {
      return res.status(400).json({ message: 'Job already processed' });
    }

    // Add provider to rejectedBy array
    if (!job.rejectedBy.includes(req.user.id)) {
      job.rejectedBy.push(req.user.id);
    }
    await job.save();

    res.json(job);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Complete job
router.put('/:id/complete', auth, async (req, res) => {
  try {
    const job = await Job.findById(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    // Allow consumer or the assigned provider to complete the job
    if (req.user.role === 'consumer' && job.consumerId.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Access denied' });
    }
    if (req.user.role === 'provider' && job.providerId.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Access denied' });
    }

    job.status = 'completed';
    job.paymentStatus = 'completed';
    await job.save();

    // Notify the other party
    const io = req.app.get('io');
    if (req.user.role === 'provider') {
      io.to(job.consumerId.toString()).emit('jobCompleted', job);
    } else {
      io.to(job.providerId.toString()).emit('jobCompleted', job);
    }

    res.json(job);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;