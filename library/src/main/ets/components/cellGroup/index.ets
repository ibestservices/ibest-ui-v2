import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestCellGroupColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestCellGroup {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyle = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE, () => new IBestUIBaseStyle({})) as IBestUIBaseStyle
	/**
	 * 分组标题
	 */
	@Param title: ResourceStr = ''
	/**
	 * 是否展示为圆角卡片风格
	 */
	@Param inset: boolean = false
	/**
	 * 是否显示外边框
	 */
	@Param hasBorder: boolean = true
	/**
	 * 圆角大小, 仅inset为true时有效
     */
	@Param radius: IBestStringNumber = this.baseStyle.borderRadiusLg as string
	/**
	 * 标题内边距
	 * @since 2.1.2
	 */
	@Param titlePadding: IBestStringNumber | Padding = this.baseStyle.spaceMd as string
	/**
	 * 默认插槽
	 */
	@BuilderParam defaultBuilder: CustomBuilder

	// 获取边框宽度
	getBorderWidth() {
		return this.hasBorder && !this.inset ? 1 : 0
	}
	// 获取margin
	getMargin() {
		return this.inset ? { left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd } as Padding : 0
	}
	// 获取内边距
	getPadding() {
		return ['string', 'number'].includes(typeof this.titlePadding) ? getSizeByUnit(this.titlePadding as IBestStringNumber) : this.titlePadding
	}
	build() {
		Column() {
			if (this.title) {
				Text(this.title)
					.textAlign(TextAlign.Start)
					.width(CONTAINER_SIZE.FULL)
					.border({
						width: { bottom: this.getBorderWidth() },
						color: IBestCellGroupColor.borderColor
					})
					.padding(this.getPadding())
					.lineHeight(convertDimensionsWidthUnit(16))
					.fontSize(this.baseStyle.fontSizeMd)
					.fontColor(IBestCellGroupColor.textColor)
			}
			if (this.defaultBuilder) {
				this.defaultBuilder()
			}
		}
		.border({
			width: { bottom: this.getBorderWidth(), top: this.title ? 0 : this.getBorderWidth() },
			color: IBestCellGroupColor.borderColor
		})
		.margin(this.getMargin())
		.borderRadius(this.inset ? getSizeByUnit(this.radius) : 0)
		.clip(true)
	}
}