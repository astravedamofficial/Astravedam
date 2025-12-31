require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
// Add these lines AFTER line 5 (after mongoose import)
const session = require('express-session');
const passport = require('./utils/googleOAuth');
const { optionalAuth } = require('./utils/auth');
const User = require('./models/User');

const UserChart = require('./models/UserChart');
const { geocodeLocation } = require('./utils/geoapify');

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
app.use(express.json({ limit: '10mb' }));
// Middleware - PUT THIS RIGHT AFTER app.use(express.json())
app.use(cors({
    origin: function (origin, callback) {
      // Allow requests with no origin (like mobile apps, curl)
      if (!origin) return callback(null, true);
      
      // Allow all localhost ports
      if (origin.startsWith('http://localhost:')) {
        return callback(null, true);
      }
      
      // Allow your Render URL
      if (origin === 'https://astravedam.onrender.com') {
        return callback(null, true);
      }
      
      // Allow any origin for now (remove in production)
      return callback(null, true); // TEMPORARY - allows all origins
    },
    credentials: true,
    methods: ['GET', 'POST', 'OPTIONS', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    exposedHeaders: ['Content-Length', 'X-Kuma-Revision'],
    maxAge: 600, // 10 minutes
    preflightContinue: false,
    optionsSuccessStatus: 204
  }));
  
  // Add OPTIONS handler for all routes
  app.options('*', cors());
app.use(express.urlencoded({ extended: true }));

// Session configuration (for Google OAuth)
app.use(session({
    secret: process.env.SESSION_SECRET || 'astravedam_secret',
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: process.env.NODE_ENV === 'production', // Use secure cookies in production
      maxAge: 24 * 60 * 60 * 1000 // 24 hours
    }
  }));
  
  // Initialize Passport
  app.use(passport.initialize());
  app.use(passport.session());

// Add CORS headers to all responses
app.use((req, res, next) => {
    const origin = req.headers.origin;
    
    // Set Access-Control-Allow-Origin dynamically
    if (origin && (origin.startsWith('http://localhost:') || origin === 'https://astravedam.onrender.com')) {
      res.header('Access-Control-Allow-Origin', origin);
    } else {
      res.header('Access-Control-Allow-Origin', '*');
    }
    
    res.header('Access-Control-Allow-Credentials', 'true');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.header('Access-Control-Expose-Headers', 'Content-Length');
    
    next();
  });

// ✅ FIXED: Updated MongoDB connection (remove deprecated options)
mongoose.connect(process.env.MONGODB_URI)
.then(() => console.log('✅ Connected to MongoDB Atlas'))
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Mock astrology data
const rashis = ['Mesha', 'Vrishabha', 'Mithuna', 'Karka', 'Simha', 'Kanya', 'Tula', 'Vrishchika', 'Dhanu', 'Makara', 'Kumbha', 'Meena'];
const nakshatras = ['Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'];

// Calculate mock birth chart
function calculateBirthChart(birthData) {
  const { name, date, time, location } = birthData;
  
  // Simple hash for consistent mock data
  const hash = location.length + date.length + time.length;
  
  const chart = {
    lagna: rashis[hash % rashis.length],
    planets: {
      sun: { 
        rashi: rashis[(hash + 1) % rashis.length], 
        nakshatra: nakshatras[(hash + 1) % nakshatras.length], 
        degree: (hash % 30) + 1 
      },
      moon: { 
        rashi: rashis[(hash + 2) % rashis.length], 
        nakshatra: nakshatras[(hash + 2) % nakshatras.length], 
        degree: ((hash + 5) % 30) + 1 
      },
      mars: { 
        rashi: rashis[(hash + 3) % rashis.length], 
        nakshatra: nakshatras[(hash + 3) % nakshatras.length], 
        degree: ((hash + 10) % 30) + 1 
      },
    },
    houses: {
      first: { lord: 'Mars', sign: rashis[hash % rashis.length] },
      second: { lord: 'Venus', sign: rashis[(hash + 1) % rashis.length] },
      third: { lord: 'Mercury', sign: rashis[(hash + 2) % rashis.length] },
    },
    summary: `Based on your birth details, you have strong ${rashis[hash % rashis.length]} energy. Your chart shows potential for spiritual growth and material success.`
  };
  
  return chart;
}

// ==============================
// 🔐 AUTHENTICATION ROUTES
// ==============================

