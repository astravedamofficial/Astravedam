require('dotenv').config();
const mongoose = require('mongoose');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB Atlas'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });
  const UserChart = require('./models/UserChart');
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3000;
// Middleware
app.use(cors());
app.use(express.json());

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

app.post('/api/calculate-chart', async (req, res) => {
  try {
    const birthData = req.body;
    console.log('📊 Received birth data:', birthData);
    
    // Validate required fields
    if (!birthData.date || !birthData.time || !birthData.location) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Calculate birth chart
    const chart = calculateBirthChart(birthData);
    console.log('🧮 Chart calculated:', chart);
    
    // Create document to save
    const userChartData = {
      name: birthData.name || 'User',
      birthDate: new Date(birthData.date),
      birthTime: birthData.time,
      location: birthData.location,
      latitude: birthData.latitude || 0,
      longitude: birthData.longitude || 0,
      timezone: birthData.timezone || 'UTC',
      chartData: chart
    };
    
    console.log('💾 Attempting to save:', userChartData);
    
    // Save to database
    const userChart = new UserChart(userChartData);
    const savedChart = await userChart.save();
    
    console.log('✅ SUCCESSFULLY SAVED TO MONGODB:');
    console.log('   Database:', mongoose.connection.name);
    console.log('   Collection:', userChart.collection.name);
    console.log('   Document ID:', savedChart._id);
    console.log('   Saved document:', savedChart);
    
    res.json({
      success: true,
      chart: chart,
      chartId: savedChart._id,
      message: 'Birth chart calculated and saved successfully'
    });
  } catch (error) {
    console.error('❌ SAVE ERROR:', error);
    res.status(500).json({ error: 'Internal server error: ' + error.message });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: '🚀 Astravedam Backend is running!', 
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`\n🎯 Astravedam Backend Started!`);
  console.log(`📍 Local: http://localhost:${PORT}`);
  console.log(`❤️  Health: http://localhost:${PORT}/api/health`);
  console.log(`📊 Chart API: POST http://localhost:${PORT}/api/calculate-chart\n`);
});