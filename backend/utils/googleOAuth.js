const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const User = require('../models/User');

// Configure Passport with Google Strategy
passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: process.env.GOOGLE_CALLBACK_URL,
    passReqToCallback: true
  },
  async (request, accessToken, refreshToken, profile, done) => {
    try {
      console.log('🔐 Google OAuth profile received:', profile.id);
      
      // Check if user already exists
      let user = await User.findOne({ googleId: profile.id });
      
      if (!user) {
        // Check if email already exists (in case user signed up with email later)
        user = await User.findOne({ email: profile.emails[0].value });
        
        if (user) {
          // User exists with email but not Google ID, add Google ID
          user.googleId = profile.id;
          await user.save();
        } else {
          // Create new user
          user = new User({
            googleId: profile.id,
            email: profile.emails[0].value,
            name: profile.displayName,
            avatar: profile.photos[0]?.value,
            isEmailVerified: true,  // Google emails are verified
            lastLogin: new Date()
          });
          
          await user.save();
          console.log('✅ New user created via Google:', user.email);
        }
      } else {
        // Update last login for existing user
        user.lastLogin = new Date();
        await user.save();
        console.log('✅ Existing user logged in via Google:', user.email);
      }
      
      return done(null, user);
    } catch (error) {
      console.error('❌ Google OAuth error:', error);
      return done(error, null);
    }
  }
));

// Serialize user for session
passport.serializeUser((user, done) => {
  done(null, user.id);
});

// Deserialize user from session
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (error) {
    done(error, null);
  }
});

module.exports = passport;