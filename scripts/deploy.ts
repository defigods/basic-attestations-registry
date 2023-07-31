import { ethers } from 'hardhat';

const main = async () => {
  const AttestationRegistry = await ethers.getContractFactory('AttestationRegistry');
  const registry = await AttestationRegistry.deploy();

  console.log('Registry:', registry.address);
};

main()
  .then(() => process.exit(0))
  .catch((err) => console.log(err));
