import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { regionData } from "@ibestservices/area-data"
import { IBestContactAddressColor } from './color'
import { convertDimensionsWidthUnit, getResourceStr, getSizeByUnit } from '../../utils/utils'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestContactAddressFormResult, IBestContactAddressController } from './index.type'
import { IBestCascaderOption } from '../cascader/index.type'
import { IBestFormController, IBestFormRule } from '../form/index.type'
import { IBestTextEllipsis } from '../textEllipsis'
import { IBestButton } from '../button'
import { IBestForm } from '../form'
import { IBestField } from '../field'
import { IBestCascader } from '../cascader'
import { addressParse, filterPhone, judgeIsName } from './utils'
import { AppStorageV2 } from '@kit.ArkUI'
@ComponentV2
export struct IBestContactAddressForm {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!

	/**
	 * 是否显示识别输入框
	 */
	@Param showIdentifyInputBox: boolean = true
	/**
	 * 识别输入框顶部的提示文字
	 */
	@Param identifyTagText: ResourceStr = "示例：菜小鸟，136xxxx0000，浙江省杭州市西湖区某小区"
	/**
	 * 识别输入框顶部标签的背景色
	 */
	@Param identifyTagBgColor: ResourceColor = this.baseStyle.primary
	/**
	 * 识别输入框顶部的提示文字颜色
     */
	@Param identifyTagTextColor: ResourceColor = this.baseStyle.default
	/**
	 * 占位文字颜色
	 */
	@Param placeholderColor: ResourceColor = IBestContactAddressColor.placeholderColor
	/**
	 * 识别输入框内占位提示文字
	 */
	@Param identifyPlaceholder: ResourceStr = "请粘贴或输入文本，点击“识别”自动识别姓名、电话和地址"
	/**
	 * 左侧label字体颜色
	 */
	@Param labelColor: ResourceColor = IBestContactAddressColor.labelColor
	/**
	 * 输入框文字大小
	 */
	@Param inputFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 输入框文字粗细
	 */
	@Param inputFontWeight: IBestStringNumber | FontWeight = FontWeight.Bold
	/**
	 * 底部线条
	 */
	@Param hasBorder: boolean = true
	/**
	 * 组件控制器
	 */
	@Param @Once controller: IBestContactAddressController = new IBestContactAddressController()

	@Local name: string = ""
	@Local phone: string = ""
	@Local provinceCityDistrict: Array<IBestCascaderOption> = []
	@Local provinceCityDistrictStr: string = ""
	@Local visible: boolean = false
	@Local selectValue: string[] = []
	@Local detail: string = ""
	@Local postalCode: string = ""
	@Local addressText: string = ""
	@Local showLoading: boolean = false
	@Local identifyTagTextLength: number = 0
	private formId: string = ''
	private formController: IBestFormController = new IBestFormController()
	private rules: IBestFormRule = {
		"name": [
			{ required: true, message: $r('app.string.ibest_text_input_name') },
			{ validator: this.validatorName, message: $r('app.string.ibest_text_input_correct_content') }
		],
		"phone": [
			{ required: true, message: $r('app.string.ibest_text_input_phone') },
			{ validator: this.validatorPhone, message: $r('app.string.ibest_text_input_correct_content') }
		],
		"provinceCityDistrictStr": [
			{ required: true, message: $r('app.string.ibest_text_select_region') }
		]
	}

