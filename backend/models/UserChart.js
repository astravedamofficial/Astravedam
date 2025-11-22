const mongoose = require('mongoose');

const userChartSchema = new mongoose.Schema({
  name: String,
  birthDate: Date,
  birthTime: String,
  location: String,
  latitude: Number,
  longitude: Number,
  timezone: String,
  chartData: Object,
  createdAt: { type: Date, default: Date.now }
}, { 
  strict: false  // Allow extra fields during development
});

module.exports = mongoose.model('UserChart', userChartSchema);