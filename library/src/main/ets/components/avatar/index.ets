import { IBestShape, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit, random } from '../../utils/utils'
import { IBestBadgePosition } from '../badge/index.type'
import { IBestIcon } from '../icon'
import { IBestAvatarColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestGlobalConfig } from '../../model/GlobalConfig'
import { IBestBadge } from '../badge'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'

@ComponentV2
export struct IBestAvatar{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Local config: IBestGlobalConfig = AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG)!
    /**
     * 头像地址
     */
    @Param src: PixelMap | ResourceStr | DrawableDescriptor = ''
    /**
     * 头像形状
     */
    @Param shape: IBestShape = 'circle'
    /**
     * 头像大小
     */
    @Param avatarSize: IBestStringNumber = convertDimensionsWidthUnit(40)
    /**
     * 头像裁剪类型
     */
    @Param objectFit: ImageFit = ImageFit.Cover
    /**
     * 圆角值
     */
    @Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = this.baseStyle.borderRadiusMd
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = IBestAvatarColor.bgColor
    /**
     * 文字替代图片, 优先级高于src
     */
    @Param text: ResourceStr = ''
    /**
     * 显示的图标, 优先级大于text
     */
    @Param icon: ResourceStr = ''
    /**
     * 图标、文字颜色
     */
    @Param iconColor: ResourceColor = this.baseStyle.default
    /**
     * 图标、文字大小
     */
    @Param iconFontSize: IBestStringNumber = convertDimensionsWidthUnit(18)
    /**
     * 随机背景色
     */
    @Param randomBgColor: boolean = false
    /**
     * 默认头像
     */
    @Param defaultAvatar: ResourceStr = this.config.avatar?.defaultAvatar || $r("app.media.ibest_default_avatar")
    /**
     * 徽标内容
     */
    @Param badgeContent: IBestStringNumber = ''
    /**
     * 徽标背景色
     */
    @Param badgeColor: ResourceColor = ''
    /**
     * 是否展示为小红点
     */
    @Param dot: boolean = false
    /**
     * 最大值,超过最大值会显示 {max}+,仅当 content 为数字时有效
     */
    @Param max: number = -1
    /**
     * 值为0时是否显示徽标
     */
    @Param showZero: boolean = true
    /**
     * 徽标位置
     */
    @Param badgePosition: IBestBadgePosition = 'top-right'
    /**
     * 徽标图标, 优先级高于 content dot
     */
    @Param badgeIcon: ResourceStr = ''
    /**
     * 徽标图标大小
     */
    @Param badgeIconSize: IBestStringNumber = this.baseStyle.fontSizeSm as string
    /**
     * 徽标图标颜色
     */
    @Param badgeIconColor: ResourceColor = ''
    /**
     * 徽标水平方向偏移量
     * @since 1.1.2
     */
    @Param xOffset: Dimension = 0
    /**
     * 徽标垂直方向偏移量
     * @since 1.1.2
     */
    @Param yOffset: Dimension = 0
    /**
     * 头像点击事件
     */
    @Event onAvatarClick: () => void = () => {}

    @Local isError: boolean = false
    private colors: string[] = ['#ffb34b', '#f2bba9', '#f7a196', '#f18080', '#88a867', '#bfbf39', '#89c152', '#94d554', '#f19ec2',
        '#afaae4', '#e1b0df', '#c38cc1', '#72dcdc', '#9acdcb', '#77b1cc', '#448aca', '#86cefa', '#98d1ee', '#73d1f1', '#80a7dc'
    ]
    @Monitor("src")
    srcChange(){
        this.isError = !this.src
    }
    getBgColor(){
        return (this.text || this.icon) ? this.randomBgColor ? this.colors[random(0, 19)] : this.bgColor : ''
    }

    build() {
        IBestBadge({
            content: this.badgeContent,
            color: this.badgeColor,
            dot: this.dot,
            max: this.max,
            showZero: this.showZero,
            badgePosition: this.badgePosition,
            icon: this.badgeIcon,
            iconSize: this.badgeIconSize,
            iconColor: this.badgeIconColor,
            xOffset: this.xOffset,
            yOffset: this.yOffset
        }){
            Row(){
                if(this.icon){
                    IBestIcon({
                        name: this.icon,
                        color: this.iconColor,
                        iconSize: this.iconFontSize
                    })
                }else if(this.text){
                    Text(this.text)
                        .fontColor(this.iconColor)
                        .fontSize(getSizeByUnit(this.iconFontSize, true))
                }else {
                    Image(this.isError ? this.defaultAvatar : this.src)
                        .width(CONTAINER_SIZE.FULL)
                        .height(CONTAINER_SIZE.FULL)
                        .onError(() => {
                            this.isError = true
                        })
                }
            }
            .width(getSizeByUnit(this.avatarSize))
            .aspectRatio(1)
            .borderRadius(this.shape === 'circle' ? this.baseStyle.borderRadiusMax : this.radius)
            .backgroundColor(this.getBgColor())
            .justifyContent(FlexAlign.Center)
            .clip(true)
            .onClick(() => {
                this.onAvatarClick()
            })
        }
    }
}