	aboutToAppear() {
		this.formId = `ibest_contact_address_form_${this.getUniqueId()}`
		this.controller.validateForm = (callBack) => {
			return this.formController.validate(callBack)
		}
		this.controller.getFormValues = (): IBestContactAddressFormResult => this.getFormValues()
		this.controller.setFormValues = (val: IBestContactAddressFormResult): void => this.setFormValues(val)
		this.controller.cleanFormValues = (): void => {
			this.phone = ''
			this.provinceCityDistrict = []
			this.provinceCityDistrictStr = ''
			this.detail = ''
			this.name = ''
			this.postalCode = ''
		}
	}
	@Monitor("identifyTagText")
	identifyTagTextChange() {
		this.identifyTagTextLength = getResourceStr(this.identifyTagText).length
	}
	validatorName(val: string){
		return judgeIsName(val)
	}
	validatorPhone(val: string){
		return filterPhone(val).target != ''
	}
	// 获取表单数据
	getFormValues() {
		return {
			phone: this.phone,
			province: this.provinceCityDistrict.length > 0 ? getResourceStr(this.provinceCityDistrict[0].text) : '',
			city: this.provinceCityDistrict.length > 1 ? getResourceStr(this.provinceCityDistrict[1].text) : '',
			area: this.provinceCityDistrict.length > 2 ? getResourceStr(this.provinceCityDistrict[2].text) : '',
			detail: this.detail,
			name: this.name,
			provinceCode: this.provinceCityDistrict.length > 0 ? this.provinceCityDistrict[0].value : '',
			cityCode: this.provinceCityDistrict.length > 1 ? this.provinceCityDistrict[1].value : '',
			areaCode: this.provinceCityDistrict.length > 2 ? this.provinceCityDistrict[2].value : '',
			postalCode: this.postalCode
		} as IBestContactAddressFormResult
	}
	// 设置表单数据
	setFormValues(val: IBestContactAddressFormResult) {
		this.phone = val.phone
		this.provinceCityDistrict = [
			{ text: val.province, value: val.provinceCode },
			{ text: val.city, value: val.cityCode },
			{ text: val.area, value: val.areaCode },
		]
		this.provinceCityDistrictStr = this.provinceCityDistrict
			.filter((item, index, arr) => index !== 1 || item.text !== arr[0].text)
			.map(item => item.text)
			.filter(e => e)
			.join(' ')
		this.selectValue = [val.provinceCode, val.cityCode, val.areaCode].filter(e => e)
		this.detail = val.detail
		this.name = val.name
		this.postalCode = val.postalCode || ''
	}
	build() {
		Column({ space: this.baseStyle.spaceSm as string }) {
			if (this.showIdentifyInputBox) {
				Column(){
					Column() {
						IBestTextEllipsis({
							text: this.identifyTagText,
							textFontSize: this.baseStyle.fontSizeSm as string,
							textColor: this.identifyTagTextColor
						})
					}
					.width(CONTAINER_SIZE.FULL)
					.backgroundColor(this.identifyTagBgColor)
					.padding({top: this.baseStyle.spaceX, bottom: this.baseStyle.spaceX, left: this.baseStyle.spaceSm, right: this.baseStyle.spaceSm})
					Column({ space: this.baseStyle.spaceXs as string }) {
						TextArea({ text: $$this.addressText, placeholder: this.identifyPlaceholder })
							.backgroundColor(Color.Transparent)
							.padding(this.baseStyle.spaceSm)
							.fontSize(getSizeByUnit(this.inputFontSize, true))
							.fontColor(IBestContactAddressColor.inputColor)
							.fontWeight(this.inputFontWeight)
							.placeholderFont({
								size: getSizeByUnit(this.inputFontSize, true)
							})
							.placeholderColor(this.placeholderColor)
							.constraintSize({
								minHeight: convertDimensionsWidthUnit(4 * 20),
								maxHeight: convertDimensionsWidthUnit(4 * 20)
							})
							.lineHeight(this.baseStyle.lineHeightMd)
							.enableAutoFill(false)
						Row({ space: this.baseStyle.spaceSm as string }) {
							Blank().layoutWeight(1)
							IBestButton({
								text: $r('app.string.ibest_text_clear'),
								btnBorderRadius: 20,
								btnWidth: 60,
								btnHeight: 28,
								btnBorderColor: Color.Transparent,
								onBtnClick: () => {
									this.addressText = ""
								}
							}).visibility(this.addressText.length > 0 ? Visibility.Visible : Visibility.Hidden)
							IBestButton({
								text: $r('app.string.ibest_text_identify'),
								type: "primary",
								btnBorderRadius: 20,
								btnWidth: 60,
								btnHeight: 28,
								disabled: this.addressText.length < 5,
								color: this.identifyTagBgColor,
								btnBorderColor: this.identifyTagBgColor,
								onBtnClick: () => {
									this.setFormValues(addressParse(this.addressText))
								}
							})
						}
						.margin({
							bottom: this.baseStyle.spaceSm,
							left: this.baseStyle.spaceSm,
							right: this.baseStyle.spaceSm
						})
					}
					.width(CONTAINER_SIZE.FULL)
					.backgroundColor(IBestContactAddressColor.bgColor)
				}
				.borderRadius(10)
				.clip(true)
			}
			IBestForm({
				formId: this.formId,
				controller: this.formController,
				requireAsteriskPosition: "right",
				rules: this.rules
			}) {
				Column() {
					IBestField({
						formId: this.formId,
						prop: 'name',
						value: this.name!!,
						label: $r('app.string.ibest_text_name'),
						placeholder: $r('app.string.ibest_text_input_name'),
						hasBorder: this.hasBorder,
						autosize: true,
						inputFontWeight: this.inputFontWeight,
						labelColor: this.labelColor,
						inputFontSize: this.inputFontSize,
						placeholderColor: this.placeholderColor,
					})
					IBestField({
						formId: this.formId,
						prop: 'phone',
						value: this.phone!!,
						label: $r('app.string.ibest_text_phone_number'),
						placeholder: $r('app.string.ibest_text_input_phone'),
						hasBorder: this.hasBorder,
						autosize: true,
						type: 'phone',
						inputFontWeight: this.inputFontWeight,
						labelColor: this.labelColor,
						inputFontSize: this.inputFontSize,
						placeholderColor: this.placeholderColor
					})
					IBestField({
						formId: this.formId,
						prop: 'provinceCityDistrictStr',
						value: this.provinceCityDistrictStr!!,
						label: $r('app.string.ibest_text_province_city_district'),
						placeholder: $r('app.string.ibest_text_select_region2'),
						isLink: true,
						onFieldClick: () => {
							this.visible = true
						},
						hasBorder: this.hasBorder,
						inputFontWeight: this.inputFontWeight,
						labelColor: this.labelColor,
						inputFontSize: this.inputFontSize,
						placeholderColor: this.placeholderColor
					})
					IBestField({
						formId: this.formId,
						prop: 'detail',
						value: this.detail!!,
						label: $r('app.string.ibest_text_detailed_address'),
						placeholder: $r('app.string.ibest_text_detailed_address_description'),
						hasBorder: this.hasBorder,
						inputFontWeight: this.inputFontWeight,
						labelColor: this.labelColor,
						inputFontSize: this.inputFontSize,
						placeholderColor: this.placeholderColor,
						autosize: true
					})
					IBestField({
						formId: this.formId,
						prop: 'postalCode',
						value: this.postalCode!!,
						label: $r('app.string.ibest_text_postal_code'),
						placeholder: $r('app.string.ibest_text_input_postal_code'),
						autosize: true,
						type: 'number',
						max: 6,
						inputFontWeight: this.inputFontWeight,
						labelColor: this.labelColor,
						inputFontSize: this.inputFontSize,
						placeholderColor: this.placeholderColor,
						hasBorder: false,
					})
				}
				.borderRadius(10)
				.clip(true)
			}
			IBestCascader({
				visible: this.visible!!,
				options: regionData,
				value: this.selectValue!!,
				onConfirm: value => {
					this.provinceCityDistrict = value
					this.provinceCityDistrictStr = value
						.filter((item, index, arr) => index !== 1 || item.text !== arr[0].text)
						.map(item => item.text)
						.join(' ')
				}
			})
		}
	}
}