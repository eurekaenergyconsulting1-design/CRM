const fs = require('fs');
const path = require('path');

const SRC_FILE = path.join(__dirname, '../src/index.html');
const DIST_DIR = path.join(__dirname, '../dist');
const OUTPUT_FILE = path.join(DIST_DIR, 'index.html');

async function build() {
  console.log('\n Build Eureka CRM...\n');

  try {
    // Créer dist s'il n'existe pas
    if (!fs.existsSync(DIST_DIR)) {
      fs.mkdirSync(DIST_DIR, { recursive: true });
    }

    // Lire le HTML source
    let html = fs.readFileSync(SRC_FILE, 'utf-8');

    // Écrire dans dist
    fs.writeFileSync(OUTPUT_FILE, html);

    const sizeKb = (html.length / 1024).toFixed(2);

    console.log(` Build complete!`);
    console.log(` Output: ${OUTPUT_FILE}`);
    console.log(` Size: ${sizeKb} KB\n`);
  } catch (err) {
    console.error(' Build failed:', err.message);
    process.exit(1);
  }
}

build();
