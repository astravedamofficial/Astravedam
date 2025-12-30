const mongoose = require('mongoose');

const userChartSchema = new mongoose.Schema({
  // ✅ Add index for faster queries
  userId: { 
    type: String,
    default: null,
    index: true  // ✅ Optional but recommended
  },
  
  personName: {
    type: String,
    default: 'User'
  },
  
  isPrimary: {
    type: Boolean,
    default: false
  },
  
  // ✅ ALL EXISTING FIELDS - NO CHANGES
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