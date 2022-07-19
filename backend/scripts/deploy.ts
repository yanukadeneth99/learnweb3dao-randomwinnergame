import { ethers } from "hardhat";
import hre from "hardhat";
import "@nomiclabs/hardhat-etherscan";
import { FEE, VRF_COORDINATOR, LINK_TOKEN, KEY_HASH } from "../constants/index";

async function main() {
  //* Deployement Process
  const RandomWinnerGame = await ethers.getContractFactory("RandomWinnerGame");
  const randomWinnerGame = await RandomWinnerGame.deploy(
    VRF_COORDINATOR,
    LINK_TOKEN,
    KEY_HASH,
    FEE
  );

  await randomWinnerGame.deployed();

  console.log("Contract Deployed to :", randomWinnerGame.address);

  //* Verfication Process
  console.log("Sleeping...");
  await sleep(50000);

  await hre.run("verify:verify", {
    address: randomWinnerGame.address,
    constructorArguments: [VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE],
  });
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
