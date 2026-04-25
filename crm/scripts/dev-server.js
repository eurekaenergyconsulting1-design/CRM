const fs = require('fs');
const path = require('path');
const http = require('http');

const PORT = process.env.PORT || 3000;
const SRC_DIR = path.join(__dirname, '../src');

const mimeTypes = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
  let filePath = path.join(SRC_DIR, req.url === '/' ? 'index.html' : req.url);
  const ext = path.extname(filePath);
  const contentType = mimeTypes[ext] || 'text/plain';

  fs.stat(filePath, (err) => {
    if (err) {
      res.writeHead(404);
      res.end('404 - Not Found');
      return;
    }

    res.writeHead(200, { 'Content-Type': contentType });
    fs.createReadStream(filePath).pipe(res);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`\n Eureka CRM dev server running`);
  console.log(` http://localhost:${PORT}`);
  console.log(` Serving from: ${SRC_DIR}`);
  console.log(` Press Ctrl+C to stop\n`);
});
