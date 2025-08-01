import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle } from '../../theme-chalk/src/index.type'
import { SIZE } from '../../theme-chalk/src/size.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestIcon } from '../icon'
import { IBestCellColor } from './color'
import { ARROW_DIRECTION, BorderSizeType, CellSizeType } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestCell {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyle = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 左侧标题
	 */
	@Param title: ResourceStr = ''
	/**
	 * 标题的文字颜色 默认 #323233
	 */
	@Param titleColor: ResourceColor = IBestCellColor.titleColor
	/**
	 * 右侧内容
	 */
	@Param value: ResourceStr = ''
	/**
	 * 内容的文字颜色 默认 #969799
	 */
	@Param valueColor: ResourceColor = IBestCellColor.valueColor
	/**
	 * 标题下方的描述信息
	 */
	@Param label: ResourceStr = ''
	/**
	 * 描述的文字颜色 默认 #969799
	 */
	@Param labelColor: ResourceColor = IBestCellColor.labelColor
	/**
	 * 是否显示底部边框
	 */
	@Param hasBorder: boolean = true
	/**
	 * 单元格大小 默认 'normal'
	 */
	@Param cellSize: `${SIZE.LARGE}` | `${SIZE.NORMAL}` = SIZE.NORMAL
	/**
	 * 是否开启点击反馈
	 */
	@Param clickable: boolean = false
	/**
	 * 是否展示右侧箭头并开启点击反馈
	 */
	@Param isLink: boolean = false
	/**
	 * 右侧箭头方向
	 */
	@Param arrowDirection: `${ARROW_DIRECTION}` = ARROW_DIRECTION.RIGHT
	/**
	 * 右侧箭头大小
	 * @since 0.0.8
	 */
	@Param arrowSize: IBestStringNumber = convertDimensionsWidthUnit(14)
	/**
	 * 右侧箭头颜色
	 * @since 0.0.8
	 */
	@Param arrowColor: ResourceColor = GRAY_COLOR.GRAY_6
	/**
	 * 是否显示必填*号
	 */
	@Param required: boolean = false
	/**
	 * 是否使内容垂直居中
	 */
	@Param center: boolean = false
	/**
	 * 左侧图标
	 */
	@Param leftIcon: ResourceStr = ""
	/**
	 * 左侧图标颜色
	 */
	@Param leftIconColor: ResourceColor = ""
	/**
	 * 左侧图标大小
	 */
	@Param leftIconSize: IBestStringNumber = convertDimensionsWidthUnit(16)
	/**
	 * 左侧图标与title间距
	 */
	@Param leftIconMarginRight: IBestStringNumber = this.baseStyle.spaceBase
	/**
	 * 右侧图标
	 */
	@Param rightIcon: ResourceStr = ""
	/**
	 * 右侧图标颜色
	 */
	@Param rightIconColor: ResourceColor = GRAY_COLOR.GRAY_6
	/**
	 * 右侧图标大小
	 */
	@Param rightIconSize: IBestStringNumber = convertDimensionsWidthUnit(14)
	/**
	 * 右侧图标与内容间距
	 */
	@Param rightIconMarginLeft: IBestStringNumber = this.baseStyle.spaceBase
	/**
	 * 左侧内容宽度
	 */
	@Param leftContentWidth: IBestStringNumber = 0
	/**
	 * 左右padding
	 */
	@Param leftRightPadding: IBestStringNumber = this.baseStyle.spaceMd
	/**
	 * 底部分割线尺寸类型
	 */
	@Param borderSizeType: BorderSizeType = "center"
	/**
	 * 底部分割线left值
	 */
	@Param borderLeft: Dimension = this.baseStyle.spaceMd as Dimension
	/**
	 * 底部分割线颜色
	 */
	@Param bdColor: ResourceColor = IBestCellColor.borderColor
	/**
	 * 禁用
	 */
	@Param disabled: boolean = false
	/**
	 * 标题文字大小
	 * @since 0.0.6
	 */
	@Param titleFontSize: IBestStringNumber = ""
	/**
	 * 标题下方的描述信息文字大小
	 * @since 0.0.6
	 */
	@Param labelFontSize: IBestStringNumber = ""
	/**
	 * 单元格padding
	 * @since 0.0.8
	 */
	@Param cellPadding: Length | Padding | LocalizedPadding = 0
	/**
	 * title的插槽 优先级大于 title
	 */
	@BuilderParam titleBuilder: CustomBuilder
	/**
	 * value的插槽 优先级大于 value
	 */
	@BuilderParam valueBuilder: CustomBuilder
	/**
	 * value的插槽 优先级大于 label
	 */
	@BuilderParam labelBuilder: CustomBuilder
	/**
	 * 自定义icon的插槽
	 */
	@BuilderParam iconBuilder: CustomBuilder
	/**
	 * 自定义右侧icon的插槽
	 */
	@BuilderParam rightIconBuilder: CustomBuilder
	/**
	 * 点击单元格的回调
	 */
	@Event onCellClick: () => void = () => {}
	/**
	 * 根据arrow direction获取图标旋转角度
	 */
	arrowDirection2RotateDegMap: Record<string, number> = {
		[ARROW_DIRECTION.RIGHT]: 0,
		[ARROW_DIRECTION.TOP]: -90,
		[ARROW_DIRECTION.BOTTOM]: 90,
		[ARROW_DIRECTION.LEFT]: 180,
	}
	/**
	 * 根据size获取单元格的尺寸
	 */
	@Computed
	get computedCellSize(): CellSizeType {
		switch (this.cellSize) {
			case SIZE.LARGE:
				return {
					padding: convertDimensionsWidthUnit(14),
					fontSize: this.titleFontSize || this.baseStyle.fontSizeLg,
					labelFontSize: this.labelFontSize || this.baseStyle.fontSizeMd
				}
			default:
				return {
					padding: convertDimensionsWidthUnit(12),
					fontSize: this.titleFontSize || this.baseStyle.fontSizeMd,
					labelFontSize: this.labelFontSize || this.baseStyle.fontSizeSm
				}
		}
	}
	getArrowRotateAngle() {
		return this.arrowDirection2RotateDegMap[this.arrowDirection] || this.arrowDirection2RotateDegMap[ARROW_DIRECTION.RIGHT]
	}
	getAlignItems() {
		return this.center ? VerticalAlign.Center : VerticalAlign.Top
	}
	build() {
		Column() {
			Row() {
				if (this.required) {
					Text('*')
						.margin({
							right: this.baseStyle.spaceMini
						})
						.fontSize(this.baseStyle.fontSizeSm)
						.fontColor(this.baseStyle.danger)
				}
				Column() {
					Row() {
						if (this.iconBuilder) {
							Row() {
								this.iconBuilder()
							}.margin({ right: getSizeByUnit(this.leftIconMarginRight) })
						} else if (this.leftIcon) {
							IBestIcon({
								name: this.leftIcon,
								iconSize: this.leftIconSize,
								color: this.leftIconColor
							}).margin({ right: getSizeByUnit(this.leftIconMarginRight) })
						}
						if (this.titleBuilder) {
							Row() {
								this.titleBuilder()
							}
						} else {
							Text(this.title)
								.layoutWeight(1)
								.fontSize(this.computedCellSize.fontSize)
								.fontColor(this.titleColor)
						}
					}.width(CONTAINER_SIZE.FULL)
					.alignItems(this.getAlignItems())
					if (this.labelBuilder) {
						Row() {
							this.labelBuilder()
						}
					} else {
						if (this.label) {
							Text(this.label)
								.width(CONTAINER_SIZE.FULL)
								.fontSize(this.computedCellSize.labelFontSize)
								.margin({
									top: this.baseStyle.spaceBase
								})
								.fontColor(this.labelColor)
						}
					}
				}
				.layoutWeight(this.leftContentWidth ? 0 : 1)
				.width(getSizeByUnit(this.leftContentWidth))
				.alignItems(this.center ? HorizontalAlign.Center : HorizontalAlign.Start)
				Row() {
					Row() {
						if (this.valueBuilder) {
							this.valueBuilder()
						} else {
							Text(this.value)
								.textAlign(TextAlign.Start)
								.fontSize(this.computedCellSize.fontSize)
								.fontColor(this.valueColor)
						}
					}.justifyContent(FlexAlign.End).layoutWeight(1)
					if (this.rightIconBuilder) {
						Row() {
							this.rightIconBuilder()
						}
						.margin({ left: getSizeByUnit(this.rightIconMarginLeft) })
					} else if (this.rightIcon) {
						IBestIcon({
							name: this.rightIcon,
							iconSize: this.rightIconSize,
							color: this.rightIconColor
						}).margin({ left: getSizeByUnit(this.rightIconMarginLeft) })
					}
					if (this.isLink) {
						Row() {
							IBestIcon({
								name: "arrow",
								iconSize: this.arrowSize,
								color: this.arrowColor
							})
								.margin({
									left: getSizeByUnit(this.rightIconMarginLeft)
								})
								.rotate({ angle: this.getArrowRotateAngle() })
								.animation({
									duration: this.baseStyle.animationDuration as number
								})
						}.height(convertDimensionsWidthUnit(16))
					}
				}
				.layoutWeight(1)
				.alignItems(this.getAlignItems())
				if (this.hasBorder && this.borderSizeType == "center") {
					CellDivider({
						bottom: "-" + this.computedCellSize.padding as Dimension,
						bdColor: this.bdColor
					})
				}
			}
			.alignItems(this.getAlignItems())
			.width(CONTAINER_SIZE.FULL)
			.padding(this.cellPadding ? getSizeByUnit(this.cellPadding) : {
				top: this.computedCellSize.padding,
				bottom: this.computedCellSize.padding,
				left: getSizeByUnit(this.leftRightPadding),
				right: getSizeByUnit(this.leftRightPadding)
			})
			if (this.hasBorder && this.borderSizeType != "center") {
				CellDivider({
					left: this.borderSizeType == "right" ? this.borderLeft : 0,
					bdColor: this.bdColor
				})
			}
		}
		.stateStyles({
			normal: {
				.backgroundColor(IBestCellColor.bgColor)
			},
			pressed: {
				.backgroundColor(this.isLink || this.clickable ? IBestCellColor.activeBgColor : IBestCellColor.bgColor)
			}
		})
		.animation({
			duration: this.baseStyle.animationDuration as number
		})
		.enabled(!this.disabled)
		.opacity(this.disabled ? 0.6 : 1)
		.onClick(() => {
			this.onCellClick()
		})
	}
}
@ComponentV2
struct CellDivider {
	@Param bdColor: ResourceColor = ''
	@Param left: Dimension = 0
	@Param bottom: Dimension = 0
	build() {
		Divider()
			.width("100%")
			.height(1)
			.color(this.bdColor)
			.position({ left: this.left, bottom: this.bottom })
	}
}