import { IBestShape, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit } from '../../utils/utils'
import { IBestAvatar } from '../avatar'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestAvatarGroup{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 头像列表
     */
    @Param urls: (PixelMap | ResourceStr | DrawableDescriptor)[] = []
    /**
     * 最多展示数量
     */
    @Param max: number = 5
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
    @Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = convertDimensionsWidthUnit(4)
    /**
     * 头像之间遮挡比例（0.5 代表遮挡 50%）
     */
    @Param gap: number = 0.5
    /**
     * 超出max时是否显示更多提示
     */
    @Param showMore: boolean = true
    /**
     * 更多文案，仅当showMore为true时生效，当头像列表小于max时，也可设置moreText强制显示更多
     * @default +n，n为超出max数量
     */
    @Param moreText: ResourceStr = ''
    /**
     * 更多文字大小
     */
    @Param moreTextSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 头像组更多点击
     */
    @Event onMoreClick: () => void = () => {}

    @Local avatarWidth: number = 0
    private uiContext = this.getUIContext()

    getWidth(){
        setTimeout(() => {
            this.avatarWidth = getComponentsInfo(this.uiContext, "ibest_avatar_0").width
        }, 50)
    }
    getShowUrls(){
        return this.urls.slice(0, this.max)
    }

    build() {
        Row(){
            ForEach(this.getShowUrls(), (item: PixelMap | ResourceStr | DrawableDescriptor, index: number) => {
                Row(){
                    IBestAvatar({
                        src: item,
                        avatarSize: this.avatarSize,
                        shape: this.shape,
                        radius: this.radius,
                    }).id(`ibest_avatar_${index}`)
                    if(this.showMore && index == this.getShowUrls().length - 1 && (this.urls.length > this.max || this.moreText)){
                        Row(){
                            Text(this.moreText || `+${this.urls.length - this.max}`)
                                .fontColor(this.baseStyle.default)
                                .fontSize(getSizeByUnit(this.moreTextSize))
                        }
                        .width(CONTAINER_SIZE.FULL)
                        .height(CONTAINER_SIZE.FULL)
                        .position({left: 0, top: 0})
                        .backgroundColor("rgba(0, 0, 0, 0.3)")
                        .justifyContent(FlexAlign.Center)
                        .onClick(() => {
                            this.onMoreClick()
                        })
                    }
                }
                .width(getSizeByUnit(this.avatarSize))
                .aspectRatio(1)
                .borderRadius(this.shape === 'circle' ? this.baseStyle.borderRadiusMax : this.radius)
                .clip(true)
                .margin({left: index === 0 ? 0 : -(this.avatarWidth * this.gap)})
            })
        }
        .onAppear(() => {
            setTimeout(() => {
                this.getWidth()
            }, 10)
        })
        .onVisibleAreaChange([0,1], (isExpanding: boolean) => {
            if(isExpanding && !this.avatarWidth){
                this.getWidth()
            }
        })
    }
}