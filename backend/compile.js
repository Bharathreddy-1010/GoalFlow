const ts = require('typescript');
const fs = require('fs');
const path = require('path');

function getAllFiles(dirPath, arrayOfFiles = []) {
  const files = fs.readdirSync(dirPath);

  files.forEach(function(file) {
    const fullPath = path.join(dirPath, file);
    if (fs.statSync(fullPath).isDirectory()) {
      arrayOfFiles = getAllFiles(fullPath, arrayOfFiles);
    } else if (file.endsWith('.ts')) {
      arrayOfFiles.push(fullPath);
    }
  });

  return arrayOfFiles;
}

const srcDir = path.resolve(__dirname, 'src');
const outDir = path.resolve(__dirname, 'dist');
const fileNames = getAllFiles(srcDir);

console.log(`Transpiling ${fileNames.length} TypeScript files to ${outDir}...`);

fileNames.forEach(filePath => {
  const relPath = path.relative(srcDir, filePath);
  const targetJsPath = path.join(outDir, relPath.replace(/\.ts$/, '.js'));
  const targetDir = path.dirname(targetJsPath);

  fs.mkdirSync(targetDir, { recursive: true });

  const tsCode = fs.readFileSync(filePath, 'utf8');
  const result = ts.transpileModule(tsCode, {
    compilerOptions: {
      target: ts.ScriptTarget.ES2022,
      module: ts.ModuleKind.CommonJS,
      esModuleInterop: true,
    }
  });

  fs.writeFileSync(targetJsPath, result.outputText, 'utf8');
  console.log(` -> Emitted ${path.relative(__dirname, targetJsPath)}`);
});

console.log('✅ All TypeScript files successfully compiled to dist!\n');
