import { IBestIcon, IBestProgress, IBestStringNumber } from '../../../../../Index'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { emitter } from '../../utils/EventEmitter'
import { convertDimensionsWidthUnit, getComponentsInfo, getEventName, getSizeByUnit } from '../../utils/utils'
import { IBestStepsColor } from './color'
import { COMPONENT_NAME, IBestStepConfig, IBestStepMarkType, STEPS_EVENT_NAME } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestStorageKey } from '../../model/Global.type'

@ComponentV2
export struct IBestSteps{
	/**
	 * 分组id
     */
	@Param @Require groupId: IBestStringNumber
	/**
	 * 当前激活的步骤索引
     */
	@Param active: number = 0
	/**
	 * 背景色
	 * @since 2.1.3
	 */
	@Param bgColor: ResourceColor = IBestStepsColor.bgColor
	/**
	 * 步骤条方向
     */
	@Param placeDirection: Axis = Axis.Horizontal
	/**
	 * 步骤标记类型
     */
	@Param type: IBestStepMarkType = 'num'
	/**
	 * 点大小
     */
	@Param dotSize: IBestStringNumber = convertDimensionsWidthUnit(6)
	/**
	 * 非激活底部图标, 仅type为 icon 时有效
     */
	@Param inactiveIcon: ResourceStr = ""
	/**
	 * 激活底部图标, 仅type为 icon 时有效
     */
	@Param activeIcon: ResourceStr = ""
	/**
	 * 图标大小, 仅type为 icon 时有效
     */
	@Param iconSize: IBestStringNumber = convertDimensionsWidthUnit(14)
	/**
	 * 未激活颜色
     */
	@Param inactiveColor: ResourceColor = IBestStepsColor.inactiveColor
	/**
	 * 激活颜色
     */
	@Param activeColor: ResourceColor = ""
	/**
	 * 自定义内容
     */
	@BuilderParam defaultBuilder: CustomBuilder

	@Local uniId: number = 0
	@Local percentContentSize: number = 0
	@Local percentContentHeight: number = 0
	@Local percent: number = 0
	allSteps: number[] = []
	private uiContext = this.getUIContext()

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		emitter.on(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_ALL_STEPS, this.groupId), this.uniId, (uniId: number): void => this.saveSteps(uniId))
	}
	onDidBuild(): void {
		setTimeout(() => {
			if(this.allSteps.length){
				emitter.emit(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_CONFIG, this.groupId), this.allSteps, this.active, {
					placeDirection: this.placeDirection,
					type: this.type,
					dotSize: this.dotSize,
					inactiveIcon: this.inactiveIcon,
					activeIcon: this.activeIcon,
					iconSize: this.iconSize,
					activeColor: this.activeColor,
					inactiveColor: this.inactiveColor
				})
				this.percent = this.active / (this.allSteps.length - 1) * 100
				setTimeout(() => {
					let arr: number[] = []
					this.allSteps.forEach((_, index) => {
						arr.push(getComponentsInfo(this.uiContext, `ibest_steps_mark_${this.groupId}_${index}`).width)
					})
					this.percentContentSize = Math.max(...arr)
					emitter.emit(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_MAX_MARK_SIZE, this.groupId), this.percentContentSize)
					if(this.placeDirection == Axis.Vertical){
						let stepHeightArr: number[] = []
						for (let i = 0; i < this.allSteps.length - 1; i++) {
							stepHeightArr.push(getComponentsInfo(this.uiContext, `ibest_step_item_${this.groupId}_${i}`).height)
						}
						this.percentContentHeight = stepHeightArr.reduce((a, b) => a + b, 0)
					}
				}, 80)
			}
		}, 50)
	}
	// 保存步骤id
	saveSteps(uniId: number){
		if(!this.allSteps.includes(uniId)){
			this.allSteps.push(uniId)
		}
	}
	// 索引变化
	@Monitor("active")
	activeChange(){
		let percent = this.active / (this.allSteps.length - 1) * 100
		let oldPercent = this.percent
		this.percent = percent
		setTimeout(() => {
			emitter.emit(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.ACTIVE_CHANGE, this.groupId), this.active)
		}, percent > oldPercent ? 280 : 0)
	}
	// 获取激活颜色
	getActiveColor(){
		return this.activeColor || IBestStepsColor.activeColor
	}
	build() {
		if(this.placeDirection == Axis.Vertical){
			Stack({alignContent: Alignment.TopStart}){
				Column(){
					Column(){
						IBestProgress({
							value: this.percent!!,
							lineWidth: 2,
							bgColor: IBestStepsColor.borderColor,
							color: this.getActiveColor(),
							showText: false
						})
					}
					.width(this.percentContentHeight)
					.position({x: this.percentContentSize / 2, y: 0})
					.rotate({z: 1, angle: 90, centerX: 0, centerY: 1})
				}
				.width(this.percentContentSize)
				.height(this.percentContentHeight)
				Column(){
					if(this.defaultBuilder){
						this.defaultBuilder()
					}
				}
				.width(CONTAINER_SIZE.FULL)
				.alignItems(HorizontalAlign.Start)
				.id(`ibest_steps_right_${this.groupId}`)
			}
			.width(CONTAINER_SIZE.FULL)
			.backgroundColor(this.bgColor)
		}else {
			Stack({alignContent: Alignment.Top}){
				Row(){
					IBestProgress({
						value: this.percent!!,
						lineWidth: 2,
						bgColor: IBestStepsColor.borderColor,
						color: this.getActiveColor(),
						showText: false
					})
				}
				.height(this.percentContentSize)
				Row(){
					if(this.defaultBuilder){
						this.defaultBuilder()
					}
				}
				.width(CONTAINER_SIZE.FULL)
				.justifyContent(FlexAlign.SpaceBetween)
			}
			.width(CONTAINER_SIZE.FULL)
			.backgroundColor(this.bgColor)
			.opacity(this.percentContentSize ? 1 : 0)
		}
	}
}

