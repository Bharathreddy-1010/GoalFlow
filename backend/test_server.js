const fs = require('fs');
fs.writeFileSync('/Users/bharathreddy/Desktop/GoalHackthon/backend/debug.log', 'STARTING\n');

try {
  const express = require('express');
  fs.appendFileSync('/Users/bharathreddy/Desktop/GoalHackthon/backend/debug.log', 'EXPRESS LOADED\n');

  const cors = require('cors');
  fs.appendFileSync('/Users/bharathreddy/Desktop/GoalHackthon/backend/debug.log', 'CORS LOADED\n');

  const { pool } = require('./dist/db/index.js');
  fs.appendFileSync('/Users/bharathreddy/Desktop/GoalHackthon/backend/debug.log', 'DB LOADED\n');

  const apiRouter = require('./dist/routes/api.js');
  fs.appendFileSync('/Users/bharathreddy/Desktop/GoalHackthon/backend/debug.log', 'API LOADED\n');

  const app = express();
  app.use(cors());
  app.use(express.json());

  app.get('/health', (req, res) => res.json({ status: 'ok' }));
  app.use('/api', apiRouter.default || apiRouter);

  const server = app.listen(5001, '0.0.0.0', () => {
    fs.appendFileSync('/Users/bharathreddy/Desktop/GoalHackthon/backend/debug.log', 'SERVER LISTENING ON 5001\n');
    console.log('SERVER LISTENING ON 5001');
  });
} catch (e) {
  fs.appendFileSync('/Users/bharathreddy/Desktop/GoalHackthon/backend/debug.log', 'ERROR: ' + e.message + '\n' + e.stack + '\n');
}
