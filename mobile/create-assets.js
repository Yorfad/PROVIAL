const fs = require('fs');
const path = require('path');

// Crear PNG base64 de 1x1 pixel azul
const createPNG = (width, height, color) => {
  // PNG mínimo en base64 (1x1 pixel transparente)
  const pngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  return Buffer.from(pngBase64, 'base64');
};

const assetsDir = path.join(__dirname, 'assets');

// Crear archivos de assets
const assets = {
  'icon.png': createPNG(1024, 1024, '#1e40af'),
  'splash.png': createPNG(1242, 2436, '#1e40af'),
  'adaptive-icon.png': createPNG(1024, 1024, '#1e40af'),
  'favicon.png': createPNG(48, 48, '#1e40af')
};

Object.entries(assets).forEach(([filename, buffer]) => {
  const filepath = path.join(assetsDir, filename);
  fs.writeFileSync(filepath, buffer);
  console.log(`Created ${filename}`);
});

console.log('✓ All asset files created successfully!');
