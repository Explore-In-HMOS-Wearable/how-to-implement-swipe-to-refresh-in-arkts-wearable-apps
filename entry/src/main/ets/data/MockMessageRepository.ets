import { Message } from '../model/Message';
import { MessageRepository } from './MessageRepository';
import { secureRandom } from '../util/SecureRandom';

const SENDERS: string[] = [
  'Michael Brooks',
  'Grace Miller',
  'Daniel Carter',
  'Delivery Service',
  'Olivia Reed'
];

const PREVIEWS: string[] = [
  'Call me when you get a chance.',
  'Your order has been shipped.',
  'Does lunch at noon still work?',
  'The driver is 5 minutes away.',
  'Standup is pushed to 10am.'
];

/** Ages (in minutes) of the seed messages, newest first. */
const SEED_AGES_MINUTES: number[] = [12, 30, 48, 66, 84];

/** Simulated network latency so the loading state is actually visible. */
const FETCH_LATENCY_MS: number = 1100;

/** Slightly longer delay on first load, so the skeleton is visible. */
const INITIAL_LOAD_MS: number = 800;

/** Chance (percent) that a pull-to-refresh fails, to exercise the error state. */
const FAILURE_RATE_PERCENT: number = 30;

/**
 * In-memory repository that fakes a backend. It answers after a short delay
 * and never touches the network, so no permission or live endpoint is needed.
 */
export class MockMessageRepository implements MessageRepository {
  private sequence: number = 0;
  private oldestAgeMinutes: number = SEED_AGES_MINUTES[SEED_AGES_MINUTES.length - 1];

  loadInitial(): Promise<Message[]> {
    return new Promise<Message[]>((resolve: (value: Message[]) => void): void => {
      setTimeout((): void => {
        const seed: Message[] = SEED_AGES_MINUTES.map(
          (ageMinutes: number): Message => this.createMessage(ageMinutes, false)
        );
        resolve(seed);
      }, INITIAL_LOAD_MS);
    });
  }

  fetchNewer(): Promise<Message[]> {
    return new Promise<Message[]>(
      (resolve: (value: Message[]) => void, reject: (reason: Object) => void): void => {
        setTimeout((): void => {
          if (secureRandom.nextInt(100) < FAILURE_RATE_PERCENT) {
            reject(new Error('Simulated network error'));
            return;
          }
          const count: number = secureRandom.nextRange(1, 3);
          const fresh: Message[] = [];
          for (let i = 0; i < count; i++) {
            fresh.push(this.createMessage(0, true));
          }
          resolve(fresh);
        }, FETCH_LATENCY_MS);
      });
  }

  fetchOlder(): Promise<Message[]> {
    return new Promise<Message[]>((resolve: (value: Message[]) => void): void => {
      setTimeout((): void => {
        const count: number = secureRandom.nextRange(3, 5);
        const older: Message[] = [];
        for (let i = 0; i < count; i++) {
          this.oldestAgeMinutes += secureRandom.nextRange(15, 45);
          older.push(this.createMessage(this.oldestAgeMinutes, false));
        }
        resolve(older);
      }, FETCH_LATENCY_MS);
    });
  }

  private createMessage(ageMinutes: number, unread: boolean): Message {
    this.sequence++;
    return new Message(
      `m_${this.sequence}`,
      secureRandom.pick(SENDERS),
      secureRandom.pick(PREVIEWS),
      Date.now() - ageMinutes * 60000,
      unread
    );
  }
}
