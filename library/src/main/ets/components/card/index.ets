import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { getSizeByUnit } from '../../utils/utils'
import { IBestCell } from '../cell'
import { IBestCardColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestCard{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 标题文字
     */
    @Param title: ResourceStr = ''
    /**
     * 标题文字大小
     */
    @Param titleFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
    /**
     * 标题文字颜色
     */
    @Param titleFontColor: ResourceColor = IBestCardColor.titleFontColor
    /**
     * 标题内边距
     */
    @Param titlePadding: Length | Padding | LocalizedPadding = {
        left: this.baseStyle.spaceSm,
        right: this.baseStyle.spaceSm,
        top: this.baseStyle.spaceXsm,
        bottom: this.baseStyle.spaceXsm
    }
    /**
     * 标题是否可点击
     */
    @Param titleClickable: boolean = false
    /**
     * 圆角
     */
    @Param radius: IBestStringNumber = this.baseStyle.borderRadiusLg as string
    /**
     * 内容内边距
     */
    @Param contentPadding: Length | Padding | LocalizedPadding = this.baseStyle.spaceSm as string
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = IBestCardColor.bgColor
    /**
     * 背景图片
     */
    @Param bgImage: ResourceStr = ''
    /**
     * 阴影半径
     */
    @Param shadowRadius: number | Resource = 12
    /**
     * 阴影颜色
     */
    @Param shadowColor: ResourceColor = IBestCardColor.shadowColor
    /**
     * 左侧图标
     * @since 2.2.6
     */
    @Param leftIcon: ResourceStr = ''
    /**
     * 左侧图标颜色
     * @since 2.2.6
     */
    @Param leftIconColor: ResourceColor = ''
    /**
     * 左侧图标大小
     * @since 2.2.6
     */
    @Param leftIconSize: IBestStringNumber = ''
    /**
     * 右侧内容
     * @since 2.2.6
     */
    @Param value: ResourceStr = ''
    /**
     * 内容的文字颜色
     * @since 2.2.6
     */
    @Param valueColor: ResourceColor = ''
    /**
     * 内容的文字大小
     * @since 2.2.6
     */
    @Param valueFontSize: IBestStringNumber = ''
    /**
     * 标题点击事件, titleClickable为true时生效
     */
    @Event onTitleClick: () => void = () => {}

    @BuilderParam defaultBuilder: CustomBuilder

    private uiContext = this.getUIContext()

    getShadowRadius(){
        if(typeof this.shadowRadius == 'object'){
            return this.uiContext.getHostContext()!.resourceManager.getNumber(this.shadowRadius.id)
        }
        return this.shadowRadius
    }

    build() {
        Column(){
            if(this.title){
                IBestCell({
                    title: this.title,
                    titleColor: this.titleFontColor,
                    titleFontSize: this.titleFontSize,
                    cellPadding: this.titlePadding,
                    leftIcon: this.leftIcon,
                    leftIconColor: this.leftIconColor,
                    leftIconSize: this.leftIconSize,
                    value: this.value,
                    valueColor: this.valueColor,
                    valueFontSize: this.valueFontSize,
                    isLink: this.titleClickable,
                    borderSizeType: "full",
                    onCellClick: () => {
                        this.onTitleClick()
                    }
                })
            }
            Column(){
                if(this.defaultBuilder){
                    this.defaultBuilder()
                }
            }
            .width(CONTAINER_SIZE.FULL)
            .padding(getSizeByUnit(this.contentPadding))
            .alignItems(HorizontalAlign.Start)
        }
        .width(`calc(100% - ${this.getShadowRadius()}vp)`)
        .backgroundColor(this.bgColor)
        .backgroundImage(this.bgImage)
        .backgroundImageSize(ImageSize.FILL)
        .borderRadius(getSizeByUnit(this.radius))
        .margin(this.getShadowRadius() / 2)
        .clip(true)
        .shadow({
            radius: this.uiContext.vp2px(this.getShadowRadius()),
            color: this.shadowColor
        })
    }
}
