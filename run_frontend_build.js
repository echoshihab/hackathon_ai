const { execSync } = require('child_process');
const path = require('path');

const frontendDir = 'C:\\Users\\echos\\source\\repos\\hackathon_ai\\frontend';

try {
  console.log('Running npm install...');
  const result = execSync('npm install', { 
    cwd: frontendDir, 
    stdio: 'pipe',
    encoding: 'utf8'
  });
  console.log('npm install output:', result);
  
  console.log('\nRunning npm run build...');
  const buildResult = execSync('npm run build', {
    cwd: frontendDir,
    stdio: 'pipe', 
    encoding: 'utf8'
  });
  console.log('Build output:', buildResult);
  console.log('\nBuild completed successfully!');
} catch (err) {
  console.error('Error:', err.message);
  if (err.stdout) console.log('stdout:', err.stdout);
  if (err.stderr) console.log('stderr:', err.stderr);
  process.exit(1);
}
