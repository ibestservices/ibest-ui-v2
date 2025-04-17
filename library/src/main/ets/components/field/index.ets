import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { COMPONENT_NAME, FieldValidateResult, FORM_EVENT_NAME, IBestFormRuleItem, IBestFormSendFieldCallResult } from '../form/index.type'
import type { ClearTriggerType, FieldTextAlign, FormatTriggerType, IBestFieldType, IBestFieldValueType, LabelPositionType, RequireAsteriskPositionType } from './index.type'
import { emitter } from '../../utils/EventEmitter'
import { runRuleValidator, runSyncRule } from './utils'
import { clamp, convertDimensionsWidthUnit, getEventName, getResourceStr, getSizeByUnit } from '../../utils/utils'
import { IBestFieldColor } from './color'
import { IBestIcon } from '../icon'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestField{
    /**
     * 全局公共样式
     */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * form id 用于验证
     */
    @Param formId: IBestStringNumber = ""
    /**
     * 表单绑定属性名
     */
    @Param prop: string = ""
    /**
     * 验证规则
     */
    @Param rules: IBestFormRuleItem[] = []
    /**
     * 组件绑定的值
     */
    @Param @Require value: IBestFieldValueType = ''
	/**
	 * 是否显示label
	 */
	@Param showLabel: boolean = true
    /**
     * 左侧文本内容
     */
    @Param label: ResourceStr = ""
	/**
	 * label字体大小
	 */
	@Param labelFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * label字体颜色
	 */
	@Param labelColor: ResourceColor = IBestFieldColor.labelColor
    /**
     * 是否在label后加冒号
     */
    @Param @Once colon?: boolean = undefined
    /**
     * 文本宽度
     */
    @Param @Once labelWidth: IBestStringNumber = 0
    /**
     * 文本位置
     */
    @Param @Once labelPosition?: LabelPositionType = undefined
    /**
     * 文本对齐方式
     */
    @Param @Once labelAlign?: FieldTextAlign = undefined
    /**
     * 输入框占位提示文字
     */
    @Param placeholder: ResourceStr = ""
    /**
     * 占位文字颜色
     */
    @Param placeholderColor: ResourceColor = IBestFieldColor.placeholderColor
    /**
     * 输入框类型
     */
    @Param type: IBestFieldType = "normal"
    /**
     * 小数点位数
     */
    @Param decimalLength: number = -1
    /**
     * 是否显示密码框末尾图标
     */
    @Param showPasswordIcon: boolean = true
    /**
     * 输入框自适应高度
     */
    @Param autosize: boolean = false
    /**
     * 自适应高度时默认行数
     */
    @Param rows: number = 1
    /**
     * 最大输入字符数
     */
    @Param maxlength: number = -1
    /**
     * 是否显示字数统计
     */
    @Param showWordLimit: boolean = false
    /**
     * 输入框文字对齐方式
     */
    @Param inputAlign: FieldTextAlign = "left"
    /**
     * 是否必填, 仅控制*显隐
     */
    @Param required?: boolean = undefined
    /**
     * 星号的位置
     */
    @Param @Once requireAsteriskPosition?: RequireAsteriskPositionType = undefined
    /**
     * 是否禁用
     */
    @Param disabled?: boolean = undefined
    /**
     * 是否只读
     */
    @Param readOnly: boolean = false
    /**
     * 是否开启点击反馈
     */
    @Param clickable: boolean = false
    /**
     * 是否展示右侧箭头并开启点击反馈
     */
    @Param isLink: boolean = false
    /**
     * 左侧图标
     */
    @Param leftIcon: ResourceStr = ""
    /**
     * 左侧图标颜色
     */
    @Param leftIconColor: ResourceColor = IBestFieldColor.labelColor
    /**
     * 右侧图标
     */
    @Param rightIcon: ResourceStr = ""
    /**
     * 右侧图标颜色
     */
    @Param rightIconColor: ResourceColor = IBestFieldColor.rightIconColor
    /**
     * 底部线条
     */
    @Param hasBorder: boolean = true
    /**
     * 是否启用清除图标，点击清除图标后会清空输入框
     */
    @Param clearable: boolean = false
    /**
     * 自定义清除图标
     */
    @Param clearIcon: ResourceStr = ""
    /**
     * 显示清除图标的时机
     */
    @Param clearTrigger: ClearTriggerType = 'focus'
    /**
     * 是否显示验证信息
     */
    @Param @Once showMessage?: boolean = undefined
	/**
	 * 验证信息对齐方式, 默认同输入框文字对齐方式一致
	 * @since 0.0.2
	 */
	@Param messageTextAlign: FieldTextAlign = this.inputAlign
    /**
     * 执行格式化函数触发时机
     */
    @Param formatTrigger: FormatTriggerType = 'onchange'
    /**
     * 左侧图标大小
     */
    @Param leftIconSize: IBestStringNumber = convertDimensionsWidthUnit(18)
    /**
     * 右侧图标大小
     */
    @Param rightIconSize: IBestStringNumber = convertDimensionsWidthUnit(18)
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = IBestFieldColor.bg2
    /**
     * 输入框文字大小
     */
    @Param inputFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 光标颜色
     */
    @Param caretColor: ResourceColor = ""
    /**
     * 最小值, type 为 number、decimal 有效
     */
    @Param min: number = -1
    /**
     * 最大值, type 为 number、decimal 有效
     */
    @Param max: number = -1
    /**
     * 垂直方向对齐方式, 仅labelPosition为left时有效
     */
    @Param verticalAlign: "top" | "center" = "top"
    /**
     * 外部圆角
     */
    @Param radius: IBestStringNumber = 0
    /**
     * 前缀内容
     */
    @Param prefix: ResourceStr = ""
    /**
     * 前缀内容颜色
     */
    @Param prefixFontColor: ResourceColor = IBestFieldColor.prefixFontColor
    /**
     * 后缀内容
     */
    @Param suffix: ResourceStr = ""
    /**
     * 后缀内容颜色
     */
    @Param suffixFontColor: ResourceColor = IBestFieldColor.suffixFontColor
    /**
     * 右侧按钮builder
     */
    @BuilderParam buttonBuilder: CustomBuilder
    /**
     * 自定义右侧内容
     */
    @BuilderParam customRightContent: CustomBuilder
    /**
     * 格式化函数
     */
    @Event formatter?: (value: string) => string = undefined
    /**
     * value变化回调函数
     */
	@Event onChange: (value: IBestFieldValueType) => void = () => {}
    /**
     * 点击清除按钮时触发
     */
	@Event onClear: () => void = () => {}
    /**
     * 点击组件触发
     */
	@Event onFieldClick: () => void = () => {}
    /**
     * 输入框获得焦点时触发
     */
	@Event onFieldFocus: () => void = () => {}
    /**
     * 输入框失去焦点时触发
     */
	@Event onFieldBlur: () => void = () => {}
    /**
     * 左侧图标点击时触发
     */
	@Event onLeftIconClick: () => void = () => {}
    /**
     * 右侧图标点击时触发
     */
	@Event onRightIconClick: () => void = () => {}
	@Event $value: (value: IBestFieldValueType) => void = () => {}
	@Event $required: (required: boolean) => void = () => {}
	@Event $rules: (rules: IBestFormRuleItem[]) => void = () => {}
	@Event $disabled: (disabled: boolean) => void = () => {}

	@Local uniId: number = 0
	@Local isFocus: boolean = false
	@Local fieldRequired: boolean = this.required ?? false
	@Local fieldDisabled: boolean = this.disabled ?? false
	@Local fieldRules: IBestFormRuleItem[] = this.rules
	// 验证状态
	@Local status: 'passed' | 'failed' | 'unvalidated' = 'unvalidated'
	// 验证信息
	@Local validateMessage: ResourceStr = ""
    private uiContext = this.getUIContext()

	@Builder asterisk(){
		Text("*")
			.margin({
				left: this.requireAsteriskPosition == "right" ? this.baseStyle.spaceMini : 0,
				right: this.requireAsteriskPosition == "left" ? this.baseStyle.spaceMini : 0
			})
			.fontSize(this.baseStyle.fontSizeSm)
			.fontColor(this.baseStyle.danger)
			.visibility(this.fieldRequired ? Visibility.Visible : Visibility.None)
	}
	@Builder fieldLabel(){
		if(this.showLabel){
			Row(){
				if(this.leftIcon){
					Image(this.leftIcon)
						.width(getSizeByUnit(this.leftIconSize))
						.fillColor(this.leftIconColor)
						.aspectRatio(1)
						.margin({right: this.baseStyle.spaceBase})
						.onClick(() => {
							this.onLeftIconClick()
						})
				}
				if(this.requireAsteriskPosition == "left"){
					this.asterisk()
				}
				Text(){
					Span(this.label)
					if(this.colon){
						Span(":")
					}
				}
				.fontSize(getSizeByUnit(this.labelFontSize, true))
				.fontColor(this.labelColor)
				.constraintSize({ minHeight: convertDimensionsWidthUnit(20) })
				.lineHeight(this.baseStyle.lineHeightMd)
				if(this.requireAsteriskPosition == "right"){
					this.asterisk()
				}
			}
			.width(this.labelPosition == "left" ? getSizeByUnit(this.labelWidth) : CONTAINER_SIZE.FULL)
			.margin({right: this.baseStyle.spaceSm})
			.alignItems(VerticalAlign.Center)
			.justifyContent(this.labelAlign == "left" ? FlexAlign.Start : this.labelAlign == "center" ? FlexAlign.Center : FlexAlign.End)
		}
	}
	@Builder fieldContent(){
		Column(){
			Row() {
				if(this.prefix){
					Text(this.prefix)
						.fontSize(getSizeByUnit(this.inputFontSize, true))
						.fontColor(this.prefixFontColor)
						.margin({right: this.baseStyle.spaceBase})
				}
				if (this.customRightContent) {
					this.customRightContent()
				} else {
					if (this.autosize) {
						TextArea({ text: $$this.value, placeholder: this.placeholder })
							.ibestFieldInputStyle()
							.caretColor(this.caretColor)
							.fontSize(getSizeByUnit(this.inputFontSize, true))
							.fontColor(IBestFieldColor.inputColor)
							.placeholderFont({
								size: getSizeByUnit(this.inputFontSize, true)
							})
							.placeholderColor(this.placeholderColor)
							.constraintSize({ minHeight: convertDimensionsWidthUnit(this.rows * 20) })
							.lineHeight(this.baseStyle.lineHeightMd)
							.maxLength(this.maxlength)
							// .showCounter(this.showWordLimit, {
							//     thresholdPercentage: 1,
							//     highlightBorder: false
							// })
							.enableAutoFill(false)
							.type(this.getTextAreaType())
							.onChange((value: string) => {
								this.formatValue(value, "onchange")
							})
							.onFocus(() => {
								this.isFocus = true
								this.onFieldFocus()
							})
							.onBlur(() => {
								this.isFocus = false
								this.onFieldBlur()
								if (this.formatTrigger == 'onblur' && typeof this.value == "string") {
									this.formatValue(this.value, "onblur")
								}
							})
					} else {
						TextInput({ text: $$this.value, placeholder: this.placeholder })
							.ibestFieldInputStyle()
							.caretColor(this.caretColor)
							.fontSize(getSizeByUnit(this.inputFontSize, true))
							.fontColor(IBestFieldColor.inputColor)
							.placeholderFont({
								size: getSizeByUnit(this.inputFontSize, true)
							})
							.placeholderColor(this.placeholderColor)
							.showPasswordIcon(this.showPasswordIcon)
							.height(this.baseStyle.lineHeightMd)
							.lineHeight(this.baseStyle.lineHeightMd)
							.textAlign(this.getInputAlign())
							.maxLength(this.maxlength)
							// .showCounter(this.showWordLimit, {
							//     thresholdPercentage: 1,
							//     highlightBorder: false
							// })
							.selectionMenuHidden(true)
							.type(this.getInputType())
							.onChange((value: string) => {
								this.formatValue(value, "onchange")
							})
							.onFocus(() => {
								this.isFocus = true
								this.onFieldFocus()
							})
							.onBlur(() => {
								this.isFocus = false
								this.onFieldBlur()
								if (typeof this.value == "string") {
									this.formatValue(this.value, "onblur")
								}
							})
					}
					// 清除图标
					if (this.clearable && this.value && (this.clearTrigger == 'always' || this.isFocus)) {
						IBestIcon({
							name: 'clear',
							iconSize: this.rightIconSize
						})
							.onClick(() => {
								this.$value('')
								this.onClear()
							})
							.margin({ left: this.baseStyle.spaceBase })
					}
				}
				// 按钮
				if(this.buttonBuilder){
					this.buttonBuilder()
				}
				// 右侧图标
				if(this.rightIcon){
					Image(this.rightIcon)
						.width(getSizeByUnit(this.rightIconSize))
						.aspectRatio(1)
						.fillColor(this.rightIconColor)
						.margin({left: this.baseStyle.spaceBase})
						.onClick(() => {
							this.onRightIconClick()
						})
				}
				// 后缀
				if(this.suffix){
					Text(this.suffix)
						.fontSize(getSizeByUnit(this.inputFontSize, true))
						.fontColor(this.suffixFontColor)
						.margin({left: this.baseStyle.spaceBase})
				}
				// link箭头
				if(this.isLink){
					IBestIcon({
						name: "arrow",
						iconSize: this.rightIconSize,
						color: this.rightIconColor
					})
						.onClick(() => {
							this.onFieldClick()
						})
						.margin({left: this.baseStyle.spaceBase})
				}
			}
			.width(CONTAINER_SIZE.FULL)
			// 限制字数, 官方的showCounter属性在TextInput上正常, 在TextArea上有问题,输入内容后才会显示下面字数
			if(typeof this.value == "string" && this.maxlength > 0 && this.showWordLimit){
				Text(this.value.length + "/" + this.maxlength)
					.width(CONTAINER_SIZE.FULL)
					.textAlign(TextAlign.End)
					.fontSize(this.baseStyle.fontSizeXs)
					.fontColor(GRAY_COLOR.GRAY_5)
					.margin({top: this.baseStyle.spaceBase})
			}
			// 验证信息
			if(this.showMessage && this.validateMessage){
				Text(this.validateMessage)
					.width(CONTAINER_SIZE.FULL)
					.fontSize(this.baseStyle.fontSizeSm)
					.fontColor(this.baseStyle.danger)
					.margin({top: this.baseStyle.spaceBase})
					.textAlign(this.getMessageAlign())
			}
		}
		.width(this.labelPosition == "top" ? CONTAINER_SIZE.FULL : "auto")
		.layoutWeight(this.labelPosition == "top" ? 0 : 1)
		.alignItems(HorizontalAlign.Start)
	}
    @Builder focusText(){
        Text()
            .focusable(true)
            .position({left: 0, top: 0})
            .zIndex(-10)
            .id(`ibest_field_${this.uniId}`)
    }
    @Styles ibestFieldStyle(){
        .width(CONTAINER_SIZE.FULL)
        .padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd })
        .stateStyles({
            normal: {
                .backgroundColor(this.bgColor)
            },
            pressed: {
                .backgroundColor((this.clickable || this.isLink) ? IBestFieldColor.activeColor : this.bgColor)
            }
        })
        .borderRadius(getSizeByUnit(this.radius))
        .enabled(!this.fieldDisabled)
        .opacity(this.fieldDisabled ? 0.6 : 1)
        .clip(true)
        .onTouch(event => {
            if(event.type == TouchType.Up){
                this.onFieldClick()
                if((this.fieldDisabled || this.readOnly || this.isLink) && !this.customRightContent){
                    this.uiContext.getFocusController().requestFocus(`ibest_field_${this.uniId}`)
                }
            }
        })
    }
    @Styles ibestFieldContentStyle(){
        .padding({ top: convertDimensionsWidthUnit(10), bottom: convertDimensionsWidthUnit(10) })
        .border({
            width: { bottom: this.hasBorder ? 1 : 0 },
            color: IBestFieldColor.borderColor
        })
    }
	@Styles ibestFieldInputStyle(){
		.layoutWeight(1)
		.padding(0)
		.borderRadius(0)
		.backgroundColor("transparent")
		.focusable(!(this.fieldDisabled || this.readOnly || this.isLink))
		.onClick(() => {
			this.onFieldClick()
		})
	}

	@Monitor("required") requiredChange(){
		this.fieldRequired = this.required || false
	}
	@Monitor("disabled") disabledChange(){
		this.fieldDisabled = this.disabled || false
	}

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
        this.initValue()
        if(this.formId && this.prop){
            emitter.on(getEventName(COMPONENT_NAME, FORM_EVENT_NAME.RESEND_FORM_ITEM, this.formId), this.uniId, (): void => this.sendFormItemData())
            this.sendFormItemData()
        }else{
            this.init()
        }
    }
    aboutToDisappear(): void {
        if(this.formId && this.prop) {
            emitter.off(getEventName(COMPONENT_NAME, FORM_EVENT_NAME.RESEND_FORM_ITEM, this.formId), this.uniId)
            emitter.emit(getEventName(COMPONENT_NAME, FORM_EVENT_NAME.DELETE_FORM_ITEM, this.formId), this.uniId)
            emitter.emit(getEventName(COMPONENT_NAME, FORM_EVENT_NAME.RESEND_FORM_ITEM, this.formId))
        }
    }
	@Monitor("rules")
    rulesChange(){
		let required = this.rules.length > 0 && this.rules.some((item: IBestFormRuleItem) => item.required)
		this.fieldRequired = required
		this.$required(required)
		this.fieldRules = this.rules
        if(!required){
            this.resetValidation()
        }
    }
    initValue(){
        if(this.value === undefined || this.value === null){
            this.$value("")
        }
    }
    // 发送表单子项信息
    sendFormItemData(){
        emitter.emit(getEventName(COMPONENT_NAME, FORM_EVENT_NAME.SEND_FIELD, this.formId), {
            uniId: this.uniId,
            prop: this.prop,
            validate: (rules: IBestFormRuleItem[]):Promise<void | FieldValidateResult> => this.validate(rules),
            getValue: (): IBestFieldValueType => this.value,
            resetValidation: (): void => this.resetValidation()
        }, (result: IBestFormSendFieldCallResult): void => this.init(result))
    }
    // 初始化参数
    init(results?: IBestFormSendFieldCallResult){
        if(results?.rules && !this.rules.length){
			this.fieldRules = results.rules
        }
		let required = this.required ?? (this.fieldRules.length > 0 && this.fieldRules.some((item: IBestFormRuleItem) => item.required))
		this.fieldRequired = required
		this.$required(required)
        this.labelWidth = this.labelWidth || results?.labelWidth || convertDimensionsWidthUnit(80)
        this.labelPosition = this.labelPosition || results?.labelPosition || 'left'
        this.labelAlign = this.labelAlign || results?.labelAlign || 'left'
        this.colon = this.colon ?? (results?.colon || false)
        this.requireAsteriskPosition = this.requireAsteriskPosition || results?.requireAsteriskPosition || 'left'
        this.showMessage = this.showMessage ?? (results?.showMessage || true)
		let disabled = this.disabled ?? (results?.disabled || false)
		this.fieldDisabled = disabled
        this.$disabled(disabled)
    }
    // 重置验证
    resetValidation(){
        this.status = 'unvalidated'
        this.validateMessage = ""
    }
    // 验证
    validate(rules: IBestFormRuleItem[]): Promise<FieldValidateResult | void> {
        return new Promise<FieldValidateResult | void>((resolve) => {
            this.resetValidation()
            rules = rules || this.fieldRules
            if (rules.length) {
                let value = this.value
                this.runRules(value, rules).then(() => {
                    if (this.status === 'failed') {
                        resolve({
                            label: getResourceStr(this.label),
                            name: this.prop,
                            message: getResourceStr(this.validateMessage)
                        })
                    } else {
                        this.status = 'passed'
                        resolve()
                    }
                })
            } else {
                resolve()
            }
        })
    }
    // 执行规则
    async runRules(value: IBestFieldValueType, rules: IBestFormRuleItem[]){
        for (let rule of rules) {
            if (!runSyncRule(value, rule)) {
                this.status = 'failed'
                this.validateMessage = rule.message || ''
                return
            }
            if (rule.validator && typeof value === 'string') {
                await runRuleValidator(value, rule).then(result => {
                    if (result && typeof result === 'string') {
                        this.status = 'failed'
                        this.validateMessage = result
                        return
                    } else if (result === false) {
                        this.status = 'failed'
                        this.validateMessage = rule.message || ""
                        return
                    }
                })
            }
        }
    }
    // 通过trigger 判断rules中是否有可触发项
    getFilteredRule(trigger: 'blur' | 'change') {
        return this.fieldRules ? this.fieldRules.filter((rule) => {
            if (!rule.trigger) return true
            return rule.trigger === trigger
        }) : []
    }
    // value  change变化 执行验证
	@Monitor("value")
    valueChange(){
		console.log("valueChange")
        this.sendValidate("change")
    }
	// 格式化值
	formatValue(value: string, trigger: string) {
		if (this.formatter && this.formatTrigger == trigger) {
			value = this.formatter(value)
		}
		if(this.type == "number" || this.type == "decimal"){
			if(trigger == 'onblur' && value !== '' && (this.min > -1 || this.max > -1)){
				const validValue = clamp(Number(value), this.min > -1 ? this.min : -Infinity, this.max > -1 ? this.max : Infinity)
				value = validValue.toString()
			}
			if(this.type == "decimal" && this.decimalLength > 0){
				let index = value.indexOf(".")
				if(index > -1){
					let decimal = value.substring(index + 1)
					if(decimal.length > this.decimalLength){
						value = Number(value).toFixed(this.decimalLength)
					}
				}
			}
		}
		this.$value(value)
		if(trigger == 'onchange'){
			this.onChange(value)
		}
	}
	// 失焦执行
    handleBlur(){
        this.onFieldBlur()
        this.sendValidate("blur")
    }
    // 发送单个验证
    sendValidate(trigger: 'blur' | 'change'){
        if(this.formId && this.prop){
            let rules: IBestFormRuleItem[] = this.getFilteredRule(trigger)
            if(rules.length) {
                emitter.emit(getEventName(COMPONENT_NAME, FORM_EVENT_NAME.VALIDATE_FIELD, this.formId), this.prop)
            }
        }
    }
    getVerticalAlign(){
        if(this.verticalAlign){
            return this.verticalAlign == 'top' ? VerticalAlign.Top : VerticalAlign.Center
        }else{
            return (this.showWordLimit || this.autosize || this.validateMessage) ? VerticalAlign.Top : VerticalAlign.Center
        }
    }
	getInputAlign(){
		return this.inputAlign == 'center' ? TextAlign.Center : this.inputAlign == 'right' ? TextAlign.End : TextAlign.Start
	}
	getMessageAlign(){
		return this.messageTextAlign == 'center' ? TextAlign.Center : this.messageTextAlign == 'right' ? TextAlign.End : TextAlign.Start
	}
	// 获取输入框类型
	getInputType(): InputType{
		switch(this.type){
			case "password":
				return InputType.NEW_PASSWORD
			case "email":
				return InputType.Email
			case "number":
				return InputType.Number
			case "phone":
				return InputType.PhoneNumber
			case "username":
				return InputType.USER_NAME
			case "number-password":
				return InputType.NUMBER_PASSWORD
			case "decimal":
				return InputType.NUMBER_DECIMAL
			default:
				return InputType.Normal
		}
	}
	// 获取textarea类型
	getTextAreaType(): TextAreaType{
		switch(this.type){
			case "number":
				return TextAreaType.NUMBER
			case "phone":
				return TextAreaType.PHONE_NUMBER
			case "email":
				return TextAreaType.EMAIL
			case "decimal":
				return TextAreaType.NUMBER_DECIMAL
			default:
				return TextAreaType.NORMAL
		}
	}

    build() {
        if(this.labelPosition == "left"){
            Row(){
                Row(){
					this.fieldLabel()
                    this.fieldContent()
                }
                .alignItems(this.getVerticalAlign())
                .ibestFieldContentStyle()
                this.focusText()
            }
            .ibestFieldStyle()
        }else{
            Column(){
                Column(){
					this.fieldLabel()
					this.fieldContent()
                }
                .alignItems(HorizontalAlign.Start)
                .ibestFieldContentStyle()
                this.focusText()
            }
            .alignItems(HorizontalAlign.Start)
            .ibestFieldStyle()
        }
    }
}