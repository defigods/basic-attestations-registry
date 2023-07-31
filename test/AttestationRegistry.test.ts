import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Contract } from 'ethers';
import { formatBytes32String } from 'ethers/lib/utils';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('Attestation Registry', function () {
  let owner: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;
  let registry: Contract;
  let mock: Contract;
  const ZeroAddress = ethers.constants.AddressZero;

  beforeEach(async () => {
    [owner, alice, bob] = await ethers.getSigners();
    const AttestationRegistry = await ethers.getContractFactory('AttestationRegistry');
    const Mock = await ethers.getContractFactory('Mock');

    registry = await AttestationRegistry.deploy();
    mock = await Mock.deploy(registry.address);
  });

  describe('#attest', () => {
    it('revert if attester is contract', async () => {
      await expect(mock.attest()).to.revertedWithCustomError(registry, 'InvalidAttester');
    });

    it('revert if attestee is 0x0', async () => {
      await expect(registry.attest(0, ZeroAddress, '0x', '0x')).to.revertedWithCustomError(
        registry,
        'InvalidAttestee',
      );
    });

    it('should register attest info properly', async () => {
      const tx = await registry.attest(
        0,
        alice.address,
        formatBytes32String('test_key'),
        formatBytes32String('test_value'),
      );
      const info = await registry.attestByIndex(0);
      expect(tx)
        .emit(registry, 'AttestRegistered')
        .withArgs(
          0,
          alice.address,
          formatBytes32String('test_key'),
          formatBytes32String('test_value'),
        );
      expect(info[0], 0);
      expect(info[1], alice.address);
      expect(info[2], formatBytes32String('test_key'));
      expect(info[3], formatBytes32String('test_value'));
    });
  });

  describe('getter functions', () => {
    beforeEach(async () => {
      for (let i = 0; i < 10; i++) {
        const attester = i < 5 ? owner : alice;
        const attestee = i < 5 ? alice : bob;
        await registry
          .connect(attester)
          .attest(
            i % 4,
            attestee.address,
            formatBytes32String(`test_key_${i + 1}`),
            formatBytes32String(`test_value_${i + 1}`),
          );
      }
    });

    it('#attestByIndex', async () => {
      let info = await registry.attestByIndex(4);
      expect(info[0], 4);
      info = await registry.attestByIndex(7);
      expect(info[0], 7);
    });

    it('#attestByAttesterAndIndex', async () => {
      let info = await registry.attestByAttesterAndIndex(owner.address, 4);
      expect(info[2], alice.address);
      info = await registry.attestByAttesterAndIndex(alice.address, 3);
      expect(info[2], bob.address);
    });
  });
});
