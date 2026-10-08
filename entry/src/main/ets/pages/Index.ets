import {
  ArcList,
  ArcListItem,
  ArcListAttribute,
  ArcListItemAttribute,
  ComponentContent,
  LengthMetrics
} from '@kit.ArkUI';
import { Message } from '../model/Message';
import { MessageListViewModel } from '../viewmodel/MessageListViewModel';
import { MessageCard } from '../view/components/MessageCard';

const REFRESH_OFFSET_VP: number = 40;
const NEW_BADGE_DURATION_MS: number = 1600;
const FAILURE_HOLD_MS: number = 1400;
const SKELETON_ROWS: number[] = [0, 1, 2, 3, 4];

class RefreshIndicatorParams {
  refreshing: boolean = false;
  status: RefreshStatus = RefreshStatus.Inactive;
  failed: boolean = false;
}

@Builder
function refreshingContent(params: RefreshIndicatorParams) {
  Row() {
    if (params.failed) {
      Column() {
        Text($r('app.string.indicator_cant_refresh'))
          .fontSize(13)
          .fontColor($r('app.color.warning'))
        Text($r('app.string.indicator_pull_to_retry'))
          .fontSize(12)
          .fontColor($r('app.color.warning'))
      }
      .alignItems(HorizontalAlign.Center)
    } else if (params.refreshing) {
      LoadingProgress()
        .width(22)
        .height(22)
        .color($r('app.color.accent'))
      Text($r('app.string.indicator_refreshing'))
        .fontSize(13)
        .fontColor($r('app.color.accent'))
        .margin({ left: 8 })
    } else if (params.status === RefreshStatus.OverDrag) {
      Text($r('app.string.indicator_release'))
        .fontSize(13)
        .fontColor($r('app.color.muted'))
    } else if (params.status === RefreshStatus.Drag) {
      Text($r('app.string.indicator_pull'))
        .fontSize(13)
        .fontColor($r('app.color.muted'))
    }
  }
  .padding({ top: 20 })
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
  .width('100%')
  .constraintSize({ minHeight: 24 })
}

class HeaderParams {
  label: string = '';
  accent: boolean = false;
}

@Builder
function headerContent(params: HeaderParams) {
  Column() {
    Text(params.label)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(params.accent ? $r('app.color.accent') : $r('app.color.muted'))
      .textAlign(TextAlign.Center)
      .width('100%')
  }
  .width('100%')
  .padding({ top: 8, bottom: 6 })
}

@Entry
@ComponentV2
struct Index {
  @Local viewModel: MessageListViewModel = new MessageListViewModel();
  @Local refreshing: boolean = false;
  @Local skeletonPulse: number = 1;
  private indicatorParams: RefreshIndicatorParams = new RefreshIndicatorParams();
  private indicatorNode?: ComponentContent<Object> = undefined;
  private headerParams: HeaderParams = new HeaderParams();
  private headerNode?: ComponentContent<Object> = undefined;

  aboutToAppear(): void {
    const context = this.getUIContext();
    this.indicatorNode = new ComponentContent(
      context, wrapBuilder(refreshingContent), this.indicatorParams
    );
    this.headerNode = new ComponentContent(
      context, wrapBuilder(headerContent), this.headerParams
    );
    setTimeout(() => {
      this.skeletonPulse = 0.4;
    }, 32);
    this.viewModel.loadInitial().then(() => {
      this.syncHeader();
    });
  }

