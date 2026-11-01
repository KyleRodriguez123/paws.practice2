const healthModel = require('../models/health.model');

function getApiHealth(req, res) {
  res.status(200).json({
    success: true,
    message: 'Paws of Haven API is running.'
  });
}

async function getDatabaseHealth(req, res, next) {
  try {
    const result = await healthModel.checkDatabase();
    res.status(200).json({
      success: true,
      message: 'Database connection successful.',
      data: result
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { getApiHealth, getDatabaseHealth };
