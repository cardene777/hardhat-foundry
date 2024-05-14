import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { ContractFactory } from "ethers";

task("deploy:deploy-nft", "deploy ERC721 Contract")
  .addParam("contractName", "Contract Name")
  .addParam("name", "NFT Name")
  .addParam("symbol", "NFT Symbol")
  .setAction(async (args, hre) => {
    try {
      const { contractName, name, symbol } = args;
      const factory = (await hre.ethers.getContractFactory(
        contractName
      )) as ContractFactory;

      const contract = await factory.deploy(
        name,
        symbol,
      );

      await contract.waitForDeployment();

      console.log(
        "🚀 ERC721 contract deployed to:",
        await contract.getAddress()
      );
    } catch (e) {
      console.error(e);
    }
  });
