import {
	IBestButton,
	IBestCalendarDialog,
	IBestCascader,
	IBestCascaderOption,
	IBestCellGroup,
	IBestCheckbox,
	IBestCheckboxGroup,
	IBestDialogUtil,
	IBestField,
	IBestForm,
	IBestFormController,
	IBestFormRule,
	IBestPicker,
	IBestPickerOption,
	IBestPopup,
	IBestRadio,
	IBestRadioGroup,
	IBestStepper,
	IBestSwipeCell,
	IBestSwitch,
	IBestToast,
	IBestUploader,
	IBestUploaderFile
} from '@ibestservices/ibest-ui-v2'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import CustomNavBar from '../../components/CustomNavBar'
import { LengthMetrics } from '@kit.ArkUI'

@Builder
export function FormBuilder(_: string, title: string){
	FormPage({title})
}

@ObservedV2
class Form{
	@Trace name: string = ''
	@Trace phone: number | string = ""
}
@ObservedV2
class Form1{
	@Trace value1: string = "123"
	@Trace value2: string = ""
	@Trace value3: string = "abc"
	@Trace value4: string = ""
}
@ObservedV2
class Form2{
	@Trace value1: boolean = false
	@Trace value2: boolean = false
	@Trace value3: string[] = []
	@Trace value4: boolean = false
	@Trace value5: number = 1
	@Trace value6: string[] = []
	@Trace value7: string = ""
	@Trace value8: IBestUploaderFile[] = []
}
@ObservedV2
class Form3{
	@Trace sex: string | number = ''
	@Trace info1: string = ""
	@Trace info2: string = ""
	@Trace list: Subject[] = []
}
@ObservedV2
class Subject {
	type: string = ""
	@Trace name: string = ""
	@Trace score: number = 0
}

@Entry
@ComponentV2
struct FormPage {
	@Param title: string = ''
	@Local form: Form = new Form()
	private formId: string = 'form'
	private controller: IBestFormController = new IBestFormController()

	@Local form1: Form1 = new Form1()
	private formId1: string = 'form1'
	private pattern = /\d{6}/
	// 校验函数返回 true 表示校验通过，false 表示不通过
	private validator = (val: string) => /1\d{10}/.test(val)
	// 校验函数可以直接返回一段错误提示
	private validatorMessage = (val: string) => `${val} 不合法，请重新输入`
	// 校验函数可以返回 Promise，实现异步校验
	private asyncValidator(val: string): Promise<boolean> {
		return new Promise((resolve) => {
			IBestToast.show({
				type: "loading",
				message: '校验中...'
			})
			setTimeout(() => {
				IBestToast.hide()
				resolve(val === '1234')
			}, 1000)
		})
	}
	private rules1: IBestFormRule = {
		"value1": [
			{ pattern: this.pattern, message: '请输入正确的内容' }
		],
		"value2": [
			{ validator: this.validator, message: "请输入正确内容" }
		],
		"value3": [
			{ validator: this.validatorMessage }
		],
		"value4": [
			{ validator: this.asyncValidator, message: "请输入正确内容" }
		]
	}
	private controller1: IBestFormController = new IBestFormController()

	@Local form2: Form2 = new Form2()
	@Local visible: boolean = false
	@Local selectValue: string = ''
	@Local visible1: boolean = false
	private formId2: string = 'form2'
	private rules2: IBestFormRule = {
		"value3": [
			{ required: true, message: '请选择' },
			{ min: 2, message: '请选择至少两项' }
		],
		"value4": [
			{ required: true, message: "请选择" }
		],
		"value6": [
			{ required: true, message: "请选择城市" }
		],
		"value7": [
			{ required: true, message: "请选择日期" }
		],
		"value8": [
			{ required: true, message: "请上传图片" }
		]
	}
	private controller2: IBestFormController = new IBestFormController()
	private options: IBestCascaderOption[] = [
		{
			text: "江苏省",
			value: "320000",
			children: [
				{
					text: "南京市",
					value: "320100",
					children: [
						{
							text: "秦淮区",
							value: "320104"
						},
						{
							text: "雨花台区",
							value: "320114"
						}
					]
				},
				{
					text: "苏州市",
					value: "320500",
					children: [
						{
							text: "姑苏区",
							value: "320508"
						},
						{
							text: "昆山市",
							value: "320583"
						}
					]
				}
			]
		},
		{
			text: "安徽省",
			value: "340000",
			children: [
				{
					text: "合肥市",
					value: "340100",
					children: [
						{
							text: "蜀山区",
							value: "340104"
						},
						{
							text: "合肥高新技术产业开发区",
							value: "340171"
						}
					]
				},
				{
					text: "黄山市",
					value: "341000",
					children: [
						{
							text: "屯溪区",
							value: "341002"
						},
						{
							text: "黄山区",
							value: "341003"
						}
					]
				}
			]
		}
	]

