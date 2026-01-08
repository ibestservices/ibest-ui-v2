import { IBestIcon } from "../icon"
import { AppStorageV2, LengthMetrics } from "@kit.ArkUI"
import { getComponentsInfo, getSizeByUnit, measureTextSize } from "../../utils/utils"
import { IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import { IBestInputTagColor } from "./color"
import { CONTAINER_SIZE } from "../../theme-chalk/src/container"

@ComponentV2
export struct IBestInputTag {
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 标签列表
     */
    @Param @Require value: string[]
    /**
     * 标签间距
     */
    @Param space: number = 6
    /**
     * 标签背景色
     */
    @Param tagBgColor: ResourceColor = IBestInputTagColor.tagBgColor
    /**
     * 字体大小
     */
    @Param fontSize: IBestStringNumber = this.baseStyle.fontSizeSm as string
    /**
     * 标签字体色
     */
    @Param tagFontColor: ResourceColor = IBestInputTagColor.tagFontColor
    /**
     * 输入框字体色
     */
    @Param inputFontColor: ResourceColor = IBestInputTagColor.inputColor
    /**
     * 外边框
     */
    @Param outerBorder: BorderOptions = {width: 1, color: IBestInputTagColor.borderColor}
    /**
     * 外圆角
     */
    @Param outerRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = this.baseStyle.borderRadiusMd
    /**
     * 外背景色
     */
    @Param outerBgColor: ResourceColor = IBestInputTagColor.bgColor
    /**
     * 外侧内边距
     */
    @Param outerPadding: Length | Padding | LocalizedPadding = 4
    /**
     * 标签改变事件
     */
    @Event onTagsChange: (tags: string[]) => void = () => {}
    @Event $value: (value: string[]) => void = () => {}

    @Local uniId: number = 0
    @Local isInit: boolean = true
    @Local contentWidth: number = 0
    @Local inputVal: string = ""
    @Local inputWidth: number = 0
    @Local baseTagBoxWidth: number = 0
    private uiContext = this.getUIContext()

    @Styles ibestInputTagBoxStyle(){
        .height(24)
        .padding({left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs})
        .backgroundColor(this.tagBgColor)
        .borderRadius(this.baseStyle.borderRadiusMd)
    }

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
    }
    init(){
        this.baseTagBoxWidth = getComponentsInfo(this.uiContext, `ibest_inputTag_box_${this.uniId}`).width
        if(this.value.length){
            this.getInputWidth()
        }
        this.isInit = false
    }
    @Monitor("value", "value.length")
    getInputWidth(){
        let currentLineWidth = 0
        for (let i = 0; i < this.value.length; i++) {
            const tag = this.value[i]
            const textWidth = measureTextSize(this.uiContext, {
                textContent: tag,
                fontSize: this.fontSize
            })
            const tagTotalWidth = textWidth.width + this.baseTagBoxWidth
            if (i === 0) {
                currentLineWidth = tagTotalWidth
            } else {
                if (currentLineWidth + this.space + tagTotalWidth <= this.contentWidth) {
                    currentLineWidth += this.space + tagTotalWidth
                } else {
                    currentLineWidth = tagTotalWidth
                }
            }
        }
        this.inputWidth = this.contentWidth - currentLineWidth - this.space
    }
    onInputSubmit(event: SubmitEvent){
        if(this.inputVal){
            this.value.push(this.inputVal)
            this.inputVal = ""
            event.keepEditableState()
            console.log("value", this.value.toString())
            this.onTagsChange(this.value)
        }
    }
    delTag(index: number){
        this.value.splice(index, 1)
        console.log("value", this.value.toString())
        this.onTagsChange(this.value)
    }

    build() {
        Row(){
            Row({space: this.baseStyle.spaceX}){
                Text()
                IBestIcon({ name: "cross", iconSize: this.fontSize })
            }
                .ibestInputTagBoxStyle()
                .position({x: 0, y: 0})
                .opacity(0)
                .id(`ibest_inputTag_box_${this.uniId}`)
            Flex({wrap: FlexWrap.Wrap, space: {main: LengthMetrics.vp(this.space), cross: LengthMetrics.vp(this.space)}}){
                ForEach(this.value, (tag: string, index: number) => {
                    Row({space: this.baseStyle.spaceX}){
                        Text(tag)
                            .fontSize(getSizeByUnit(this.fontSize, true))
                            .fontColor(this.tagFontColor)
                        IBestIcon({
                            name: "cross",
                            iconSize: this.fontSize,
                            color: this.tagFontColor,
                            onIconClick: () => {
                                this.delTag(index)
                            }
                        })
                    }
                    .ibestInputTagBoxStyle()
                })
                TextInput({ text: this.inputVal!! })
                    .width(this.inputWidth >= this.contentWidth * 0.3 ? this.inputWidth : CONTAINER_SIZE.FULL)
                    .height(24)
                    .fontSize(getSizeByUnit(this.fontSize, true))
                    .fontColor(this.inputFontColor)
                    .padding(0)
                    .borderRadius(0)
                    .backgroundColor(Color.Transparent)
                    .onDidDelete((info: DeleteValue) => {
                        if(info.deleteValue == '' && this.inputVal == '' && this.value.length){
                            this.delTag(this.value.length - 1)
                        }
                    })
                    .onSubmit((_: EnterKeyType, event: SubmitEvent) => {
                        this.onInputSubmit(event)
                    })
            }
            .width(CONTAINER_SIZE.FULL)
            .onAreaChange((_: Area, newVal: Area) => {
                this.contentWidth = newVal.width as number
                if(this.isInit){
                    this.init()
                }
            })
        }
        .width(CONTAINER_SIZE.FULL)
        .border(this.outerBorder)
        .borderRadius(getSizeByUnit(this.outerRadius))
        .backgroundColor(this.outerBgColor)
        .padding(getSizeByUnit(this.outerPadding))
    }
}