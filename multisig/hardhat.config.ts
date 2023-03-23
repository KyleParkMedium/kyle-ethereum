import { HardhatUserConfig } from "hardhat/config";

import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      chainId: 1337,
      gasPrice: 20000000000,
      accounts: [
        // example
        "0xee58f4e92301be8b1aed9f44cfb34693e5994b627c2b6a4252e14d64b1c4ae3d",
      ],
    },
  },
};

export default config;
