import { clamp, getComponentsInfo, getSizeByUnit } from '../../utils/utils'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { RateOption } from './index.type'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestRate {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 值
	 */
	@Param @Require value: number
	/**
	 * 图标总数
	 */
	@Param count: number = 5
	/**
	 * 图标大小
	 */
	@Param iconSize: IBestStringNumber = 20
	/**
	 * 间距
	 */
	@Param space: IBestStringNumber = 4
	/**
	 * 选中图标
	 */
	@Param activeIcon: ResourceStr = $r("app.media.ibest_icon_star_o")
	/**
	 * 未选中图标
	 */
	@Param inactiveIcon: ResourceStr = $r("app.media.ibest_icon_star")
	/**
	 * 选中颜色
	 */
	@Param activeColor: ResourceColor = this.baseStyle.danger as string
	/**
	 * 未选中颜色
	 */
	@Param inactiveColor: ResourceColor = GRAY_COLOR.GRAY_5
	/**
	 * 是否允许半选
	 */
	@Param allowHalf: boolean = false
	/**
	 * 禁用
	 */
	@Param disabled: boolean = false
	/**
	 * 只读
	 */
	@Param readOnly: boolean = false
	/**
	 * 禁用时颜色
	 */
	@Param disabledColor: ResourceColor = GRAY_COLOR.GRAY_5
	/**
	 * 是否可清空
	 */
	@Param clearable: boolean = false
	/**
	 * 是否可通过滑动手势选择评分
	 */
	@Param isTouchable: boolean = true
	/**
	 * 分值变化回调
	 */
	@Event onChange: (value: number) => void = () => {}
	@Event $value: (value: number) => void = () => {}

	// 唯一id
	@Local uniId: number = 0
	// 选项列表
	@Local optionsList: RateOption[] = []
	// 容器宽度
	@Local containerWidth: number = 0
	// 单个图标宽度
	@Local iconWidth: number = 0
	// 图标间距
	@Local iconSpace: number = 0
	// 手势初始位置
	@Local startX: number = 0
	private context = this.getUIContext()
	private panOption: PanGestureOptions = new PanGestureOptions({
		fingers: 1,
		distance: 1
	})

	@Builder rateItem(item: RateOption, index: number){
		Stack({ alignContent: Alignment.Start }) {
			Image(this.inactiveIcon)
				.width(CONTAINER_SIZE.FULL)
				.height(CONTAINER_SIZE.FULL)
				.fillColor(this.inactiveColor)
				.draggable(false)
				.visibility(item.value == 1 ? Visibility.None : Visibility.Visible)
			Row() {
				Image(this.activeIcon)
					.width(getSizeByUnit(this.iconSize))
					.height(getSizeByUnit(this.iconSize))
					.draggable(false)
					.fillColor(this.disabled ? this.disabledColor : this.activeColor)
			}
			.width(item.value*100 + "%")
			.height(CONTAINER_SIZE.FULL)
			.clip(true)
		}
		.width(getSizeByUnit(this.iconSize))
		.aspectRatio(1)
		.id(`ibest_rate_${this.uniId}_${index}`)
		.onClick(event => {
			this.rateClick(event, index)
		})
	}

	aboutToAppear(): void {
		this.init()
	}
	// 初始化
	init(){
		let value = clamp(this.value, 0, this.count)
		this.uniId = this.getUniqueId()
		if(value.toString().indexOf(".") > -1 && !this.allowHalf){
			value = Math.ceil(value)
		}
		this.optionsList = Array(this.count).fill(0).map((_: number, i: number) => {
			let val = value - i
			return new RateOption(val > 1 ? 1 : val > 0 ? val : 0)
		})
	}
	// 获取组件容器宽度
	getContentWidth(){
		this.containerWidth = getComponentsInfo(this.context, `ibest_rate_${this.uniId}`).width
		this.iconWidth = getComponentsInfo(this.context, `ibest_rate_${this.uniId}_0`).width
		this.iconSpace = (this.containerWidth - this.iconWidth*this.count)/(this.count - 1)
	}
	// 点击
	rateClick(event: ClickEvent, index: number){
		let x = event.x
		let value = 0
		if(this.allowHalf){
			value = index + (x <= this.iconWidth/2 ? 0.5 : 1)
		}else{
			value = index + 1
		}
		value = value == this.value && this.clearable ? 0 : value
		this.$value(value)
		this.onChange(value)
	}
	// 刷新optionsList
	@Monitor("value")
	refreshList(){
		let value = this.value
		this.optionsList.forEach((item: RateOption, i: number) => {
			let val = value - i
			item.value = val > 1 ? 1 : val > 0 ? val : 0
		})
	}
	// 手指移动
	onFingerMove(event: GestureEvent){
		let offsetX = this.startX + event.offsetX
		let value = clamp(Math.ceil(offsetX/(this.iconWidth + this.iconSpace)), 0, this.count)
		this.$value(value)
		this.onChange(value)
	}
	build() {
		Row({ space: getSizeByUnit(this.space) }){
			ForEach(this.optionsList, (item: RateOption, index: number) => {
				this.rateItem(item, index)
			}, (_: RateOption, index) => index + "")
		}
		.id(`ibest_rate_${this.uniId}`)
		.enabled(!(this.disabled || this.readOnly))
		.onAppear(() => {
			setTimeout(() => {
				this.getContentWidth()
			}, 10)
		})
		.onVisibleAreaChange([0,1], (isExpanding: boolean) => {
			if(isExpanding && !this.containerWidth){
				this.getContentWidth()
			}
		})
		.gesture(
			PanGesture(this.panOption)
				.onActionStart((event: GestureEvent) => {
					this.startX = event.fingerList[0].localX
				})
				.onActionUpdate((event: GestureEvent) => {
					this.isTouchable && this.onFingerMove(event)
				})
				.onActionEnd(() => {
					this.startX = 0
				})
		)
	}
}