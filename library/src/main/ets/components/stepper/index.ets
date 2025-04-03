import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { accAdd, accSub, convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestStepperColor } from './color'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestIcon } from '../icon'

enum STEPPER_BTN_TYPE {
	PLUS = 'PLUS',
	REDUCE = 'REDUCE'
}

@ComponentV2
export struct IBestStepper {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 绑定值
	 */
	@Param @Require value: number
	/**
	 * 输入框宽度
	 */
	@Param inputWidth: IBestStringNumber = convertDimensionsWidthUnit(32)
	/**
	 * 按钮大小以及输入框高度
	 */
	@Param buttonSize: IBestStringNumber = convertDimensionsWidthUnit(27)
	/**
	 * 图标大小
	 */
	@Param iconSize: IBestStringNumber = convertDimensionsWidthUnit(20)
	/**
	 * 加减按钮图标的左右radius值
	 */
	@Param buttonRadius: IBestStringNumber = this.baseStyle.borderRadiusSm as string
	/**
	 * 最小值
	 */
	@Param min: number = 1
	/**
	 * 最大值
	 */
	@Param max: number = Infinity
	/**
	 * 多少毫秒触发校验修正 0时不校验
	 */
	@Param validateTime: number = 1000
	/**
	 * 是否自动校正超出限制范围的数值，设置为 false 后输入超过限制范围的数值将不会自动校正
	 */
	@Param autoFixed: boolean = true
	/**
	 * 步长，每次点击时改变的值
	 */
	@Param step: number = 1
	/**
	 * 固定显示的小数位数
	 */
	@Param decimalLength: number = 0
	/**
	 * 是否只允许输入整数
	 */
	@Param integer: boolean = false
	/**
	 * 是否禁用步进器
	 */
	@Param disabled: boolean = false
	/**
	 *  是否禁用增加按钮
	 */
	@Param disablePlus: boolean = false
	/**
	 *  是否禁用减少按钮
	 */
	@Param disableMinus: boolean = false
	/**
	 * 是否禁用输入框
	 */
	@Param disableInput: boolean = false
	/**
	 * 是否显示增加地址
	 */
	@Param showPlus: boolean = true
	/**
	 * 是否显示增加地址
	 */
	@Param showMinus: boolean = true
	/**
	 * 是否显示增加地址
	 */
	@Param showInput: boolean = true
	/**
	 * 是否开启长按手势，开启后可以长按增加和减少按钮
	 */
	@Param longPress: boolean = true
	/**
	 * 改变的回调
	 */
	@Event onChange: (value: number) => void = () => {}
	/**
	 * 点击增加按钮的回调
	 */
	@Event onPlus: () => void = () => {}
	/**
	 * 点击减少按钮的回调
	 */
	@Event onMinus: () => void = () => {}
	@Event $value: (value: number) => void = () => {}
	// 输入框的值
	@Local inputNumValue: string = ""
	// 减少按钮是否禁用
	@Local reduceBtnDisabled: boolean = false
	// 增加按钮是否禁用
	@Local plusBtnDisabled: boolean = false
	// 上一次输入正确的值
	private preValue: string = this.inputNumValue
	// 自动纠正的时间id
	private validateTimeId: number = 0

	@Builder stepperBtn(type: 'plus' | 'minus'){
		Button() {
			IBestIcon({
				name: type,
				iconSize: this.iconSize,
				color: IBestStepperColor.textColor
			})
		}
		.type(ButtonType.Normal)
		.backgroundColor(this.disabled ? IBestStepperColor.disabledBg : IBestStepperColor.bg)
		.width(getSizeByUnit(this.buttonSize))
		.height(getSizeByUnit(this.buttonSize))
		.borderRadius({
			topLeft: getSizeByUnit(this.buttonRadius),
			topRight: getSizeByUnit(this.buttonRadius),
			bottomLeft: getSizeByUnit(this.buttonRadius),
			bottomRight: getSizeByUnit(this.buttonRadius)
		})
		.enabled(!this.getBtnDisabled(type))
		.onClick(() => {
			this.handleClickStepperBtn(type == 'plus' ? STEPPER_BTN_TYPE.PLUS : STEPPER_BTN_TYPE.REDUCE)
		})
		.gesture(
			LongPressGesture({ repeat: true, duration: 200 })
				.onAction((event: GestureEvent) => {
					if (event && event.repeat) {
						this.handleClickStepperBtn(type == 'plus' ? STEPPER_BTN_TYPE.PLUS : STEPPER_BTN_TYPE.REDUCE)
					}
				})
		)
	}

