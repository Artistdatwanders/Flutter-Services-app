const mongoose = require('mongoose');
const Service = require('./models/Service');
require('dotenv').config();

const services = [
  { name: 'AC Repair', icon: 'ac_repair' },
  { name: 'Cleaning', icon: 'cleaning' },
  { name: 'Plumbing', icon: 'plumbing' },
  { name: 'Electric', icon: 'electric' },
  { name: 'Fumigation', icon: 'fumigation' },
  { name: 'Carpentry', icon: 'carpentry' },
  { name: 'Painting', icon: 'painting' },
  { name: 'Others', icon: 'others' },
];

const seedServices = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    await Service.deleteMany();
    await Service.insertMany(services);
    console.log('Services seeded successfully');
    process.exit();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};

seedServices();