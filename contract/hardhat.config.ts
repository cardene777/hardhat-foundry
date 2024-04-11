import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-foundry";
import "@nomicfoundation/hardhat-verify";
import "dotenv/config";
import "./tasks";

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
if (!PRIVATE_KEY) {
  throw new Error("Please set your PRIVATE_KEY in a .env file");
}

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.23",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    z_kyoto: {
      url: "https://rpc.startale.com/zkyoto",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: 6038361,
    },
    astar_zkevm: {
      url: "https://rpc.startale.com/astar-zkevm",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: 3776,
    },
  },
  etherscan: {
    apiKey: {
      z_kyoto: process.env.ETHERSCAN_API_KEY || "",
      astar_zkevm: process.env.ETHERSCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "z_kyoto",
        chainId: 6038361,
        urls: {
          apiURL: "https://zkyoto.explorer.startale.com/api",
          browserURL: "https://zkyoto.explorer.startale.com/",
        },
      },
      {
        network: "astar_zkevm",
        chainId: 3776,
        urls: {
          apiURL: "https://astar-zkevm.explorer.startale.com/api",
          browserURL: "https://astar-zkevm.explorer.startale.com/",
        },
      },
    ],
  },
  sourcify: {
    enabled: false,
  },
};

export default config;
