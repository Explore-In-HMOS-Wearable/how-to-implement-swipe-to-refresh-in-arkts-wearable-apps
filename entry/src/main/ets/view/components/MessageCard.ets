import { Message } from '../../model/Message';
import { formatRelativeTime } from '../../util/TimeFormat';

function avatarColor(name: string): Resource {
  let sum: number = 0;
  for (let i = 0; i < name.length; i++) {
    sum += name.charCodeAt(i);
  }
  switch (sum % 5) {
    case 0: return $r('app.color.avatar_1');
    case 1: return $r('app.color.avatar_2');
    case 2: return $r('app.color.avatar_3');
    case 3: return $r('app.color.avatar_4');
    default: return $r('app.color.avatar_5');
  }
}

function initial(name: string): string {
  return name.length > 0 ? name.substring(0, 1).toUpperCase() : '?';
}

@ComponentV2
export struct MessageCard {
  @Param message: Message = new Message('', '', '', 0, false);

  build() {
    Row() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Text(initial(this.message.sender))
          .width(30)
          .height(30)
          .borderRadius(15)
          .backgroundColor(avatarColor(this.message.sender))
          .fontColor($r('app.color.text_primary'))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
        if (this.message.unread) {
          Circle()
            .width(10)
            .height(10)
            .fill($r('app.color.accent'))
            .stroke($r('app.color.card'))
            .strokeWidth(2)
        }
      }
      .width(30)
      .height(30)

      Column() {
        Row() {
          Text(this.message.sender)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Text(formatRelativeTime(this.message.timestamp))
            .fontSize(13)
            .fontColor($r('app.color.muted'))
            .margin({ left: 8 })
        }
        .width('100%')

        Text(this.message.preview)
          .fontSize(15)
          .fontColor($r('app.color.text_secondary'))
          .lineHeight(20)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('app.color.card'))
  }
}