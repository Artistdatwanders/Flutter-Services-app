const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json());
 
// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/handyman', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected'))
.catch(err => console.log(err));

// Models
const User = require('./models/User');
const Job = require('./models/Job');
const Service = require('./models/Service');

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/jobs', require('./routes/jobs'));
app.use('/api/services', require('./routes/services'));

// Socket.io for real-time
const connectedUsers = new Map(); // socket.id -> userId

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join', async (userId) => {
    socket.join(userId);
    connectedUsers.set(socket.id, userId);
    await User.findByIdAndUpdate(userId, { isOnline: true });
    console.log(`User ${userId} is now online`);
  });

  socket.on('disconnect', async () => {
    const userId = connectedUsers.get(socket.id);
    if (userId) {
      await User.findByIdAndUpdate(userId, { isOnline: false });
      connectedUsers.delete(socket.id);
      console.log(`User ${userId} is now offline`);
    }
    console.log('User disconnected:', socket.id);
  });
});

// Make io accessible in routes
app.set('io', io);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));