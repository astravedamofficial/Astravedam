const mongoose = require('mongoose');

const userChartSchema = new mongoose.Schema({
  name: String,
  birthDate: Date,
  birthTime: String,
  location: String,
  latitude: Number,
  longitude: Number,
  timezone: { type: String, default: 'UTC' },
  formattedAddress: String,
  country: String,
  city: String,
  placeId: String,
  chartData: Object,
  createdAt: { type: Date, default: Date.now }
}, { 
  strict: false
});

module.exports = mongoose.model('UserChart', userChartSchema);