// 1. Health check (public)
app.get('/api/health', (req, res) => {
    res.json({ 
      status: '🚀 Astravedam Backend is running!', 
      timestamp: new Date().toISOString(),
      version: '2.0.0',
      environment: process.env.NODE_ENV || 'development',
      database: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected',
      features: ['Google Login', 'Multi-Kundali', 'Geocoding']
    });
  });
  
  // 2. Google OAuth Login
  app.get('/api/auth/google',
    passport.authenticate('google', { 
      scope: ['profile', 'email'],
      prompt: 'select_account' // Force account selection
    })
  );
  
  // 3. Google OAuth Callback
  app.get('/api/auth/google/callback',
    passport.authenticate('google', { 
      failureRedirect: '/auth/failed',
      session: false  // We don't need sessions, we'll use JWT
    }),
    async (req, res) => {
      try {
        // Generate JWT token
        const jwt = require('jsonwebtoken');
        const token = jwt.sign(
          { userId: req.user._id },
          process.env.JWT_SECRET,
          { expiresIn: '7d' }
        );
        
        // Redirect to frontend with token
        const frontendUrl = process.env.NODE_ENV === 'production' 
          ? 'https://astravedam-5a3da.web.app'  // Your Flutter web URL
          : 'http://localhost:3001';           // Flutter local URL
        
        res.redirect(`${frontendUrl}/auth/callback?token=${token}&userId=${req.user._id}`);
      } catch (error) {
        console.error('Callback error:', error);
        res.redirect(`${frontendUrl}/auth/error`);
      }
    }
  );
  
  // 4. Get current user profile (protected)
  app.get('/api/auth/me', optionalAuth, async (req, res) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Not authenticated'
        });
      }
      
      res.json({
        success: true,
        user: req.user.getPublicProfile()
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });
  
  // 5. Logout (frontend just discards token)
  app.post('/api/auth/logout', (req, res) => {
    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  });
  
  // 6. Link anonymous charts to user account
  app.post('/api/auth/link-charts', optionalAuth, async (req, res) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Authentication required'
        });
      }
      
      const { anonymousUserId } = req.body;
      
      if (!anonymousUserId) {
        return res.status(400).json({
          success: false,
          error: 'anonymousUserId is required'
        });
      }
      
      // Find all charts with this anonymous ID
      const charts = await UserChart.find({ userId: anonymousUserId });
      
      // Link them to the user
      for (const chart of charts) {
        chart.ownerUserId = req.user._id;
        await chart.save();
      }
      
      res.json({
        success: true,
        linkedCount: charts.length,
        message: `Successfully linked ${charts.length} charts to your account`
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });
  
  // 7. Auth failure route
  app.get('/auth/failed', (req, res) => {
    res.status(401).json({
      success: false,
      error: 'Google authentication failed'
    });
  });
  

