import { ethers } from 'hardhat';

const main = async () => {
  const RegistryFactory = await ethers.getContractFactory('AttestRegistry');
  const ServiceFactory = await ethers.getContractFactory('SBTAttestService');

  const registry = await RegistryFactory.deploy();
  const service = await ServiceFactory.deploy(registry.address);

  console.log('Registry:', registry.address);
  console.log('Service:', service.address);
};

main()
  .then(() => process.exit(0))
  .catch((err) => console.log(err));
