import { clamp, convertDimensionsWidthUnit, getComponentsInfo, getResourceStr, getSizeByUnit } from '../../utils/utils';
import { getDefaultBaseStyle } from '../../theme-chalk/src';
import { CONTAINER_SIZE } from '../../theme-chalk/src/container';
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';
import { ColumnType, IBestPickerOption } from './index.type';
import { IBestPickerColor } from './color';
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { AppStorageV2 } from '@kit.ArkUI';
@Extend(Text) function ibestPickerItemStyle(itemHeight: IBestStringNumber, fontSize: IBestStringNumber){
	.width(CONTAINER_SIZE.FULL)
	.height(getSizeByUnit(itemHeight))
	.padding({ left: getDefaultBaseStyle().spaceBase, right: getDefaultBaseStyle().spaceBase })
	.fontSize(getSizeByUnit(fontSize, true))
	.fontColor(IBestPickerColor.textColor)
	.align(Alignment.Center)
	.textAlign(TextAlign.Center)
	.maxLines(1)
	.textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Text) function ibestHorizontalPickerItemStyle(itemWidth: IBestStringNumber, fontSize: IBestStringNumber){
	.width(getSizeByUnit(itemWidth))
	.padding({ left: getDefaultBaseStyle().spaceBase, right: getDefaultBaseStyle().spaceBase })
	.fontSize(getSizeByUnit(fontSize, true))
	.textAlign(TextAlign.Center)
	.maxLines(1)
	.textOverflow({ overflow: TextOverflow.Ellipsis })
}


// 惯性滑动思路:
// 在手指离开屏幕时，如果和上一次 move 时的间隔小于 `MOMENTUM_TIME` 且 move
// 距离大于 `MOMENTUM_DISTANCE` 时，执行惯性滑动
const MOMENTUM_TIME = 300
const MOMENTUM_DISTANCE = 30
const swipeDuration = 500


