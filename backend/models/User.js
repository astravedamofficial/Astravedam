const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  // Google OAuth fields
  googleId: {
    type: String,
    unique: true,
    sparse: true  // Allows null for mobile login later
  },
  
  // For future mobile login
  mobile: {
    type: String,
    unique: true,
    sparse: true
  },
  
  // User profile
  email: {
    type: String,
    lowercase: true,
    trim: true
  },
  name: String,
  avatar: String,
  
  // Account flags
  isEmailVerified: {
    type: Boolean,
    default: true  // Google emails are verified
  },
  isMobileVerified: {
    type: Boolean,
    default: false
  },
  
  // Astrology-specific fields
  credits: {
    type: Number,
    default: 5  // Free credits for new users
  },
  totalCreditsPurchased: {
    type: Number,
    default: 0
  },
  primaryKundaliId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'UserChart',
    default: null
  },
  
  // Timestamps
  lastLogin: Date,
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update timestamp before saving
userSchema.pre('save', function(next) {
  this.updatedAt = new Date();
});

// Method to get public profile (without sensitive info)
userSchema.methods.getPublicProfile = function() {
  return {
    _id: this._id,
    email: this.email,
    name: this.name,
    avatar: this.avatar,
    credits: this.credits,
    isEmailVerified: this.isEmailVerified,
    isMobileVerified: this.isMobileVerified,
    createdAt: this.createdAt,
    lastLogin: this.lastLogin
  };
};

const User = mongoose.model('User', userSchema);

module.exports = User;