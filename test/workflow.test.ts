import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Contract, Wallet } from 'ethers';
import { formatBytes32String } from 'ethers/lib/utils';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

const ZeroAddress = ethers.constants.AddressZero;
const randomAddr = Wallet.createRandom().address;

describe('Attest Workflow', function () {
  let owner: SignerWithAddress;
  let alice: SignerWithAddress;

  let registry: Contract;
  let service: Contract;
  let mock: Contract;
  let sbt: Contract;

  beforeEach(async () => {
    [owner, alice] = await ethers.getSigners();
    const AttestRegistry = await ethers.getContractFactory('AttestRegistry');
    const SBTAttestService = await ethers.getContractFactory('SBTAttestService');
    const Mock = await ethers.getContractFactory('Mock');
    const MockSBT = await ethers.getContractFactory('MockSBT');

    registry = await AttestRegistry.deploy();
    service = await SBTAttestService.deploy(registry.address);
    mock = await Mock.deploy();
    sbt = await MockSBT.deploy();
  });

  describe('#constructor', async () => {
    it('revert if registry address is 0x0', async () => {
      const SBTAttestService = await ethers.getContractFactory('SBTAttestService');
      await expect(SBTAttestService.deploy(ZeroAddress)).to.revertedWithCustomError(
        service,
        'InvalidRegistry',
      );
    });
  });

  describe('#register', () => {
    it('revert if non-owner attempts', async () => {
      await expect(registry.connect(alice).register(0, randomAddr, true)).to.revertedWith(
        'Ownable: caller is not the owner',
      );
    });

    it('revert if service is not contract', async () => {
      await expect(registry.register(0, randomAddr, true)).to.revertedWithCustomError(
        registry,
        'InvalidService',
      );
    });

    it('should register service and emit {AttestServiceRegistered} event', async () => {
      const tx = await registry.register(0, service.address, true);
      expect(tx)
        .emit(registry, 'AttestServiceRegistered')
        .withArgs(0, owner.address, service.address);
      expect(await registry.getAttestService(0)).to.eq(service.address);
    });

    it('revert if service already exists but {forceUpdate} param is false', async () => {
      await registry.register(0, service.address, true);
      await expect(registry.register(0, mock.address, false)).to.revertedWithCustomError(
        registry,
        'ServiceAlreadyExists',
      );
    });
  });

  describe('attest or revoke', () => {
    beforeEach(async () => {
      await registry.register(1, service.address, true);
    });

    it('revert if non-service attest/revoke attempts', async () => {
      await expect(registry.attest(0, [alice.address, '0x', '0x'])).to.revertedWithCustomError(
        registry,
        'ServiceNotExists',
      );
      await expect(registry.revoke(0, [alice.address, '0x', '0x'])).to.revertedWithCustomError(
        registry,
        'ServiceNotExists',
      );
    });

    it('revert if call service attest/revoke not via registry', async () => {
      await expect(service.attest([alice.address, '0x', '0x'])).to.revertedWithCustomError(
        service,
        'NotRegistry',
      );
      await expect(service.revoke([alice.address, '0x', '0x'])).to.revertedWithCustomError(
        service,
        'NotRegistry',
      );
    });

    it('revert if throwable', async () => {
      await service.setThrowable(true);
      await expect(registry.revoke(1, [alice.address, '0x', '0x'])).to.revertedWithCustomError(
        service,
        'ToBeDetermined',
      );
    });

    it('returns false if key is not token address', async () => {
      expect(await registry.callStatic.attest(1, [alice.address, randomAddr, '0x'])).to.eq(false);
    });

    it('returns true if address from key is sbt address and emit {Attested} event', async () => {
      expect(await registry.callStatic.attest(1, [alice.address, sbt.address, '0x'])).to.eq(true);
      const tx = await registry.attest(1, [alice.address, sbt.address, '0x']);
      expect(tx)
        .emit(registry, 'Attested')
        .withArgs(owner.address, alice.address, sbt.address, '0x');
    });

    it('should emit {Revoked} event', async () => {
      const tx = await registry.revoke(1, [alice.address, sbt.address, '0x']);
      expect(tx)
        .emit(registry, 'Revoked')
        .withArgs(owner.address, alice.address, sbt.address, '0x');
    });
  });

  describe('setter & getter functions', () => {
    beforeEach(async () => {
      await registry.register(1, service.address, true);
    });

    it('#setRegistry/getRegistry', async () => {
      expect(await service.getRegistry()).to.eq(registry.address);
      await service.setRegistry(randomAddr);
      expect(await service.getRegistry()).to.eq(randomAddr);
    });

    it('#setThrowable', async () => {
      expect(await service.throwable()).to.eq(false);
      await service.setThrowable(true);
      expect(await service.throwable()).to.eq(true);
    });

    it('#getAttesterService', async () => {
      expect(await registry.getAttestService(1)).to.eq(service.address);
    });

    it('#getAttestType', async () => {
      expect(await service.getAttestType()).to.eq(1);
      const VCAttestService = await ethers.getContractFactory('VCAttestService');
      const IPFSAttestService = await ethers.getContractFactory('IPFSAttestService');
      const OBAttestService = await ethers.getContractFactory('OBAttestService');
      let tempService = await VCAttestService.deploy(registry.address);
      expect(await tempService.getAttestType()).to.eq(0);
      tempService = await IPFSAttestService.deploy(registry.address);
      expect(await tempService.getAttestType()).to.eq(2);
      tempService = await OBAttestService.deploy(registry.address);
      expect(await tempService.getAttestType()).to.eq(3);
    });
  });
});