@ComponentV2
export struct IBestPicker{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE) as IBestUIBaseStyleObjType
	@Local colorMode: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.COLOR_MODE)!
	/**
	 * 分组id
	 */
	@Param groupId: string = ""
	/**
	 * 当前选中的值, 支持双向绑定
	 */
	@Param value: IBestStringNumber[] = []
	/**
	 * 选项列表
	 */
	@Param @Require options: IBestPickerOption[] | IBestPickerOption[][]
	/**
	 * 标题
	 */
	@Param title: ResourceStr = ""
	/**
	 * 单项高度
	 */
	@Param itemHeight: IBestStringNumber = convertDimensionsWidthUnit(44)
	/**
	 * 确认按钮文字
	 */
	@Param confirmText: ResourceStr = $r("app.string.ibest_text_confirm")
	/**
	 * 取消按钮文字
	 */
	@Param cancelText: ResourceStr = $r("app.string.ibest_text_cancel")
	/**
	 * 是否显示顶部栏
	 */
	@Param showToolBar: boolean = true
	/**
	 * 可见选项数量
  	 */
	@Param visibleItemCount: number = 6
	/**
	 * 是否横向
	 */
	@Param horizontal: boolean = false
	/**
	 * 单项宽度, 仅横向时生效
     */
	@Param itemWidth: IBestStringNumber = convertDimensionsWidthUnit(44)
	/**
	 * 整体高度, 仅横向时生效
     */
	@Param contentHeight: IBestStringNumber = convertDimensionsWidthUnit(44)
	/**
	 * 选项字体大小
     */
	@Param optionFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 确认按钮点击事件
	 */
	@Event onConfirm: (selectedValues: IBestStringNumber[], selectTexts: string[]) => void = () => {}
	/**
	 * 取消按钮点击事件
	 */
	@Event onCancel: () => void = () => {}
	/**
	 * 选中项改变事件
	 */
	@Event onChange: (selectedValues: IBestStringNumber[], selectTexts: string[], columnIndex: number) => void = () => {}
	@Event $value: (value: IBestStringNumber[]) => void = () => {}

	@Local uniId: number = 0
	// 列表类型
	@Local columnType: ColumnType = "multiple"
	// 每列选中索引
	@Local indexArr: number[] = []
	// 触摸滑动相关参数
	@Local touchStartTime: number = 0
	@Local startOffset: number = 0
	@Local momentumOffset: number = 0
	// 选项列表
	@Local columns: IBestPickerOption[][] = []
	// offset 列表
	@Local offsetList: number[] = []
	@Local itemCalcHeight: number = 0
	@Local itemCalcWidth: number = 0
	@Local leftWidth: number = 0
	@Local isReady: boolean = false
	private uiContext = this.getUIContext()

	@Styles ibestPickerColumnItemStyle(){
		.height(CONTAINER_SIZE.FULL)
		.layoutWeight(1)
		.monopolizeEvents(true)
	}
	@Styles ibestPickerRowItemStyle(){
		.width(CONTAINER_SIZE.FULL)
		.layoutWeight(1)
		.monopolizeEvents(true)
	}
	@Builder verticalBuilder(){
		Stack() {
			Row() {
				ForEach(this.columns, (item: IBestPickerOption[], index) => {
					Column() {
						ForEach(item, (e: IBestPickerOption, index: number) => {
							Text(e.text)
								.ibestPickerItemStyle(this.itemHeight, this.optionFontSize)
								.id(`ibest_picker_text_${this.uniId}_${index}`)
						})
					}
					.translate({ y: this.offsetList[index] + this.getBaseOffset() })
					.ibestPickerColumnItemStyle()
					.animation({
						duration: this.isReady ? swipeDuration : 0,
						curve: Curve.Ease
					})
				})
			}
			.width(CONTAINER_SIZE.FULL)
			.justifyContent(FlexAlign.Center)
			Column(){
				Row()
					.width(CONTAINER_SIZE.FULL)
					.height(`calc(50% - ${this.itemCalcHeight/2}vp)`)
					.linearGradient({
						angle: 180,
						colors: this.colorMode.value === 0 ? [["rgba(0,0,0,0.9)", 0.1], [ "rgba(0,0,0,0.5)", 1]] : [["rgba(255,255,255,0.9)", 0.1], [ "rgba(255,255,255,0.5)", 1]]
					})
					.border({ width: { bottom: 1 }, color: IBestPickerColor.borderColor })
				Row()
					.width(CONTAINER_SIZE.FULL)
					.height(`calc(50% - ${this.itemCalcHeight/2}vp)`)
					.linearGradient({
						angle: 0,
						colors: this.colorMode.value === 0 ? [["rgba(0,0,0,0.9)", 0.1], [ "rgba(0,0,0,0.5)", 1]] : [["rgba(255,255,255,0.9)", 0.1], [ "rgba(255,255,255,0.5)", 1]]
					})
					.border({ width: { top: 1 }, color: IBestPickerColor.borderColor })
			}
			.height(CONTAINER_SIZE.FULL)
			.justifyContent(FlexAlign.SpaceBetween)
			// 触摸层
			Row() {
				ForEach(this.columns, (item: IBestPickerOption[], index) => {
					Column()
						.ibestPickerColumnItemStyle()
						.gesture(
							PanGesture({
								fingers: 1,
								direction: PanDirection.Vertical,
								distance: 1
							})
								.onActionStart(() => {
									this.onTouchStart(index)
								})
								.onActionUpdate((event: GestureEvent) => {
									this.onTouchMove(event, index)
								})
								.onActionEnd(() => {
									this.onTouchEnd(index)
								})
						)
				})
			}
			.height(CONTAINER_SIZE.FULL)
			.justifyContent(FlexAlign.Center)
		}
		.height((this.itemCalcHeight || 44) * this.visibleItemCount)
		.clip(true)
	}

	@Builder horizontalBuilder(){
		Stack() {
			Column() {
				ForEach(this.columns, (item: IBestPickerOption[], index) => {
					Row() {
						ForEach(item, (e: IBestPickerOption) => {
							Text(e.text)
								.ibestHorizontalPickerItemStyle(this.itemWidth, this.optionFontSize)
								.id(`ibest_picker_text_${this.uniId}_${index}`)
						})
					}
					.translate({ x: this.offsetList[index] + this.getBaseOffset() })
					.ibestPickerRowItemStyle()
					.animation({
						duration: this.isReady ? swipeDuration : 0,
						curve: Curve.Ease
					})
				})
			}
			.height(CONTAINER_SIZE.FULL)
			.justifyContent(FlexAlign.Center)
			Row(){
				Row()
					.width(`calc(50% - ${this.itemCalcWidth/2}vp)`)
					.height(CONTAINER_SIZE.FULL)
					.linearGradient({
						angle: 90,
						colors: this.colorMode.value === 0 ? [["rgba(0,0,0,0.9)", 0.1], [ "rgba(0,0,0,0.5)", 1]] : [["rgba(255,255,255,0.9)", 0.1], [ "rgba(255,255,255,0.5)", 1]]
					})
					.border({ width: { right: 1 }, color: IBestPickerColor.borderColor })
					.id(`ibest_picker_left_${this.uniId}`)
				Row()
					.width(`calc(50% - ${this.itemCalcWidth/2}vp)`)
					.height(CONTAINER_SIZE.FULL)
					.linearGradient({
						angle: -90,
						colors: this.colorMode.value === 0 ? [["rgba(0,0,0,0.9)", 0.1], [ "rgba(0,0,0,0.5)", 1]] : [["rgba(255,255,255,0.9)", 0.1], [ "rgba(255,255,255,0.5)", 1]]
					})
					.border({ width: { left: 1 }, color: IBestPickerColor.borderColor })
			}
			.width(CONTAINER_SIZE.FULL)
			.justifyContent(FlexAlign.SpaceBetween)
			Column() {
				ForEach(this.columns, (item: IBestPickerOption[], index) => {
					Row()
						.ibestPickerRowItemStyle()
						.gesture(
							PanGesture({
								fingers: 1,
								direction: PanDirection.Horizontal,
								distance: 1
							})
								.onActionStart(() => {
									this.onTouchStart(index)
								})
								.onActionUpdate((event: GestureEvent) => {
									this.onTouchMove(event, index)
								})
								.onActionEnd(() => {
									this.onTouchEnd(index)
								})
						)
				})
			}
			.width(CONTAINER_SIZE.FULL)
			.height(CONTAINER_SIZE.FULL)
			.justifyContent(FlexAlign.Center)
		}
		.width(CONTAINER_SIZE.FULL)
		.height(getSizeByUnit(this.contentHeight))
		.clip(true)
	}

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		this.init()
	}
	// 获取列表类型
	getColumnType(): ColumnType{
		return Array.isArray(this.options[0]) ? "multiple" : "cascade"
	}
	// 初始化数据
	init(type?: string){
		this.columnType = this.getColumnType()
		this.columns = []
		if(this.columnType == "cascade") {
			if (this.value.length) {
				this.indexArr = Array(this.value.length).fill(0)
				this.offsetList = Array(this.value.length).fill(0)
				this.initWithSelectValue(0, this.options as IBestPickerOption[])
			} else {
				this.initWithEmptyValue([], this.options as IBestPickerOption[])
			}
		}else{
			this.initWidthMultiple(type)
		}
		this.initSize()
	}
	initSize(){
		this.isReady = false
		setTimeout(() => {
			if(this.horizontal){
				this.itemCalcWidth = getComponentsInfo(this.uiContext, `ibest_picker_text_${this.uniId}_0`).width
				setTimeout(() => {
					this.leftWidth = getComponentsInfo(this.uiContext, `ibest_picker_left_${this.uniId}`).width
				}, 50)
			}else{
				this.itemCalcHeight = getComponentsInfo(this.uiContext, `ibest_picker_text_${this.uniId}_0`).height
			}
			this.initOffset()
			setTimeout(() => {
				this.isReady = true
			}, swipeDuration)
		}, 0)
	}
	// 根据已选值 初始化索引位置
	initWithSelectValue(index: number, children: IBestPickerOption[]){
		if(this.value[index] != undefined && children && children.length){
			let i = children.findIndex(item => item.value == this.value[index])
			i = i > -1 ? i : children.length - 1
			this.columns.push(children)
			this.indexArr[index] = i
			this.initWithSelectValue(index+1, children[i].children!)
		}
	}
	// 初始化value
	initWithEmptyValue(arr: IBestStringNumber[], children: IBestPickerOption[]){
		if(children && children.length){
			this.columns.push(children)
			arr.push(children[0].value)
			this.initWithEmptyValue(arr, children[0].children!)
		}else{
			this.indexArr = Array(arr.length).fill(0)
			this.offsetList = Array(arr.length).fill(0)
			this.$value(arr)
		}
	}
	// 初始化多列类型
	initWidthMultiple(type?:string){
		let options = this.options as IBestPickerOption[][]
		if(!this.value.length){
			this.$value(Array(options.length).fill(0))
		}
		options.forEach((item, index) => {
			let i = item.findIndex(e => e.value == this.value[index])
			i = i > -1 ? i : 0
			this.indexArr[index] = i
			this.value[index] = item[i].value
			if(i > -1){
				if(type == "change"){
					this.value[index] = item[i].value
				}
			}
			this.columns.push(item)
		})
	}
	// 初始化多列位置
	initOffset(){
		if(this.value.length) {
			this.columnType = this.getColumnType()
			if (this.columnType == "cascade") {
				this.initCascadeOffset(0, this.options as IBestPickerOption[])
			} else {
				let options = this.options as IBestPickerOption[][]
				if (!this.offsetList.length) {
					this.offsetList = Array(this.value.length).fill(0)
				}
				options.forEach((item, index) => {
					let i = item.findIndex(e => e.value == this.value[index])
					i = i > -1 ? i : 0
					if (i > -1) {
						this.updateOffsetByIndex(index, i)
					}
				})
			}
		}
	}
	// 根据已选值 初始化索引位置
	initCascadeOffset(index: number, children: IBestPickerOption[]){
		if(this.value[index] != undefined && children && children.length){
			let i = children.findIndex(item => item.value == this.value[index])
			i = i > -1 ? i : children.length - 1
			this.updateOffsetByIndex(index, i)
			this.initCascadeOffset(index+1, children[i].children!)
		}
	}
	// 列表变化
	@Monitor("options.length")
	optionsChange(){
		this.init("change")
	}
	// 获取初始位置
	getBaseOffset(): number{
		if(this.horizontal){
			return this.leftWidth
		}else{
			return this.itemCalcHeight * (this.visibleItemCount-1) / 2
		}
	}
	// 通过偏移量获取索引
	getIndexByOffset(columnIndex: number, offset: number) {
		return clamp(Math.round(-offset / (this.horizontal ? this.itemCalcWidth : this.itemCalcHeight)), 0, this.columns[columnIndex].length - 1)
	}
	// 通过索引更新偏移量
	updateOffsetByIndex(columnIndex: number, index: number){
		const offset = - index * (this.horizontal ? this.itemCalcWidth : this.itemCalcHeight)
		this.offsetList[columnIndex] = offset
	}
	// 重置列表数据
	resetColumnOptions(columnIndex: number, i: number){
		// console.log("重置列表数据", columnIndex, i)
		this.columns.forEach((item, index, arr) => {
			if(index > columnIndex){
				this.offsetList[index] = 0
				this.indexArr[index] = 0
				if(columnIndex == 0){
					if(index - 1 == columnIndex){
						arr[index] = (this.options as IBestPickerOption[])[i].children || []
					}else{
						arr[index] = (arr[index-1][0].children || [])
					}
				}else{
					arr[index] = (arr[index-1][i].children || [])
				}
			}
		})
	}
	// 更新某一列offset
	updateOffset(columnIndex: number, offset: number){
		this.offsetList[columnIndex] = offset
	}
	// 获取某一列offset
	getOffset = (columnIndex: number): number => this.offsetList[columnIndex]
	// 手指接触屏幕
	onTouchStart(columnIndex: number){
		this.startOffset = this.getOffset(columnIndex)
		this.touchStartTime = Date.now()
		this.momentumOffset = this.startOffset
	}
	// 手指移动
	onTouchMove(event: GestureEvent, columnIndex: number): void {
		let bl = this.horizontal ? event.offsetX : event.offsetY
		let itemSize = this.horizontal ? this.itemCalcWidth : this.itemCalcHeight
		let newOffset = this.startOffset + bl
		let list = this.columns[columnIndex]
		if(bl > 0 && newOffset > itemSize){
			newOffset = itemSize
		}else if(bl < 0 && newOffset < - list.length * itemSize){
			newOffset = - list.length * itemSize
		}
		const now = Date.now()
		if (now - this.touchStartTime > MOMENTUM_TIME) {
			this.touchStartTime = now;
			this.momentumOffset = newOffset;
		}
		this.updateOffset(columnIndex, newOffset)
	}
	// 手指离开
	onTouchEnd(columnIndex: number): void {
		let offset = this.getOffset(columnIndex)
		let distance = offset - this.momentumOffset
		const duration = Date.now() - this.touchStartTime
		const startMomentum = duration < MOMENTUM_TIME && Math.abs(distance) > MOMENTUM_DISTANCE
		if (startMomentum) {	// 惯性滑动
			const speed = Math.abs(distance / duration)
			offset = offset + (speed / 0.03) * (distance < 0 ? -1 : 1)
		}
		const index = this.getIndexByOffset(columnIndex, offset)
		this.updateOffsetByIndex(columnIndex, index)
		if(this.indexArr[columnIndex] != index){	// 索引变更
			this.indexArr[columnIndex] = index
			// 重置后面项
			if(this.columnType == "cascade"){
				this.resetColumnOptions(columnIndex, index)
			}
			this.setValueByIndex()
			setTimeout(() => {
				this.onChange(this.value, this.getTextByIndex(), columnIndex)
			}, swipeDuration)
		}
	}
	// 根据索引设置value
	setValueByIndex(){
		this.$value(this.columns.map((item, index) => item[this.indexArr[index]].value))
	}
	// 根据索引获取值 文字
	getTextByIndex(): string[]{
		return this.columns.map((item, index) => getResourceStr(item[this.indexArr[index]].text))
	}

	build() {
		Column() {
			if(!this.groupId && this.showToolBar) {
				PickerHeader({
					value: this.value,
					title: this.title,
					cancelText: this.cancelText,
					confirmText: this.confirmText,
					onConfirm: this.onConfirm,
					onCancel: this.onCancel,
					getTextByIndex: (): string[] => this.getTextByIndex()
				})
			}
			if(this.horizontal){
				this.horizontalBuilder()
			}else{
				this.verticalBuilder()
			}
		}
		.width(CONTAINER_SIZE.FULL)
		.alignItems(HorizontalAlign.Start)
		.backgroundColor(IBestPickerColor.bgColor)
		.onVisibleAreaChange([0, 1], (isExpanding: boolean) => {
			if(isExpanding && !this.itemCalcHeight){
				this.initSize()
			}
		})
	}
}

