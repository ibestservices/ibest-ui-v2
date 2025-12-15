import { IBestBorderSizeType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestIcon } from '../icon'
import { IBestPopoverColor } from './color'
import { IBestPopoverAction, IBestPopoverController, PopoverMask } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestPopover{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 选项列表
     */
    @Param actions: IBestPopoverAction[] = []
    /**
     * 选项文字大小
     */
    @Param textFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 文字颜色
     */
    @Param textColor: ResourceColor = IBestPopoverColor.textColor
    /**
     * 选项高度
     */
    @Param itemHeight: IBestStringNumber = convertDimensionsWidthUnit(44)
    /**
     * 选项内边距
     */
    @Param itemPadding: IBestStringNumber = this.baseStyle.spaceMd as string
    /**
     * 文字对齐方式
     */
    @Param textAlign?: TextAlign = undefined
    /**
     * 图标大小
     */
    @Param iconSize: IBestStringNumber = convertDimensionsWidthUnit(20)
    /**
     * 图标颜色
     */
    @Param iconColor: ResourceColor = IBestPopoverColor.textColor
    /**
     * 分割线颜色
     */
    @Param dividerColor: ResourceColor = IBestPopoverColor.borderColor
    /**
     * 弹出位置
     */
    @Param placement: Placement = Placement.Bottom
    /**
     * 气泡框宽度
     */
    @Param popoverWidth: IBestStringNumber = ""
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = IBestPopoverColor.bgColor
    /**
     * 是否显示箭头
     */
    @Param showArrow: boolean = true
    /**
     * 箭头宽度
     */
    @Param arrowWidth: IBestStringNumber = convertDimensionsWidthUnit(12)
    /**
     * 箭头高度
     */
    @Param arrowHeight: IBestStringNumber = convertDimensionsWidthUnit(6)
    /**
     * 是否显示遮罩
     */
    @Param popoverMask: boolean | PopoverMask = true
    /**
     * 气泡与目标的间隙
     */
    @Param space: IBestStringNumber = convertDimensionsWidthUnit(4)
    /**
     * 气泡圆角
     */
    @Param radius: IBestStringNumber = convertDimensionsWidthUnit(8)
    /**
     * 气泡阴影
     */
    @Param popoverShadow: ShadowOptions | ShadowStyle = ShadowStyle.OUTER_DEFAULT_MD
    /**
     * 底部分割线尺寸类型
     */
    @Param borderSizeType: IBestBorderSizeType = "center"
    /**
     * 固定高度
     */
    @Param fixHeight: IBestStringNumber = "auto"
    /**
     * 最大高度
     */
    @Param maxHeight: IBestStringNumber = "auto"
    /**
     * 滚动条状态
     */
    @Param scrollBarState: BarState = BarState.Auto
    /**
     * 气泡框实例
     */
    @Param controller: IBestPopoverController = new IBestPopoverController()
    /**
     * 默认内容
     */
    @BuilderParam triggerBuilder: CustomBuilder
    /**
     * 自定义popover内容
     */
    @BuilderParam popoverContentBuilder: CustomBuilder
    /**
     * 点击选项是触发
     */
    @Event onSelect: (action: IBestPopoverAction, index: number) => void = () => {}
    /**
     * 打开时触发
     */
    @Event onOpen: () => void = () => {}

    @Local isShow: boolean = false

    @Builder popoverContent(){
        if(this.popoverContentBuilder){
            this.popoverContentBuilder()
        }else {
            Scroll(){
                Column(){
                    ForEach(this.actions, (item: IBestPopoverAction, index: number) => {
                        Row(){
                            Row({space: this.baseStyle.spaceXs}){
                                if(item.icon){
                                    IBestIcon({
                                        name: item.icon,
                                        iconSize: this.iconSize,
                                        color: this.iconColor
                                    })
                                }
                                Text(item.text)
                                    .layoutWeight(this.popoverWidth ? 1 : 0)
                                    .height(getSizeByUnit(this.itemHeight))
                                    .fontSize(getSizeByUnit(this.textFontSize, true))
                                    .fontColor(item.color || this.textColor)
                                    .border({width:{top: this.borderSizeType == 'right' && index > 0 ? 1 : 0}, color: this.dividerColor})
                                    .textAlign(this.getTextAlign(item))
                                    .maxLines(1)
                                    .textOverflow({overflow: TextOverflow.Ellipsis})
                            }
                            .border({width:{top: this.borderSizeType == 'center' && index > 0 ? 1 : 0}, color: this.dividerColor})
                        }
                        .border({width: {top: this.borderSizeType == 'full' && index > 0 ? 1 : 0}, color: this.dividerColor})
                        .padding({left: getSizeByUnit(this.itemPadding), right: getSizeByUnit(this.itemPadding)})
                        .stateStyles({
                            pressed: {
                                .backgroundColor(IBestPopoverColor.activeBg)
                            },
                            normal: {
                                .backgroundColor(this.bgColor)
                            }
                        })
                        .enabled(!item.disabled)
                        .opacity(item.disabled ? 0.5 : 1)
                        .onClick(() => {
                            this.onSelect(item, index)
                            this.isShow = false
                        })
                    })
                }
            }
            .scrollBar(this.scrollBarState)
            .height(getSizeByUnit(this.fixHeight))
            .constraintSize({maxHeight: getSizeByUnit(this.maxHeight)})
        }
    }

    aboutToAppear(): void {
        this.controller.open = (): void => this.open()
        this.controller.close = (): void => this.close()
    }
    open(): void {
        this.isShow = true
    }
    close(): void {
        this.isShow = false
    }
    getTextAlign(item: IBestPopoverAction){
        return this.textAlign || (item.icon ? TextAlign.Start : TextAlign.Center)
    }

    build() {
        Column(){
            if(this.triggerBuilder){
                this.triggerBuilder()
            }
        }
        .parallelGesture(
            TapGesture({fingers: 1})
                .onAction(() => {
                    this.isShow = !this.isShow
                })
        )
        .bindPopup(this.isShow!!, {
            builder: (): void => this.popoverContent(),
            width: getSizeByUnit(this.popoverWidth) as Dimension,
            popupColor: this.bgColor,
            placement: this.placement,
            backgroundBlurStyle: BlurStyle.NONE,
            shadow: this.popoverShadow,
            enableArrow: this.showArrow,
            arrowWidth: getSizeByUnit(this.arrowWidth) as Dimension,
            arrowHeight: getSizeByUnit(this.arrowHeight) as Dimension,
            mask: this.popoverMask,
            targetSpace: this.space,
            radius: getSizeByUnit(this.radius) as Dimension,
            onWillDismiss: (): void => this.close(),
            onStateChange: event => {
                if(event.isVisible){
                    this.onOpen()
                }
            }
        })
    }
}