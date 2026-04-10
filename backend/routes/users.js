const express = require('express');
const auth = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

// Get user profile
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Update user profile
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, location, isOnline } = req.body;
    const updateFields = {};
    if (name) updateFields.name = name;
    if (location) updateFields.location = location;
    if (isOnline !== undefined) updateFields.isOnline = isOnline;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updateFields },
      { new: true }
    ).select('-password');

    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Update provider status
router.put('/status', auth, async (req, res) => {
  try {
    const { isOnline } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: { isOnline } },
      { new: true }
    ).select('-password');

    // Emit socket event for real-time updates
    const io = req.app.get('io');
    io.to(user.id).emit('statusUpdate', { isOnline });

    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;