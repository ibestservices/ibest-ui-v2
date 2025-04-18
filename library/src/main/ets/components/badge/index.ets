import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit } from '../../utils/utils'
import { IBestBadgeColor } from './color'
import { IBestBadgePosition } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'
@ComponentV2
export struct IBestBadge {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 徽标内容
	 */
	@Param content: IBestStringNumber = ''
	/**
	 * 徽标背景色
	 */
	@Param color: ResourceColor = IBestBadgeColor.badgeBgColor
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
	 * 自定义内容
	 */
	@BuilderParam defaultBuilder: CustomBuilder

	isShow(){
		return !(typeof this.content == "number" && this.content == 0 && !this.showZero)
	}
	getContent(){
		if(typeof this.content == 'number' && this.max > 0 && this.content > this.max){
			return this.max + '+'
		}
		return this.content.toString()
	}
	getPosition(): Edges{
		switch (this.badgePosition){
			case 'top-left':
				return {
					left: 0,
					top: 0
				}
			case 'top-right':
				return {
					right: 0,
					top: 0
				}
			case 'bottom-left':
				return {
					left: 0,
					bottom: 0
				}
			case 'bottom-right':
				return {
					right: 0,
					bottom: 0
				}
		}
	}
	getTranslate(): TranslateOptions{
		switch (this.badgePosition){
			case 'top-left':
				return {
					x: "-50%",
					y: "-50%"
				}
			case 'top-right':
				return {
					x: "50%",
					y: "-50%"
				}
			case 'bottom-left':
				return {
					x: "-50%",
					y: "50%"
				}
			case 'bottom-right':
				return {
					x: "50%",
					y: "50%"
				}
		}
	}
	build() {
		Row() {
			if (this.defaultBuilder) {
				this.defaultBuilder()
			}
			if (this.dot) {
				Text()
					.width(convertDimensionsWidthUnit(8))
					.aspectRatio(1)
					.borderRadius(this.baseStyle.borderRadiusMax)
					.backgroundColor(this.color)
					.position(this.getPosition())
					.translate(this.getTranslate())
			} else if(this.isShow()) {
				Text(this.getContent())
					.constraintSize({ minWidth: convertDimensionsWidthUnit(16) })
					.fontColor(IBestBadgeColor.textColor)
					.fontSize(convertDimensionsWidthUnit(12, true))
					.padding({ left: convertDimensionsWidthUnit(3), right: convertDimensionsWidthUnit(3) })
					.backgroundColor(this.color)
					.borderRadius(this.baseStyle.borderRadiusMax)
					.position(this.getPosition())
					.translate(this.getTranslate())
					.textAlign(TextAlign.Center)
			}
		}
	}
}