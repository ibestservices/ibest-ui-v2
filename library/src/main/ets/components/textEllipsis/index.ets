import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import {
	convertDimensionsWidthUnit,
	getComponentsInfo,
	getResourceStr,
	getSizeByUnit,
	measureTextSize
} from '../../utils/utils'
import { IBestTextEllipsisColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestTextEllipsis{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 显示文本
     */
    @Param @Require text: ResourceStr
    /**
     * 文字大小
     */
    @Param textFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 文字颜色
     */
    @Param textColor: ResourceColor = IBestTextEllipsisColor.textColor
	/**
	 * 文字字重
	 * @since 0.0.8
	 */
	@Param textFontWeight: IBestStringNumber | FontWeight = FontWeight.Normal
    /**
     * 行高
     */
    @Param lineHeight: IBestStringNumber = convertDimensionsWidthUnit(20)
    /**
     * 展示的行数
     */
    @Param rows: number = 1
    /**
     * 是否显示操作
     */
    @Param showAction: boolean = false
    /**
     * 展开操作文案
     */
    @Param expandText: ResourceStr = $r("app.string.ibest_text_expand")
    /**
     * 收起操作文案
     */
    @Param collapseText: ResourceStr = $r("app.string.ibest_text_collapse")
    /**
     * 省略号内容
     */
    @Param omitContent: ResourceStr = "…"
	/**
	 * 操作文字字重
	 * @since 0.0.8
	 */
	@Param actionFontWeight: IBestStringNumber | FontWeight = FontWeight.Normal
    /**
     * 操作文字颜色
     */
    @Param actionColor: ResourceColor = this.baseStyle.primary
    /**
     * 省略位置
     */
    @Param omitPosition: "start" | "middle" | "end" = "end"
	/**
	 * 操作点击事件
	 * @since 0.0.2
     */
	@Event onActionClick: (isExpand: boolean) => void = () => {}

    @Local uniId: number = 0
    @Local showText: string = ""
    @Local isExpand: boolean = false
    @Local textWidth: number = 0
    @Local textHeight: number = 0
    @Local maxLineHeight: number = 0
    private uiContext = this.getUIContext()

    @Builder OmitContent(){
        Span(this.omitContent)
            .fontColor(this.textColor)
            .fontSize(getSizeByUnit(this.textFontSize, true))
			.fontWeight(this.textFontWeight)
    }

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
        this.formatText()
    }
    getTextString(){
        return getResourceStr(this.text)
    }
    getOmitText(){
        return getResourceStr(this.omitContent)
    }
    getExpandText(){
        return getResourceStr(this.expandText)
    }
    @Monitor("text, rows, omitPosition")
    formatText(){
        setTimeout(() => {
            this.textWidth = getComponentsInfo(this.uiContext, `ibest_text_ellipsis_${this.uniId}`).width
            this.textHeight = this.measureText(this.getTextString())
            this.maxLineHeight = this.measureText(this.getTextString(), this.rows)
            if(this.textHeight > this.maxLineHeight){
                this.getTextByWidth()
            }else {
                this.showText = this.getTextString()
            }
        }, 0)
    }
    getTextByWidth(){
        let clipText = this.getTextString()
        let textHeight = this.textHeight
        let centerIndex = Math.floor(clipText.length / 2)
        let leftStr = clipText.slice(0, centerIndex)
        let rightStr = clipText.slice(centerIndex)
        let omitText = this.getOmitText()
        let expandText = this.getExpandText()
        while (textHeight > this.maxLineHeight) {
            switch (this.omitPosition){
                case "start":
                    clipText = clipText.substring(1)
                    textHeight = this.measureText(omitText + clipText + (this.showAction ? expandText : ""))
                    break
                case "middle":
                    leftStr = leftStr.substring(0, leftStr.length - 1)
                    rightStr = rightStr.substring(1)
                    textHeight = this.measureText(leftStr + omitText + rightStr + (this.showAction ? expandText : ""))
                    break
                case "end":
                    clipText = clipText.substring(0, clipText.length - 1)
                    textHeight = this.measureText(clipText + (this.textHeight > this.maxLineHeight ? omitText : "") + (this.showAction ? expandText : ""))
                    break
            }
        }
        this.showText = this.omitPosition == 'middle' ? leftStr + omitText + rightStr : clipText
    }
    measureText(text: string, rows?: number): number{
        return measureTextSize(this.uiContext, {
            textContent: text,
            constraintWidth: this.textWidth,
            fontSize: getSizeByUnit(this.textFontSize, true),
            lineHeight: getSizeByUnit(this.lineHeight),
            maxLines: rows
        }).height
    }

    build() {
        Text(){
            if(this.textHeight > this.maxLineHeight && !this.isExpand && this.omitPosition == "start"){
                this.OmitContent()
            }
            Span(this.isExpand ? this.text : this.showText)
                .fontColor(this.textColor)
                .fontSize(getSizeByUnit(this.textFontSize, true))
				.fontWeight(this.textFontWeight)
            if(this.textHeight > this.maxLineHeight && !this.isExpand && this.omitPosition == "end"){
                this.OmitContent()
            }
            if(this.showAction && this.textHeight > this.maxLineHeight){
                Span(this.isExpand ? this.collapseText : this.expandText)
                    .fontColor(this.actionColor)
                    .fontSize(getSizeByUnit(this.textFontSize, true))
					.fontWeight(this.actionFontWeight)
                    .onClick(() => {
                        this.isExpand = !this.isExpand
						this.onActionClick(this.isExpand)
                    })
            }
        }
        .width(CONTAINER_SIZE.FULL)
        .lineHeight(getSizeByUnit(this.lineHeight))
        .id(`ibest_text_ellipsis_${this.uniId}`)
        .visibility(this.showText ? Visibility.Visible : Visibility.Hidden)
    }
}