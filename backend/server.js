require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

// Import UserChart model
const UserChart = require('./models/UserChart');

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
// With this:
app.use(cors({
    origin: ['http://localhost:49934', 'http://localhost:3000', 'https://astravedam.onrender.com'],
    methods: ['GET', 'POST', 'OPTIONS'],
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization']
  }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

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

// Routes
app.post('/api/calculate-chart', async (req, res) => {
  try {
    const birthData = req.body;
    console.log('📊 Received birth data:', birthData);
    
    // Validate required fields
    if (!birthData.date || !birthData.time || !birthData.location) {
      return res.status(400).json({ error: 'Missing required fields: date, time, location' });
    }
    
    // Calculate birth chart
    const chart = calculateBirthChart(birthData);
    
    // Save to database
    const userChart = new UserChart({
      name: birthData.name || 'User',
      birthDate: new Date(birthData.date),
      birthTime: birthData.time,
      location: birthData.location,
      latitude: birthData.latitude || 0,
      longitude: birthData.longitude || 0,
      timezone: birthData.timezone || 'UTC',
      chartData: chart
    });
    
    const savedChart = await userChart.save();
    
    res.json({
      success: true,
      chart: chart,
      chartId: savedChart._id,
      message: 'Birth chart calculated and saved successfully'
    });
    
  } catch (error) {
    console.error('❌ Error in /api/calculate-chart:', error);
    res.status(500).json({ 
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