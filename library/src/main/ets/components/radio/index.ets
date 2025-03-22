import { emitter } from '../../utils/EventEmitter'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { COMPONENT_NAME, RADIO_GROUP_EVENT_NAME } from '../radioGroup/index.type'
import { BuilderArgs } from './index.type'
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit } from '../../utils/utils'
import { IBestRadioColor } from './color'
import { IBestIcon } from '../icon'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestRadio {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 组名
	 */
	@Param @Require @Once group: string
	/**
	 * 标识符，通常为一个唯一的字符串
	 */
	@Param @Require @Once name: IBestStringNumber | boolean
	/**
	 * 形状
	 */
	@Param shape: 'square' | 'round' | 'dot' = 'round'
	/**
	 * 选中状态颜色
	 */
	@Param checkedColor: ResourceColor = ""
	/**
	 * 图标大小
	 */
	@Param iconSize: IBestStringNumber = convertDimensionsWidthUnit(20)
	/**
	 * 是否禁用
	 */
	@Param disabled: boolean = false
	/**
	 * 显示的文本
	 */
	@Param label: ResourceStr = ''
	/**
	 * 文本大小
	 */
	@Param labelFontSize: IBestStringNumber = convertDimensionsWidthUnit(16)
	/**
	 * 文本位置，可选值为 left
	 */
	@Param labelPosition: 'left' | 'right' = 'right'
	/**
	 * 是否禁用复选框文本点击
	 */
	@Param labelDisabled: boolean = false
	/**
	 * 背景色
	 */
	@Param bgColor: ResourceColor = ''
	/**
	 * 边框色
	 */
	@Param bdColor: ResourceColor = IBestRadioColor.borderColor
	/**
	 * 自定义文本插槽
	 */
	@BuilderParam defaultBuilder: (data: BuilderArgs) => void
	/**
	 * 自定义图标插槽
	 */
	@BuilderParam iconBuilder: (data: BuilderArgs) => void
	/**
	 * 改变的回调
	 */
	@Event onChange: (checked: boolean) => void = () => {}

	@Local uniId: number = 0
	@Local isChecked: boolean = false

	@Builder LabelContain() {
		Row() {
			if (this.defaultBuilder) {
				this.defaultBuilder({ checked: this.isChecked, disabled: this.disabled })
			} else {
				Text(this.label)
					.fontColor(this.getLabelColor())
					.fontSize(getSizeByUnit(this.labelFontSize, true))
			}
		}
		.margin({
			left: this.isLeftLabel() ? 0 : this.baseStyle.spaceXs,
			right: this.isLeftLabel() ? this.baseStyle.spaceXs : 0
		})
		.onClick(() => {
			!this.labelDisabled && this.handleCheckedChange()
		})
	}
	aboutToAppear() {
		this.uniId = this.getUniqueId()
		if (this.group) {
			emitter.on(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.INIT_CHILDREN, this.group), this.uniId, (name: IBestStringNumber | boolean): void => this.handleRadioGroupInit(name))
		}
	}
	aboutToDisappear() {
		if (this.group) {
			emitter.off(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.INIT_CHILDREN, this.group), this.uniId)
		}
	}
	// 获取背景色
	getBackgroundColor() {
		if (this.disabled) {
			return IBestRadioColor.borderColor
		} else {
			return this.isChecked && this.shape != 'dot' ? (this.checkedColor || this.baseStyle.primary as string) : this.bgColor
		}
	}
	// 获取边框色
	getBorderColor() {
		if (this.disabled) {
			return GRAY_COLOR.GRAY_5
		} else {
			return this.isChecked ? (this.checkedColor || this.baseStyle.primary as string) : this.bdColor
		}
	}
	// 获取label的颜色
	getLabelColor() {
		return this.disabled ? IBestRadioColor.disabledLabelColor : IBestRadioColor.labelColor
	}
	// 获取图标的颜色
	getIconColor() {
		if (this.disabled) {
			return IBestRadioColor.disabledIconColor
		} else {
			return this.shape === 'dot' ? (this.checkedColor || this.baseStyle.primary as string) : IBestRadioColor.whiteColor
		}
	}
	// 是否是在左边的label
	isLeftLabel() {
		return this.labelPosition === 'left'
	}
	updateGroup() {
		if (this.group) {
			emitter.emit(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.name)
		}
	}
	// 改变选中状态的回调
	handleCheckedChange() {
		if (this.disabled || this.isChecked) {
			return
		}
		this.isChecked = true
		this.onChange(this.isChecked)
		this.updateGroup()
	}
	// 初始化
	handleRadioGroupInit(name: IBestStringNumber | boolean) {
		this.isChecked = name === this.name
	}
	build() {
		Row() {
			if (this.labelPosition === 'left') {
				this.LabelContain()
			}
			Column() {
				if (this.iconBuilder) {
					this.iconBuilder({ checked: this.isChecked, disabled: this.disabled })
				} else {
					if (this.shape === 'dot') {
						Column()
							.width(getSizeByUnit(this.iconSize))
							.aspectRatio(1)
							.backgroundColor(this.getIconColor())
							.borderRadius(this.baseStyle.borderRadiusMax)
							.scale({
								x: this.isChecked ? 0.7 : 0,
								y: this.isChecked ? 0.7 : 0
							})
							.animation({
								duration: this.baseStyle.animationDuration as number
							})
					} else {
						IBestIcon({
							name: "success",
							iconSize: this.iconSize,
							color: this.getIconColor()
						})
							.opacity(this.isChecked ? 1 : 0)
							.animation({
								duration: this.baseStyle.animationDuration as number,
							})
					}
				}
			}
			.padding(1)
			.justifyContent(FlexAlign.Center)
			.alignItems(HorizontalAlign.Center)
			.border({ color: this.getBorderColor(), width: 1 })
			.borderRadius(['round', 'dot'].includes(this.shape) ? this.baseStyle.borderRadiusMax : 0)
			.backgroundColor(this.getBackgroundColor())
			.animation({
				duration: this.baseStyle.animationDuration as number,
			})
			.onClick(() => {
				this.handleCheckedChange()
			})
			if (this.labelPosition === 'right') {
				this.LabelContain()
			}
		}.enabled(!this.disabled)
	}
}