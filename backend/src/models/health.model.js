const pool = require('../config/db');

async function checkDatabase() {
  const [rows] = await pool.query('SELECT DATABASE() AS database_name, 1 AS connection_test');
  return rows[0];
}

module.exports = { checkDatabase };
