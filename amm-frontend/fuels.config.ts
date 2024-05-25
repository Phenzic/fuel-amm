import { createConfig } from 'fuels';

export default createConfig({
  contracts: [
        '../AMM-contract',
  ],
  output: './src/amm-abi',
});

/**
 * Check the docs:
 * https://fuellabs.github.io/fuels-ts/tooling/cli/fuels/config-file
 */
