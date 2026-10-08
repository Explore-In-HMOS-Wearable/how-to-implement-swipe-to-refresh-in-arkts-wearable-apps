import { Message } from '../model/Message';

export interface MessageRepository {
  /** Messages to show on first load. */
  loadInitial(): Promise<Message[]>;

  /** Newer messages to prepend when the user pulls to refresh. */
  fetchNewer(): Promise<Message[]>;

  /** Older messages to append when the user scrolls to the bottom. */
  fetchOlder(): Promise<Message[]>;
}