import { IBestBaseDataType, IBestStorageKey } from "../../model/Global.type"
import { applyMosaicToImage } from "./util"
import { AppStorageV2 } from "@kit.ArkUI"
import { IBestMosaicColor } from "./color"

@ComponentV2
export struct IBestMosaic {
    @Local colorMode: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.COLOR_MODE)!
    /**
     * 是否展示马赛克
     */
    @Param showMosaic: boolean = true
    /**
     * 延迟时长，单位ms，若在使用中马赛克无法正常显示，可设置更长的延迟时长
     */
    @Param delay: number = 300
    /**
     * 马赛克块大小
     */
    @Param blockSize: number = 16
    /**
     * 是否同步展示马赛克，即马赛克与内容同步展示
     */
    @Param syncShow: boolean = true
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = IBestMosaicColor.bgColor
    /**
     * 圆角，当内容部分含有圆角时，请设置该属性
     */
    @Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
    /**
     * 默认插槽
     */
    @BuilderParam defaultBuilder: CustomBuilder

    @Local isReady: boolean = false
    @Local mskPixelMap: PixelMap | null = null
    @Local contentWidth: number = 0
    @Local contentHeight: number = 0
    private uiContext = this.getUIContext()

    @Builder mskContent() {
        Column(){
            if(this.defaultBuilder){
                this.defaultBuilder()
            }
        }
        .backgroundColor(this.bgColor)
        .alignItems(HorizontalAlign.Start)
        .onAreaChange((_: Area, newVal: Area) => {
            if(!this.contentWidth && newVal.width && newVal.height){
                this.contentWidth = newVal.width as number
                this.contentHeight = newVal.height as number
            }
        })
    }

    @Monitor("colorMode.value", "showMosaic")
    onDidBuild() {
        if(this.showMosaic){
            this.getMskPixel()
        }
    }
    getMskPixel(){
        this.uiContext.getComponentSnapshot().createFromBuilder(() => {
            this.mskContent()
        }, this.delay, true, { waitUntilRenderFinished: true }).then((pixmap: PixelMap) => {
            this.mskPixelMap = applyMosaicToImage(pixmap, this.blockSize)
            this.isReady = true
        }).catch(() => {
            setTimeout(() => {
                this.getMskPixel()
            }, 50)
        })
    }

    build() {
        Stack({alignContent: Alignment.TopStart}){
            this.mskContent()
            Image(this.mskPixelMap)
                .width(this.contentWidth)
                .height(this.contentHeight)
                .objectFit(ImageFit.Fill)
                .borderRadius(this.radius)
                .visibility(this.showMosaic ? Visibility.Visible : Visibility.None)
        }
        .opacity(this.syncShow && !this.isReady ? 0 : 1)
    }
}