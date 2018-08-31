const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const gigPath = path.resolve(__dirname, 'contracts', 'Gigs.sol');
const source = fs.readFileSync(gigPath, 'utf8');
const output = solc.compile(source, 1).contracts;

console.log('contracts is---->',output);

fs.ensureDirSync(buildPath);

for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}