  private text(resource: Resource, ...args: (string | number)[]): string {
    return this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id, ...args);
  }

  private updateIndicator(refreshing: boolean, failed: boolean): void {
    this.indicatorParams.refreshing = refreshing;
    this.indicatorParams.status = this.viewModel.refreshStatus;
    this.indicatorParams.failed = failed;
    this.indicatorNode?.update(this.indicatorParams);
  }

  private currentHeaderLabel(): string {
    if (this.refreshing) {
      return this.text($r('app.string.header_updating'));
    }
    if (this.viewModel.lastRefreshFailed) {
      return this.text($r('app.string.header_update_failed'));
    }
    return this.text($r('app.string.header_updated_at'), this.viewModel.lastSync);
  }

  private syncHeader(): void {
    this.headerParams.label = this.currentHeaderLabel();
    this.headerParams.accent = false;
    this.headerNode?.update(this.headerParams);
  }

  private showNewBadge(count: number): void {
    this.headerParams.label = this.text($r('app.string.header_new_count'), count);
    this.headerParams.accent = true;
    this.headerNode?.update(this.headerParams);
    setTimeout(() => {
      this.syncHeader();
    }, NEW_BADGE_DURATION_MS);
  }

  @Builder
  skeletonCard() {
    Row() {
      Circle()
        .width(30)
        .height(30)
        .fill($r('app.color.skeleton'))
      Column({ space: 6 }) {
        Row().width('55%').height(12).borderRadius(6).backgroundColor($r('app.color.skeleton'))
        Row().width('90%').height(10).borderRadius(5).backgroundColor($r('app.color.skeleton'))
        Row().width('70%').height(10).borderRadius(5).backgroundColor($r('app.color.skeleton'))
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
    .opacity(this.skeletonPulse)
    .animation({
      duration: 700,
      curve: Curve.EaseInOut,
      iterations: -1,
      playMode: PlayMode.Alternate
    })
  }

  @Builder
  skeletonList() {
    Column({ space: 8 }) {
      ForEach(SKELETON_ROWS, (row: number) => {
        this.skeletonCard()
      }, (row: number) => row.toString())
    }
    .width('100%')
    .padding({ left: '10%', right: '10%', top: '20%' })
  }

  @Builder
  loadMoreFooter() {
    Row() {
      LoadingProgress()
        .width(18)
        .height(18)
        .color($r('app.color.muted'))
      Text($r('app.string.footer_loading_older'))
        .fontSize(12)
        .fontColor($r('app.color.muted'))
        .margin({ left: 8 })
    }
    .width('100%')
    .height(36)
    .justifyContent(FlexAlign.Center)
    .visibility(this.viewModel.isLoadingMore ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  messageList() {
    Refresh({ refreshing: $$this.refreshing, refreshingContent: this.indicatorNode }) {
      ArcList({ initialIndex: 0, header: this.headerNode }) {
        ForEach(this.viewModel.messages, (message: Message) => {
          ArcListItem() {
            MessageCard({ message: message })
          }
          .width('80%')
          .transition(
            TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -16 })),
              TransitionEffect.OPACITY
            )
          )
        }, (message: Message) => message.id)

        ArcListItem() {
          this.loadMoreFooter()
        }
      }
      .width('100%')
      .height('100%')
      .space(LengthMetrics.vp(8))
      .scrollBar(BarState.Off)
      .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
      .fadingEdge(true)
      .cachedCount(4)
      .onScrollIndex((start: number, end: number, center: number) => {
        if (end >= this.viewModel.messages.length - 1) {
          this.viewModel.loadMore();
        }
      })
    }
    .refreshOffset(REFRESH_OFFSET_VP)
    .pullToRefresh(true)
    .onStateChange((status: RefreshStatus) => {
      this.viewModel.updateStatus(status);
      this.updateIndicator(this.refreshing, false);
    })
    .onRefreshing(() => {
      this.updateIndicator(true, false);
      this.syncHeader();
      this.viewModel.refresh(this.getUIContext())
        .then((added: number) => {
          if (this.viewModel.lastRefreshFailed) {
            this.updateIndicator(false, true);
            this.headerParams.label = this.text($r('app.string.header_update_failed'));
            this.headerParams.accent = false;
            this.headerNode?.update(this.headerParams);
            setTimeout(() => {
              this.refreshing = false;
              this.updateIndicator(false, false);
              this.syncHeader();
            }, FAILURE_HOLD_MS);
          } else {
            this.refreshing = false;
            this.updateIndicator(false, false);
            if (added > 0) {
              this.showNewBadge(added);
            } else {
              this.syncHeader();
            }
          }
        });
    })
    .layoutWeight(1)
    .width('100%')
  }

  build() {
    Column() {
      if (this.viewModel.isInitialLoading) {
        this.skeletonList()
      } else {
        this.messageList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}