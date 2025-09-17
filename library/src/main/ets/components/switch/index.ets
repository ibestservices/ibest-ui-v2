import { IBestStorageKey, IBestAwaitable, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit, handleBeforeFunction } from '../../utils/utils'
import { IBestLoading } from '../loading'
import { IBestSwitchColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestSwitch {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 开关默认选中的状态
	 */
	@Param @Require value: boolean
	/**
	 * 开关按钮的尺寸
	 */
	@Param switchSize: IBestStringNumber = convertDimensionsWidthUnit(26)
	/**
	 * 打开时的背景色
	 */
	@Param activeColor: ResourceColor = ''
	/**
	 * 关闭时的背景色
	 */
	@Param inactiveColor: ResourceColor = IBestSwitchColor.bg
	/**
	 * 是否禁用 禁用状态下开关不可点击
	 */
	@Param disabled: boolean = false
	/**
	 * 是否为加载状态 加载状态下开关不可点击
	 */
	@Param loading: boolean = false
	/**
	 * 打开时的loading颜色
	 */
	@Param loadingActiveColor: ResourceColor = ''
	/**
	 * 关闭时的loading颜色
	 */
	@Param loadingInactiveColor: ResourceColor = ''
	/**
	 * 自定义按钮的内容
	 */
	@BuilderParam buttonBuilder: CustomBuilder
	/**
	 * 改变的回调
	 */
	@Event onChange: (value: boolean) => void = () => {}
	/**
	 * 改变前的回调
	 */
	@Event beforeChange?: (value: boolean) => IBestAwaitable = undefined
	/**
	 * 点击的回调
	 */
	@Event onSwitchClick: () => void = () => {}
	@Event $value: (value: boolean) => void = () => {}

	@Local uniId: number = 0
	@Local switchBarSize: number = 0
	private uiContext = this.getUIContext()

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
	}
	initSize(){
		setTimeout(() => {
			this.switchBarSize = getComponentsInfo(this.uiContext, `ibest_switch_${this.uniId}`).width
		}, 50)
	}
	// 改变的回调
	async handleChange() {
		const nextValue = !this.value
		let status = await handleBeforeFunction(this.beforeChange, nextValue)
		if(!status){
			return
		}
		this.$value(nextValue)
		this.onChange(nextValue)
	}
	// 获取激活的颜色
	getActiveColor() {
		return this.activeColor || this.baseStyle.primary as string
	}
	build() {
		Column() {
			Column() {
				if (this.buttonBuilder) {
					this.buttonBuilder()
				} else if (this.loading && this.switchBarSize) {
					IBestLoading({
						loadingSize: this.switchBarSize / 1.5,
						loadingColor: this.value ? this.loadingActiveColor || this.getActiveColor() : this.loadingInactiveColor || this.activeColor
					})
				}
			}
			.width(getSizeByUnit(this.switchSize))
			.height(getSizeByUnit(this.switchSize))
			.alignItems(HorizontalAlign.Center)
			.justifyContent(FlexAlign.Center)
			.borderRadius(this.baseStyle.borderRadiusMax)
			.shadow({
				color: 'rgba(0, 0, 0, 0.1)',
				offsetY: this.uiContext.px2vp(3),
				radius: 1
			})
			.backgroundColor(IBestSwitchColor.white)
			.translate({
				x: this.value ? this.switchBarSize - 4 : 0
			})
			.id(`ibest_switch_${this.uniId}`)
			.animation({
				duration: this.baseStyle.animationDuration as number,
			})
		}
		.alignItems(HorizontalAlign.Start)
		.justifyContent(FlexAlign.Center)
		.width(this.switchBarSize * 2)
		.padding(2)
		.backgroundColor(this.value ? this.getActiveColor() : this.inactiveColor)
		.borderRadius(this.baseStyle.borderRadiusMax)
		.enabled(!this.disabled && !this.loading)
		.opacity(this.disabled ? 0.5 : 1)
		.animation({
			duration: this.baseStyle.animationDuration as number
		})
		.onClick(() => {
			this.handleChange()
			this.onSwitchClick()
		})
		.onAppear(() => {
			setTimeout(() => {
				this.initSize()
			}, 20)
		})
		.onVisibleAreaChange([0,1], (isExpanding: boolean) => {
			if(isExpanding && !this.switchBarSize){
				this.initSize()
			}
		})
	}
}