@ComponentV2
export struct IBestStep{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 分组id
	 */
	@Param @Require groupId: IBestStringNumber
	/**
	 * 标题
     */
	@Param title: ResourceStr = ''
	/**
	 * 描述
     */
	@Param description: ResourceStr = ''
	/**
	 * 步骤标记类型
	 */
	@Param type: IBestStepMarkType | '' = ''
	/**
	 * 点大小
	 */
	@Param dotSize: IBestStringNumber = ""
	/**
	 * 非激活底部图标, 仅type为 icon 时有效
	 */
	@Param inactiveIcon: ResourceStr = ""
	/**
	 * 激活底部图标, 仅type为 icon 时有效
	 */
	@Param activeIcon: ResourceStr = ""
	/**
	 * 图标大小, 仅type为 icon 时有效
	 */
	@Param iconSize: IBestStringNumber = ""
	/**
	 * 未激活颜色
	 */
	@Param inactiveColor: ResourceColor = ""
	/**
	 * 激活颜色
	 */
	@Param activeColor: ResourceColor = ""
	/**
	 * 自定义内容
	 */
	@BuilderParam defaultBuilder: CustomBuilder

	@Local uniId: number = 0
	@Local allSteps: number[] = []
	@Local index: number = 0
	@Local active: number = 0
	@Local config: IBestStepConfig = {} as IBestStepConfig
	@Local maxMarkWidth: number = 0

