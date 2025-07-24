import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { CONTAINER_SIZE } from '../../theme-chalk/src/container';
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';
import GlobalStore from '../../utils/GlobalStore';
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils';
import { IBestButton } from '../button';
import { IBestGuideColor } from './color';
import { GuideRect, IBestGuideController, IBestGuideItemType } from './index.type';
import { AppStorageV2, window } from '@kit.ArkUI';

@ComponentV2
export struct IBestGuide {
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 引导路径数据
     */
    @Param @Require data: IBestGuideItemType[]
    /**
     * 严格模式,当引导的元素不在屏幕内时抛出异常
     */
    @Param strictMode: boolean = true
    /**
     * 气泡框宽度
     */
    @Param popupWidth: IBestStringNumber = convertDimensionsWidthUnit(300)
    /**
     * 气泡框高度
     */
    @Param popupHeight: IBestStringNumber = "auto"
    /**
     * 气泡框最大高度
     */
    @Param popupMaxHeight: IBestStringNumber = "auto"
    /**
     * 气泡框背景色
     */
    @Param bgColor: ResourceColor = IBestGuideColor.bgColor
    /**
     * 气泡框的圆角半径
     */
    @Param popupCornerRadius: IBestStringNumber = convertDimensionsWidthUnit(8)
    /**
     * 按钮间距
     */
    @Param buttonSpace: IBestStringNumber = this.baseStyle.spaceMd as string
    /**
     * 内容区域的行高 lineHeight
     */
    @Param messageLineHeight: IBestStringNumber = this.baseStyle.lineHeightMd as string
    /**
     * 内容区域的fontSize
     */
    @Param messageFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 内容区域的颜色
     */
    @Param messageFontColor: ResourceColor = IBestGuideColor.fontColor
    /**
     * 上一步按钮文字
     */
    @Param previousText: ResourceStr = $r('app.string.ibest_guide_previous')
    /**
     * 下一步按钮文字
     */
    @Param nextText: ResourceStr = $r('app.string.ibest_guide_next')
    /**
     * 结束按钮文字
     */
    @Param completeText: ResourceStr = $r('app.string.ibest_guide_complete')
    /**
     * 默认插槽
     */
    @BuilderParam defaultBuilder: CustomBuilder
    /**
     * 引导控制器
     */
    @Param @Require controller: IBestGuideController

    @Local guideContentBuilder: WrappedBuilder<[sort: number, total: number, ctl: IBestGuideController]> | null = null
    @Local guideAreaWidth: number = 0
    @Local guideAreaHeight: number = 0
    @Local guideAreaTop: number = 0
    @Local guideAreaBottom: number = 0
    @Local guideAreaLeft: number = 0
    @Local guideAreaRight: number = 0
    @Local isLayoutFullScreen: boolean = GlobalStore.getMainWindow().getWindowProperties().isLayoutFullScreen
    @Local avoidTopRectHeight: number = 0
    @Local avoidNavRectHeight: number = 0
	private uiContext = this.getUIContext()

    @Builder popupBuilder() {
        if (this.guideContentBuilder) {
            this.guideContentBuilder.builder(this.controller.__cache.__currentSort,
                this.controller.__cache.__guideTotal, this.controller)
        } else {
            Scroll() {
                Column({ space: this.baseStyle.spaceSm as string }) {
                    Text(this.controller.__cache.__guideItemValue)
                        .width(CONTAINER_SIZE.FULL)
                        .textAlign(TextAlign.Start)
                        .lineHeight(getSizeByUnit(this.messageLineHeight))
                        .fontSize(getSizeByUnit(this.messageFontSize, true))
                        .fontColor(this.messageFontColor)
                    Row() {
                        Text(this.controller.__cache.__currentSort.toString() + " / " + this.controller.__cache.__guideTotal.toString())
                            .letterSpacing(this.baseStyle.spaceMini as string)
                            .fontSize(this.baseStyle.fontSizeMd)
                        Row({ space: getSizeByUnit(this.buttonSpace) }) {
                            IBestButton({
                                text: this.previousText,
                                type: 'default',
                                buttonSize: 'small',
                                fontWeight: FontWeight.Medium,
                                onBtnClick: () => {
                                    if (!this.controller.__cache.__guideItemIsFirst) {
                                        this.controller.prev()
                                    }
                                },
                                disabled: this.controller.__cache.__guideItemIsFirst
                            }).visibility(this.controller.__cache.__guideTotal == 1 ? Visibility.Hidden : Visibility.Visible)
                            IBestButton({
                                text: this.controller.__cache.__guideItemIsLast ? this.completeText : this.nextText,
                                type: 'primary',
                                buttonSize: 'small',
                                fontWeight: FontWeight.Medium,
                                onBtnClick: () => {
                                    if (!this.controller.__cache.__guideItemIsLast) {
                                        this.controller.next()
                                    } else {
                                        this.controller.close()
                                    }
                                }
                            })
                        }
                    }
                    .width(CONTAINER_SIZE.FULL)
                    .justifyContent(FlexAlign.SpaceBetween)
                }
                .padding(this.baseStyle.spaceMd)
            }
            .scrollBar(BarState.Auto)
            .height(getSizeByUnit(this.popupHeight))
            .constraintSize({ maxHeight: getSizeByUnit(this.popupMaxHeight) })
        }
    }

