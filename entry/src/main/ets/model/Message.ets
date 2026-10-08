@ObservedV2
export class Message {
  id: string = '';
  sender: string = '';
  preview: string = '';
  timestamp: number = 0;
  @Trace unread: boolean = false;

  constructor(id: string, sender: string, preview: string, timestamp: number, unread: boolean) {
    this.id = id;
    this.sender = sender;
    this.preview = preview;
    this.timestamp = timestamp;
    this.unread = unread;
  }
}