import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestDividerColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestDivider{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 线宽, 仅hairline为false时生效
     */
	@Param lineWidth: IBestStringNumber = convertDimensionsWidthUnit(1)
	/**
	 * 是否使用虚线
	 */
	@Param dashed: boolean = false
	/**
	 * 是否使用细线
     */
	@Param hairline: boolean = true
	/**
	 * 是否垂直
     */
	@Param vertical: boolean = false
	/**
	 * 分割线高度, 仅垂直时生效
     */
	@Param lineHeight: IBestStringNumber = convertDimensionsWidthUnit(14)
	/**
	 * 线颜色
     */
	@Param lineColor: ResourceColor = IBestDividerColor.borderColor
	/**
	 * 文本内容, 仅水平时生效
     */
	@Param text: ResourceStr = ""
	/**
	 * 文字颜色, 仅水平时生效
     */
	@Param color: ResourceColor = IBestDividerColor.textColor
	/**
	 * 文本大小, 仅水平时生效
     */
	@Param texFontSize: IBestStringNumber = convertDimensionsWidthUnit(14, true)
	/**
	 * 文本与线段间距, 仅水平时生效
     */
	@Param textLineSpace: IBestStringNumber = this.baseStyle.spaceMd as string
	/**
	 * 左侧线段宽度, 仅水平时生效
     */
	@Param leftLineWidth: IBestStringNumber = ""
	/**
	 * 右侧线段宽度, 仅水平时生效
     */
	@Param rightLineWidth: IBestStringNumber = ""
	/**
	 * 左右内边距, 仅水平时生效
     */
	@Param leftRightPadding: IBestStringNumber = 0
	/**
	 * 左右外边距, 仅垂直时生效
     */
	@Param leftRightMargin: IBestStringNumber = this.baseStyle.spaceXs as string
	/**
	 * 自定义文本内容
     */
	@BuilderParam textBuilder: CustomBuilder

	build() {
		if(this.vertical){
			Row()
				.width(1)
				.height(getSizeByUnit(this.lineHeight))
				.scale({x: this.hairline ? 0.5 : 1})
				.border({ width: { left: this.hairline ? 1 : getSizeByUnit(this.lineWidth) }, color: this.lineColor, style: this.dashed ? BorderStyle.Dashed : BorderStyle.Solid })
				.margin({left: getSizeByUnit(this.leftRightMargin), right: getSizeByUnit(this.leftRightMargin)})
		}else{
			Row(){
				Row()
					.width(this.leftLineWidth)
					.height(1)
					.layoutWeight(this.leftLineWidth ? "" : 1)
					.scale({y: this.hairline ? 0.5 : 1})
					.border({ width: { top: this.hairline ? 1 : getSizeByUnit(this.lineWidth) }, color: this.lineColor, style: this.dashed ? BorderStyle.Dashed : BorderStyle.Solid })
				if(this.textBuilder || this.text){
					Row(){
						if(this.textBuilder){
							this.textBuilder()
						}else{
							Text(this.text)
								.fontColor(this.color)
								.fontSize(getSizeByUnit(this.texFontSize, true))
						}
					}
					.margin({left: getSizeByUnit(this.textLineSpace), right: getSizeByUnit(this.textLineSpace)})
					Row()
						.width(this.rightLineWidth)
						.height(1)
						.layoutWeight(this.rightLineWidth ? "" : 1)
						.scale({y: this.hairline ? 0.5 : 1})
						.border({ width: { top: this.hairline ? 1 : getSizeByUnit(this.lineWidth) }, color: this.lineColor, style: this.dashed ? BorderStyle.Dashed : BorderStyle.Solid })
				}
			}
			.width(CONTAINER_SIZE.FULL)
			.padding({left: getSizeByUnit(this.leftRightPadding), right: getSizeByUnit(this.leftRightPadding)})
			.alignItems(VerticalAlign.Center)
		}
	}
}