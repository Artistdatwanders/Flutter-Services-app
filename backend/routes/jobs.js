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
  try {
    if (req.user.role !== 'provider') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const jobs = await Job.find({ status: 'pending' }).populate('consumerId', 'name location');
    res.json(jobs);
  } catch (err) {
    console.error(err.message);
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

    job.status = 'declined';
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
    if (req.user.role !== 'consumer') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const job = await Job.findById(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.consumerId.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Access denied' });
    }

    job.status = 'completed';
    job.paymentStatus = 'completed';
    await job.save();

    // Notify provider
    const io = req.app.get('io');
    io.to(job.providerId.toString()).emit('jobCompleted', job);

    res.json(job);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;