	@Builder stepContent(){
		Row() {
			if (this.config.type == 'dot') {
				Row()
					.width(getSizeByUnit(this.config.dotSize))
					.aspectRatio(1)
					.borderRadius(this.baseStyle.borderRadiusMax)
					.backgroundColor(this.getActiveColor())
					.id(this.getMarkId())
			} else if (this.config.type == 'icon') {
				Row() {
					IBestIcon({
						name: this.isActive() ? this.config.activeIcon : this.config.inactiveIcon,
						iconSize: this.config.iconSize,
						color: this.getActiveColor()
					})
				}
				.backgroundColor(IBestStepsColor.bgColor)
				.id(this.getMarkId())
			} else if (this.config.type == 'num') {
				Row() {
					Text((this.index + 1).toString())
						.fontSize(this.baseStyle.fontSizeSm)
						.fontColor(this.getActiveColor())
				}
				.padding({left: 4, right: 4})
				.aspectRatio(1)
				.borderRadius(this.baseStyle.borderRadiusMax)
				.border({ width: 2, color: this.isActive() ? this.baseStyle.primary : IBestStepsColor.borderColor })
				.justifyContent(FlexAlign.Center)
				.backgroundColor(IBestStepsColor.bgColor)
				.id(this.getMarkId())
			}
		}
		.width(this.maxMarkWidth || "auto")
		.aspectRatio(1)
		.justifyContent(FlexAlign.Center)
		.alignItems(VerticalAlign.Top)
		if(this.defaultBuilder){
			this.defaultBuilder()
		}else {
			if(this.title){
				Text(this.title)
					.fontSize(this.baseStyle.fontSizeSm)
					.fontColor(this.getActiveColor())
			}
			if(this.description){
				Text(this.description)
					.fontSize(this.baseStyle.fontSizeXs)
					.fontColor(this.getActiveColor())
			}
		}
	}

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		emitter.on(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_CONFIG, this.groupId), this.uniId, (steps: number[], active: number, data: IBestStepConfig): void => this.saveConfig(steps, active, data))
		emitter.on(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.ACTIVE_CHANGE, this.groupId), this.uniId, (active: number): void => {
			this.active = active
		})
		emitter.on(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_MAX_MARK_SIZE, this.groupId), this.uniId, (size: number): void => {
			this.maxMarkWidth = size
		})
		emitter.emit(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_ALL_STEPS, this.groupId), this.uniId)
	}
	aboutToDisappear(): void {
		emitter.off(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_CONFIG, this.groupId), this.uniId)
		emitter.off(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.ACTIVE_CHANGE, this.groupId), this.uniId)
		emitter.off(getEventName(COMPONENT_NAME, STEPS_EVENT_NAME.GET_MAX_MARK_SIZE, this.groupId), this.uniId)
	}
	// 保存配置信息
	saveConfig(steps: number[], active: number, data: IBestStepConfig){
		this.allSteps = steps
		this.active = active
		this.index = steps.indexOf(this.uniId)
		this.config = {
			placeDirection: data.placeDirection,
			type: this.type || data.type,
			dotSize: this.dotSize || data.dotSize,
			inactiveIcon: this.inactiveIcon || data.inactiveIcon,
			activeIcon: this.activeIcon || data.activeIcon,
			iconSize: this.iconSize || data.iconSize,
			inactiveColor: this.inactiveColor || data.inactiveColor,
			activeColor: this.activeColor || data.activeColor
		}
	}
	// 获取是否是第一个
	isFirstStep(): boolean{
		return this.uniId == this.allSteps[0]
	}
	// 获取是否是最后一个步骤
	isLastStep(): boolean{
		return this.uniId == this.allSteps[this.allSteps.length - 1]
	}
	// 当前是否激活
	isActive(): boolean{
		return this.active >= this.index
	}
	// 是否是竖向排列
	isVertical(): boolean{
		return this.config.placeDirection == Axis.Vertical
	}
	// 获取激活颜色
	getActiveColor(){
		return this.isActive() ? (this.config.activeColor || IBestStepsColor.activeColor) : this.config.inactiveColor
	}
	// 生成id
	getMarkId(){
		return `ibest_steps_mark_${this.groupId}_${this.index}`
	}
	build() {
		if(this.isVertical()){
			Row({space: this.baseStyle.spaceXs as string}){
				this.stepContent()
			}
			.width(CONTAINER_SIZE.FULL)
			.alignItems(VerticalAlign.Top)
			.padding({bottom: this.baseStyle.spaceSm as string})
			.id(`ibest_step_item_${this.groupId}_${this.index}`)
		}else {
			Column({space: this.baseStyle.spaceXs as string}){
				this.stepContent()
			}
			.layoutWeight(1)
			.alignItems(this.isFirstStep() ? HorizontalAlign.Start : this.isLastStep() ? HorizontalAlign.End : HorizontalAlign.Center)
		}
	}
}