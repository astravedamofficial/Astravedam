const axios = require('axios');

const geocodeLocation = async (locationText) => {
  try {
    console.log(`📍 Geocoding: ${locationText}`);
    
    const response = await axios.get(
      'https://api.geoapify.com/v1/geocode/search',
      {
        params: {
          text: locationText,
          apiKey: process.env.GEOAPIFY_KEY,
          limit: 1,
          format: 'json'
        },
        timeout: 5000
      }
    );
    
    if (response.data.results?.length > 0) {
      const result = response.data.results[0];
      return {
        success: true,
        latitude: result.lat,
        longitude: result.lon,
        formatted: result.formatted,
        city: result.city || result.county || '',
        country: result.country,
        timezone: result.timezone?.name || 'UTC',
        place_id: result.place_id
      };
    }
    
    return {
      success: false,
      error: 'Location not found'
    };
    
  } catch (error) {
    console.error('❌ Geoapify error:', error.message);
    return {
      success: false,
      error: error.message
    };
  }
};

module.exports = { geocodeLocation };