	@Monitor("inputNumValue")
	inputValueChange(){
		this.$value(parseFloat(this.inputNumValue))
	}

	aboutToAppear() {
		this.inputNumValue = this.value.toString()
		this.handleInputNumChange(this.inputNumValue)
	}
	aboutToDisappear() {
		clearTimeout(this.validateTimeId)
	}
	// TextInput变化时赋值
	async handleInputNumChange(val: string, validateSameValue = false) {
		clearTimeout(this.validateTimeId)
		// 避免inputNum变化一致情况 当不触发beforechange时说明是修正 修正时不需要判定是否一致 不然可能会导致不更新
		if (validateSameValue && val === this.inputNumValue) {
			return
		}
		// 超过范围是否自动纠正
		if (this.autoFixed && val !== '') {
			if (parseFloat(val) > this.max) {
				// console.log('触发自动修正')
				this.handleInputNumChange(String(this.max))
				return
			}
			if (parseFloat(val) < this.min) {
				this.handleInputNumChange(String(this.min))
				return
			}
		}
		// 数据限制展示多少位
		if (this.decimalLength >= 1) {
			// console.log('触发decimalLength限制')
			val = Number(val).toFixed(Number(this.decimalLength))
		}
		// 限制整数 如果匹配不到正确的整数
		if (this.integer && !/^-?\d+$/.test(val)) {
			const numberArr = val.match(/^(-?\d+)/)
			if (Array.isArray(numberArr) && numberArr[0]) {
				val = String(Math.trunc(Number(numberArr[0])))
			} else {
				val = String(this.preValue || this.min)
			}
		}
		this.inputNumValue = String(val)
		this.handleSetStepperBtnStatus()
		// 判定输入是否合法
		if (/^-?\d+(\.\d+)?$/.test(val)) {
			this.preValue = val
			this.onChange(this.value)
		} else {
			this.handleValidateInputNum()
		}
	}
	// 输入值变化时如果不合法使用上一个有效值
	handleValidateInputNum() {
		this.validateTimeId = setTimeout(() => {
			// 校验延迟时间为0时不自动修复
			if (this.validateTime !== 0) {
				this.inputNumValue = this.preValue
				this.onChange(this.value)
			}
			this.handleSetStepperBtnStatus()
		}, this.validateTime)
	}
	// 监听inputNumChange改变按钮状态
	handleSetStepperBtnStatus() {
		const val = parseFloat(this.inputNumValue)
		this.reduceBtnDisabled = val <= this.min
		this.plusBtnDisabled = val >= this.max
	}
	// 当点击加减按钮时
	handleClickStepperBtn(btnType: STEPPER_BTN_TYPE) {
		if (this.disabled) {
			return
		}
		let nextValue = '0'
		// 如果增加
		if (btnType === STEPPER_BTN_TYPE.PLUS) {
			if (this.disablePlus) {
				return
			}
			nextValue = String(accAdd(Number(this.inputNumValue), this.step))
			this.onPlus()
		} else {
			if (this.disableMinus) {
				return
			}
			nextValue = String(accSub(Number(this.inputNumValue), this.step))
			this.onMinus()
		}
		this.handleInputNumChange(nextValue, true)
	}
	getBtnDisabled(type: 'plus' | 'minus'){
		return this.disabled || (type == 'minus' ? this.reduceBtnDisabled || this.disableMinus : this.plusBtnDisabled || this.disablePlus)
	}
	build() {
		Row() {
			if (this.showMinus) {
				this.stepperBtn("minus")
			}
			// 输入框
			if (this.showInput) {
				TextInput({ text: this.inputNumValue })
					.width(getSizeByUnit(this.inputWidth))
					.height(getSizeByUnit(this.buttonSize))
					.type(InputType.NUMBER_DECIMAL)
					.padding(0)
					.margin({
						top: 0,
						bottom: 0,
						left: convertDimensionsWidthUnit(2),
						right: convertDimensionsWidthUnit(2)
					})
					.fontSize(this.baseStyle.fontSizeMd)
					.fontColor(this.disabled ? IBestStepperColor.disabledTextColor : IBestStepperColor.textColor)
					.backgroundColor(IBestStepperColor.bg)
					.borderRadius(0)
					.textAlign(TextAlign.Center)
					.inputFilter(this.integer ? '[0-9-]' : '[0-9\.-]')
					.onChange((val) => this.handleInputNumChange(val, true))
					.focusable(!(this.disabled || this.disableInput))
			}
			if (this.showPlus) {
				this.stepperBtn("plus")
			}
		}
	}
}