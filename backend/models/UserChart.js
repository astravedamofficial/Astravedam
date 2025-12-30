const mongoose = require('mongoose');

const userChartSchema = new mongoose.Schema({
    // 1. EXISTING: userId field (keep for legacy support)
    userId: { 
    type: String,
    default: null,
    index: true
  },
  
  // 2. NEW: Link to registered user
  ownerUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
    index: true
  },
  
  // 3. Person information
  personName: {
    type: String,
    default: 'User'
  },
  
  isPrimary: {
    type: Boolean,
    default: false
  },
  
  // 5. ALL EXISTING FIELDS (NO CHANGES)
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
  
  // 6. Timestamps
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, { 
  strict: false  // Keep this for flexibility
});

// Update timestamp before saving
userChartSchema.pre('save', function(next) {
  this.updatedAt = new Date();
});

module.exports = mongoose.model('UserChart', userChartSchema);