// Routes
app.post('/api/calculate-chart', optionalAuth, async (req, res) => {
    console.log('📥 Received chart request:', req.body);
    
    try {
      const { 
        name, 
        date, 
        time, 
        location, 
        userId,          // Anonymous user ID
        personName,      
        setAsPrimary     
      } = req.body;
  

      // Validate required fields
      if (!date || !time || !location) {
        return res.status(400).json({ 
          success: false,
          error: 'Missing required fields: date, time, location' 
        });
      }
      
      // 1. Geocode the location
      console.log('📍 Step 1: Geocoding location...');
      const geoResult = await geocodeLocation(location);
      
      if (!geoResult.success) {
        return res.status(400).json({
          success: false,
          error: `Could not find location: ${location}. Please enter a valid city name.`
        });
      }
      
      console.log('📍 Geocoding result:', geoResult);
      
      // 2. Prepare enhanced birth data
      const enhancedBirthData = {
        name: name || 'User',
        date: date,
        time: time,
        location: location,
        latitude: geoResult.latitude,
        longitude: geoResult.longitude,
        timezone: geoResult.timezone
      };
      
      // 3. Calculate birth chart (your existing function)
      console.log('🔮 Step 2: Calculating chart...');
      const chart = calculateBirthChart(enhancedBirthData);
      
      // 4. Save to database
      console.log('💾 Step 3: Saving to database...');
     // ✅ CRITICAL FIX 1: Ensure only one primary per user
     if ((userId || req.user) && setAsPrimary === true) {
        let query = {};
        
        if (req.user) {
          // Registered user: unset primaries for this user
          query.ownerUserId = req.user._id;
        } else if (userId) {
          // Anonymous user: unset primaries for this anonymous ID
          query.userId = userId;
        }
        
        await UserChart.updateMany(
          query, 
          { $set: { isPrimary: false } }
        );
        console.log(`♻️ Reset previous primaries`);
      }
    
    // ✅ Create the chart (same as before with fixed logic)
    // ✅ Create the chart with dual ownership
    const userChart = new UserChart({
        // Anonymous system
        userId: userId || null,
        ownerUserId: req.user?._id || null,
        personName: personName || name || 'User',
        isPrimary: (userId || req.user) ? (setAsPrimary === true) : true,
        
        // All existing fields (NO CHANGES)
        name: name || 'User',
        birthDate: new Date(date),
        birthTime: time,
        location: location,
        formattedAddress: geoResult.formatted,
        latitude: geoResult.latitude,
        longitude: geoResult.longitude,
        timezone: geoResult.timezone,
        country: geoResult.country,
        city: geoResult.city,
        placeId: geoResult.place_id,
        chartData: chart
    });
    
    const savedChart = await userChart.save();
    console.log('✅ Saved chart. ID:', savedChart._id, '| User:', savedChart.userId, '| Primary:', savedChart.isPrimary);

      console.log('✅ Saved chart ID:', savedChart._id);
      
      // 5. Return success response
      res.json({
        success: true,
        chart: chart,
        chartId: savedChart._id,
        locationData: {
          coordinates: {
            lat: geoResult.latitude,
            lng: geoResult.longitude
          },
          timezone: geoResult.timezone,
          formattedAddress: geoResult.formatted,
          city: geoResult.city,
          country: geoResult.country
        },
        message: 'Birth chart calculated successfully'
      });
      
    } catch (error) {
      console.error('❌ Server error in /api/calculate-chart:', error);
      res.status(500).json({ 
        success: false,
        error: 'Internal server error',
        details: error.message 
      });
    }
  });

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: '🚀 Astravedam Backend is running!', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    database: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected'
  });
});

app.get('/api/charts', optionalAuth, async (req, res) => {
    try {
      let query = {};
      
      // Priority 1: If user is logged in, get their charts
      if (req.user) {
        query.ownerUserId = req.user._id;
        console.log(`📊 Fetching charts for registered user: ${req.user._id}`);
      } 
      // Priority 2: If anonymous userId provided in query
      else if (req.query.userId) {
        query.userId = req.query.userId;
        console.log(`📊 Fetching charts for anonymous user: ${req.query.userId}`);
      }
      // Priority 3: If both user is logged in AND anonymous ID provided
      // (This happens when user logs in for first time and we need to merge)
      else if (req.user && req.query.anonymousUserId) {
        // Return charts from BOTH sources for merging
        const registeredCharts = await UserChart.find({ ownerUserId: req.user._id });
        const anonymousCharts = await UserChart.find({ userId: req.query.anonymousUserId });
        
        const allCharts = [...registeredCharts, ...anonymousCharts];
        
        return res.json({
          success: true,
          charts: allCharts,
          count: allCharts.length,
          source: 'merged'
        });
      }
      else {
        return res.status(400).json({ 
          success: false, 
          error: 'User identifier required. Please login or provide userId.' 
        });
      }
    
      const charts = await UserChart.find(query)
        .sort({ createdAt: -1 })
        .select('-__v'); // Exclude version field
      
      console.log(`📊 Found ${charts.length} charts`);
      
      res.json({
        success: true,
        charts: charts,
        count: charts.length,
        source: req.user ? 'registered' : 'anonymous'
      });
      
    } catch (error) {
      console.error('❌ /api/charts error:', error);
      res.status(500).json({ 
        success: false,
        error: 'Internal server error',
        details: error.message 
      });
    }
  });
  
// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🎯 Astravedam Backend Started!`);
  console.log(`📍 Render URL: https://astravedam.onrender.com`);
  console.log(`📍 Port: ${PORT}`);
  console.log(`❤️  Health: /api/health`);
  console.log(`📊 Chart API: POST /api/calculate-chart`);
  console.log(`🌐 CORS: ${process.env.CORS_ORIGIN || '*'}`);
  console.log(`🗄️  Database: ${mongoose.connection.readyState === 1 ? '✅ Connected' : '❌ Disconnected'}\n`);
});