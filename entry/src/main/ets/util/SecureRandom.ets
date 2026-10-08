import { cryptoFramework } from '@kit.CryptoArchitectureKit';

class SecureRandom {
  private generator: cryptoFramework.Random = cryptoFramework.createRandom();

  private nextUint32(): number {
    const bytes: Uint8Array = this.generator.generateRandomSync(4).data;
    return (((bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3]) >>> 0);
  }

  nextInt(maxExclusive: number): number {
    if (maxExclusive <= 0) {
      throw new Error('maxExclusive must be greater than 0');
    }
    const limit: number = Math.floor(0x100000000 / maxExclusive) * maxExclusive;
    let value: number = this.nextUint32();
    while (value >= limit) {
      value = this.nextUint32();
    }
    return value % maxExclusive;
  }

  nextRange(minInclusive: number, maxInclusive: number): number {
    return minInclusive + this.nextInt(maxInclusive - minInclusive + 1);
  }

  pick<T>(items: Array<T>): T {
    return items[this.nextInt(items.length)];
  }
}

export const secureRandom: SecureRandom = new SecureRandom();