@ComponentV2
struct PickerHeader{
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE) as IBestUIBaseStyleObjType
	@Param value: IBestStringNumber[] = []
	@Param @Require title: ResourceStr
	@Param @Require cancelText: ResourceStr
	@Param @Require confirmText: ResourceStr
	@Event onConfirm: (value: IBestStringNumber[], text: string[]) => void = () => {}
	@Event onCancel: () => void = () => {}
	@Event getTextByIndex: () => string[] = () => []
	build() {
		Stack({alignContent: Alignment.Center}) {
			Row(){
				Text(this.cancelText)
					.height(CONTAINER_SIZE.FULL)
					.fontSize(this.baseStyle.fontSizeMd)
					.fontColor(IBestPickerColor.cancelTextColor)
					.padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd })
					.onClick(() => {
						this.onCancel()
					})
				Text(this.confirmText)
					.height(CONTAINER_SIZE.FULL)
					.fontSize(this.baseStyle.fontSizeMd)
					.fontColor(this.baseStyle.primary)
					.padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd })
					.onClick(() => {
						this.onConfirm(this.value, this.getTextByIndex())
					})
			}
			.width(CONTAINER_SIZE.FULL)
			.height(convertDimensionsWidthUnit(44))
			.justifyContent(FlexAlign.SpaceBetween)
			Text(this.title)
				.constraintSize({ maxWidth: "50%" })
				.fontWeight(600)
				.fontSize(this.baseStyle.fontSizeLg)
				.fontColor(IBestPickerColor.textColor)
				.maxLines(1)
				.textOverflow({ overflow: TextOverflow.Ellipsis })
		}
	}
}