	@Local form3: Form3 = new Form3()
	private formId3: string = 'form3'
	private rules3: IBestFormRule = {
		"sex": [
			{ required: true, message: "请选择性别" }
		],
		"info1": [
			{ required: true, message: "请输入男生信息" }
		],
		"info2": [
			{ required: true, message: "请输入女生信息" }
		],
		"type": [
			{ required: true, message: "请选择学科类型" }
		],
		"score": [
			{ required: true, message: "请输入分数" }
		]
	}
	private controller3: IBestFormController = new IBestFormController()

	@Builder switchContent() {
		IBestSwitch({
			value: this.form2.value1!!
		})
	}
	@Builder checkboxContent() {
		IBestCheckbox({
			value: this.form2.value2!!,
			shape: "square",
			name: "1"
		})
	}
	@Builder checkboxGroupContent() {
		IBestCheckboxGroup({
			group: "group1",
			activeList: this.form2.value3!!,
			placeDirection: Axis.Horizontal
		}){
			Flex({wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(5) }}){
				IBestCheckbox({
					group: "group1",
					shape: "square",
					label: "复选框1",
					name: "1"
				})
				IBestCheckbox({
					group: "group1",
					shape: "square",
					label: "复选框2",
					name: "2"
				})
				IBestCheckbox({
					group: "group1",
					shape: "square",
					label: "复选框3",
					name: "3"
				})
				IBestCheckbox({
					group: "group1",
					shape: "square",
					label: "复选框4",
					name: "4"
				})
			}
		}
	}
	@Builder radioContent() {
		IBestRadioGroup({
			active: this.form2.value4!!,
			group: "group1",
			placeDirection: Axis.Horizontal
		}){
			IBestRadio({
				group: "group1",
				label: "单选框1",
				name: true
			})
			IBestRadio({
				group: "group1",
				label: "单选框2",
				name: false
			})
		}
	}
	@Builder radioContent1() {
		IBestRadioGroup({
			active: this.form3.sex!!,
			group: "group2",
			placeDirection: Axis.Horizontal
		}){
			IBestRadio({
				group: "group2",
				label: "男",
				name: 1
			})
			IBestRadio({
				group: "group2",
				label: "女",
				name: 2
			})
		}
	}
	@Builder stepperContent(){
		IBestStepper({
			value: this.form2.value5!!,
			min: 1,
			max: 99
		})
	}
	@Builder uploadImg(){
		IBestUploader({
			fileList: this.form2.value8!!,
			max: 2
		})
	}

	deleteContent(index: number){
		this.form3.list.splice(index, 1)
	}
	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法', titlePaddingLeft: SPACE.MD }) {
						IBestForm({
							formId: this.formId,
							controller: this.controller
						}){
							IBestCellGroup({hasBorder: false}) {
								IBestField({
									formId: this.formId,
									prop: 'name',
									value: this.form.name!!,
									label: "姓名",
									placeholder: "请输入姓名",
									rules:[
										{ required: true, message: '请输入姓名' },
										{ min: 3, max: 10, message: '姓名长度在3-10个字符之间' }
									]
								})
								IBestField({
									formId: this.formId,
									type: "number",
									prop: 'phone',
									value: this.form.phone!!,
									label: "手机号",
									placeholder: "请输入手机号",
									hasBorder: false,
									rules: [
										{ required: true, message: '请输入手机号' }
									]
								})
							}
							IBestButton({
								text: "设置值",
								type: 'primary',
								buttonSize: 'large',
								onBtnClick: () => {
									this.controller1.setFormValues({
										"name": "测试",
										"phone": 123456
									})
								}
							})
							IBestButton({
								text: "验证姓名",
								type: 'primary',
								buttonSize: 'large',
								onBtnClick: () => {
									this.controller.validateField("name").then(res => {
										if(res.valid){
											IBestToast.show("验证成功")
										} else {
											IBestToast.show({
												message: `${res.field.label}验证失败`
											})
										}
									})
								}
							})
							IBestButton({
								text: "提交",
								type: 'primary',
								buttonSize: 'large',
								onBtnClick: () => {
									this.controller.validate().then(res => {
										if(res.valid){
											IBestToast.show("验证成功")
										} else {
											let labels: string[] = res.fields.map(item => item.label)
											IBestToast.show({
												message: `${labels.join(',')}验证失败`
											})
										}
									})
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义校验规则', titlePaddingLeft: SPACE.MD }) {
						IBestForm({
							formId: this.formId1,
							rules: this.rules1,
							controller: this.controller1
						}){
							IBestCellGroup({hasBorder: false}) {
								IBestField({
									formId: this.formId1,
									prop: 'value1',
									value: this.form1.value1!!,
									label: "正则校验",
									placeholder: "正则校验"
								})
								IBestField({
									formId: this.formId1,
									prop: 'value2',
									value: this.form1.value2!!,
									label: "函数校验",
									placeholder: "返回true/false"
								})
								IBestField({
									formId: this.formId1,
									prop: 'value3',
									value: this.form1.value3!!,
									label: "函数校验",
									placeholder: "返回验证信息"
								})
								IBestField({
									formId: this.formId1,
									prop: 'value4',
									value: this.form1.value4!!,
									label: "异步校验",
									placeholder: "异步函数校验",
									hasBorder: false
								})
							}
							IBestButton({
								text: "提交",
								type: 'primary',
								buttonSize: 'large',
								onBtnClick: () => {
									this.controller1.validate((valid) => {
										if (valid) {
											IBestToast.show("验证成功")
										}
									})
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义表单项类型', titlePaddingLeft: SPACE.MD }) {
						IBestForm({
							formId: this.formId2,
							rules: this.rules2,
							controller: this.controller2
						}){
							IBestCellGroup({hasBorder: false}) {
								IBestField({
									formId: this.formId2,
									prop: 'value1',
									value: this.form2.value1!!,
									label: "开关",
									customRightContent: (): void => this.switchContent()
								})
								IBestField({
									formId: this.formId2,
									prop: 'value2',
									value: this.form2.value2!!,
									label: "复选框",
									rules: this.form2.value1 ? [{required: true, message: '请选择'}] : [],
									customRightContent: (): void => this.checkboxContent()
								})
								IBestField({
									formId: this.formId2,
									prop: 'value3',
									value: this.form2.value3!!,
									label: "复选框组",
									required: this.form2.value1,
									customRightContent: (): void => this.checkboxGroupContent()
								})
								IBestField({
									formId: this.formId2,
									prop: 'value4',
									value: this.form2.value4!!,
									label: "单选框",
									customRightContent: (): void => this.radioContent()
								})
								IBestField({
									formId: this.formId2,
									prop: 'value5',
									value: this.form2.value5!!,
									label: "步进器",
									customRightContent: (): void => this.stepperContent()
								})
								IBestField({
									formId: this.formId2,
									prop: 'value6',
									value: this.form2.value6!!,
									showValue: this.selectValue,
									label: "选择城市",
									placeholder: "请选择城市",
									isLink: true,
									onFieldClick: () => {
										this.visible = true
									}
								})
								IBestField({
									formId: this.formId2,
									prop: 'value7',
									value: this.form2.value7!!,
									label: "日历",
									placeholder: "请选择日期",
									isLink: true,
									onFieldClick: () => {
										this.visible1 = true
									}
								})
								IBestField({
									formId: this.formId2,
									prop: 'value8',
									value: this.form2.value8!!,
									label: "上传图片",
									hasBorder: false,
									customRightContent: (): void => this.uploadImg()
								})
							}
							IBestButton({
								text: "设置值",
								type: 'primary',
								buttonSize: 'large',
								onBtnClick: () => {
									this.controller2.setFormValues({
										"value1": true,
										"value2": true,
										"value3": ['1'],
										"value4": true,
										"value6": ["320000","320500","320583"],
										"value7": '2025-08-25'
									})
									this.selectValue = "江苏省,苏州市,昆山市"
								}
							})
							IBestButton({
								text: "提交",
								type: 'primary',
								buttonSize: 'large',
								onBtnClick: () => {
									this.controller2.validate((valid) => {
										if (valid) {
											IBestDialogUtil.open({
												title: "表单值",
												message: JSON.stringify(this.controller2.getFormValues())
											})
										}
									})
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '动态表单验证', titlePaddingLeft: SPACE.MD }) {
						IBestForm({
							formId: this.formId3,
							rules: this.rules3,
							controller: this.controller3
						}){
							IBestCellGroup({hasBorder: false}){
								IBestField({
									formId: this.formId3,
									prop: 'sex',
									value: this.form3.sex,
									label: "性别",
									hasBorder: this.form3.sex != '',
									customRightContent: (): void => this.radioContent1()
								})
								if(this.form3.sex == 1){
									IBestField({
										formId: this.formId3,
										prop: 'info1',
										value: this.form3.info1!!,
										label: "男生信息",
										placeholder: "请输入男生信息",
										hasBorder: false
									})
								}else if(this.form3.sex == 2){
									IBestField({
										formId: this.formId3,
										prop: 'info2',
										value: this.form3.info2!!,
										label: "女生信息",
										placeholder: "请输入女生信息",
										hasBorder: false
									})
								}
								ForEach(this.form3.list, (item: Subject, index) => {
									subjectItem({
										item: item,
										index: index,
										formId: this.formId3,
										delete: (): void => this.deleteContent(index)
									})
								})
							}
							IBestButton({
								text: "添加学科",
								type: "primary",
								buttonSize: 'large',
								onBtnClick: () => {
									this.form3.list.push(new Subject())
								}
							})
							IBestButton({
								text: "提交",
								type: 'primary',
								buttonSize: 'large',
								onBtnClick: () => {
									this.controller3.validate(valid => {
										if (valid) {
											IBestDialogUtil.open({
												title: "表单值",
												message: JSON.stringify(this.controller3.getFormValues())
											})
										}
									})
								}
							})
						}
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
			.padding({ left: SPACE.MD, right: SPACE.MD })
			// 选择城市
			IBestCascader({
				visible: this.visible!!,
				options: this.options,
				value: this.form2.value6!!,
				onConfirm: value => {
					this.selectValue = value.map(item => item.text).join(',')
				}
			})
			// 日历
			IBestCalendarDialog({
				visible: this.visible1!!,
				onConfirm: value => {
					this.form2.value7 = value[0].dateStr
				}
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}

@ComponentV2
struct subjectItem{
	@Param @Require item: Subject
	@Param @Require index: number
	@Param @Require formId: string
	@Local visible: boolean = false
	@Event delete: (index: number) => void = () => {}
	private options: IBestPickerOption[] = [
		{ text: '语文', value: '1' },
		{ text: '数学', value: '2' },
		{ text: '英语', value: '3' },
		{ text: '物理', value: '4' },
		{ text: '化学', value: '5' },
		{ text: '生物', value: '6' }
	]
	@Builder pickerBuilder(){
		IBestPicker({
			options: this.options,
			title: "请选择学科",
			visibleItemCount: 5,
			onConfirm: (selectedValues, selectTexts) => {
				this.visible = false
				this.item.type = selectedValues[0] as string
				this.item.name = selectTexts.join('-')
			},
			onCancel: () => {
				this.visible = false
			}
		})
	}
	@Builder contentBuilder(){
		IBestCellGroup({title: `学科${this.index+1}(左滑删除)`, hasBorder: false}){
			IBestField({
				formId: this.formId,
				prop: `type.${this.index}`,
				label: '学科',
				value: this.item.name,
				placeholder: "请选择学科",
				isLink: true,
				onFieldClick: () => {
					this.visible = true
				}
			})
			IBestField({
				formId: this.formId,
				prop: `score.${this.index}`,
				label: "分数",
				value: this.item.score!!,
				type: "number",
				placeholder: "请输入分数",
				hasBorder: false
			})
			IBestPopup({
				visible: this.visible!!,
				popupAlign: "bottom",
				contentBuilder: (): void => this.pickerBuilder()
			})
		}
	}
	@Builder delBuilder(){
		IBestButton({
			type: "danger",
			round: true,
			text: "删除",
			onBtnClick: () => {
				this.delete(this.index)
			}
		}).margin({left: SPACE.SM, right: SPACE.SM, top: 40})
	}

	build() {
		IBestSwipeCell({
			defaultContent: (): void => this.contentBuilder(),
			rightContent: (): void => this.delBuilder()
		})
	}
}