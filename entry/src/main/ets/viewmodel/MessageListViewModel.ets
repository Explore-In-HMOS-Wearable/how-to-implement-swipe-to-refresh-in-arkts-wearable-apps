import { UIContext } from '@kit.ArkUI';
import { Message } from '../model/Message';
import { MessageRepository } from '../data/MessageRepository';
import { MockMessageRepository } from '../data/MockMessageRepository';
import { formatClock } from '../util/TimeFormat';

const MAX_MESSAGES: number = 50;
const UNREAD_TIMEOUT_MS: number = 3000;

@ObservedV2
export class MessageListViewModel {
  @Trace messages: Message[] = [];
  @Trace refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  @Trace lastSync: string = '';
  @Trace isInitialLoading: boolean = true;
  @Trace isLoadingMore: boolean = false;
  @Trace lastRefreshFailed: boolean = false;
  private readonly repository: MessageRepository;

  constructor(repository: MessageRepository = new MockMessageRepository()) {
    this.repository = repository;
  }

  async loadInitial(): Promise<void> {
    this.messages = await this.repository.loadInitial();
    this.lastSync = formatClock();
    this.isInitialLoading = false;
  }

  async refresh(uiContext: UIContext): Promise<number> {
    try {
      const fresh: Message[] = await this.repository.fetchNewer();
      const merged: Message[] = fresh.concat(this.messages).slice(0, MAX_MESSAGES);
      uiContext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.messages = merged;
      });
      this.lastSync = formatClock();
      this.lastRefreshFailed = false;
      setTimeout(() => {
        fresh.forEach((message: Message) => {
          message.unread = false;
        });
      }, UNREAD_TIMEOUT_MS);
      return fresh.length;
    } catch (error) {
      this.lastRefreshFailed = true;
      return 0;
    }
  }

  async loadMore(): Promise<void> {
    if (this.isLoadingMore) {
      return;
    }
    this.isLoadingMore = true;
    try {
      const older: Message[] = await this.repository.fetchOlder();
      this.messages = this.messages.concat(older).slice(0, MAX_MESSAGES);
    } finally {
      this.isLoadingMore = false;
    }
  }

  updateStatus(status: RefreshStatus): void {
    this.refreshStatus = status;
  }
}