    aboutToAppear(): void {
        this.controller.context = this.getUIContext()
        if(this.data){
            this.dataChange()
        }
        this.strictModeChange()
        this.controller.__cache.__guideContentBuilderEvent = (builder: WrappedBuilder<[sort: number, total: number, ctl: IBestGuideController]> | null) => {
            this.guideContentBuilder = builder
        }
        this.controller.__cache.__guideAreaChangeEvent = (rect: GuideRect) => {
            this.guideAreaWidth = rect.getWidth()
            this.guideAreaHeight = rect.getHeight()
            this.guideAreaTop = rect.top
            this.guideAreaBottom = rect.bottom
            this.guideAreaLeft = rect.left
            this.guideAreaRight = rect.right
            this.isLayoutFullScreen = GlobalStore.getMainWindow().getWindowProperties().isLayoutFullScreen
            this.avoidTopRectHeight = this.uiContext.px2vp(GlobalStore.getMainWindow()
                .getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
                .topRect
                .height)
            this.avoidNavRectHeight = this.uiContext.px2vp(GlobalStore.getMainWindow()
                .getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
                .bottomRect
                .height)
        }
    }
    @Monitor("data", "data.length")
    dataChange() {
        this.controller.__cache.__data = this.data
    }
    @Monitor("strictMode")
    strictModeChange(){
        this.controller.__cache.__strictMode = this.strictMode
    }

    build() {
        Column() {
            Stack() {
                Column() {
                    if (this.defaultBuilder) {
                        this.defaultBuilder()
                    }
                }
                .zIndex(1)
                Column() {
                    Column()
                        .width(CONTAINER_SIZE.FULL)
                        .height(this.avoidTopRectHeight)
                        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.START])
                        .backgroundColor(this.controller.__cache.__styleParam.maskColor as string)
                    Blank().width(CONTAINER_SIZE.FULL).layoutWeight(1)
                        .borderWidth({
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0.5
                        })
                        .borderColor(this.controller.__cache.__styleParam.maskColor as string)
                    Column()
                        .width(CONTAINER_SIZE.FULL)
                        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.END])
                        .backgroundColor(this.controller.__cache.__styleParam.maskColor as string)
                }
                .width(CONTAINER_SIZE.FULL)
                .height(CONTAINER_SIZE.FULL)
                .visibility((this.controller.__cache.__isShowGuide && !this.isLayoutFullScreen) ? Visibility.Visible : Visibility.None)
                .zIndex(this.controller.__cache.__isShowGuide ? 100 : 0)
                Stack({ alignContent: Alignment.TopStart }) {
                    Canvas(this.controller.__cache.__context).width(CONTAINER_SIZE.FULL).height(CONTAINER_SIZE.FULL)
                    Row()
                        .width(this.guideAreaWidth)
                        .height(this.guideAreaHeight)
                        .backgroundColor(Color.Transparent)
                        .position({
                            left: this.guideAreaLeft,
                            right: this.guideAreaRight,
                            top: this.guideAreaTop,
                            bottom: this.guideAreaBottom
                        })
                        .bindPopup(this.controller.__cache.__isShowGuide, {
                            builder: this.popupBuilder,
                            width: getSizeByUnit(this.popupWidth) as Dimension,
                            placement: this.controller.__cache.__guidePlacement,
                            popupColor: this.bgColor,
                            backgroundBlurStyle: BlurStyle.NONE,
                            shadow: ShadowStyle.OUTER_DEFAULT_MD,
                            showInSubWindow: false,
                            autoCancel: false,
                            radius: getSizeByUnit(this.popupCornerRadius) as Dimension,
                            onWillDismiss: false,
                            transition: TransitionEffect.asymmetric(
                                TransitionEffect.opacity(0).animation({ duration: 20, delay: 50 }),
                                TransitionEffect.IDENTITY
                            )
                        })
                }
                .visibility(this.controller.__cache.__isShowGuide ? Visibility.Visible : Visibility.None)
                .zIndex(this.controller.__cache.__isShowGuide ? 99 : 0)
            }
            .width(CONTAINER_SIZE.FULL)
        }
        .width(CONTAINER_SIZE.FULL)
    }
}