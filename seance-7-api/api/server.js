const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const jsonServer = require('json-server');

const PORT = process.env.PORT || 3000;
const DEMO_PASSWORD = 'campus123';

const seedFile = path.join(__dirname, 'db.json');
const workDir = path.join(__dirname, '.data');
const workFile = path.join(workDir, 'db.json');
fs.mkdirSync(workDir, { recursive: true });
fs.copyFileSync(seedFile, workFile);

const server = jsonServer.create();
const router = jsonServer.router(workFile);
const tokens = new Map();

server.use(jsonServer.defaults());
server.use(jsonServer.bodyParser);

server.post('/login', (req, res) => {
  const { email, password } = req.body || {};
  const user = router.db.get('utilisateurs').find({ email }).value();

  if (!user || password !== DEMO_PASSWORD) {
    return res.status(401).json({ message: 'Wrong email or password' });
  }

  const token = crypto.randomBytes(24).toString('hex');
  tokens.set(token, user.id);
  res.json({ token, user });
});

server.use((req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';

  if (!tokens.has(token)) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  req.userId = tokens.get(token);
  next();
});

server.get('/me', (req, res) => {
  const user = router.db.get('utilisateurs').find({ id: req.userId }).value();
  res.json(user);
});

server.use(router);

server.listen(PORT, () => {
  console.log(`CampusFlow API on http://localhost:${PORT}`);
});
