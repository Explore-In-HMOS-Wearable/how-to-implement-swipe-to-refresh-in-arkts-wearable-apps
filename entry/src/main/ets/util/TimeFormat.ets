export function formatRelativeTime(timestamp: number): string {
  const minutes: number = Math.floor((Date.now() - timestamp) / 60000);
  if (minutes < 1) {
    return 'now';
  }
  if (minutes < 60) {
    return `${minutes}m`;
  }
  const hours: number = Math.floor(minutes / 60);
  if (hours < 24) {
    return `${hours}h`;
  }
  return `${Math.floor(hours / 24)}d`;
}

export function formatClock(date: Date = new Date()): string {
  const hours: string = date.getHours().toString().padStart(2, '0');
  const minutes: string = date.getMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
}