import { IBestPullRefreshStatus, IBestRefreshContentParams } from './index.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { IBestLoading } from '../loading'
import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit } from '../../utils/utils'
import { IBestPullRefreshColor } from './color'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'
@ComponentV2
export struct IBestPullRefresh {
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 是否处于加载状态
  	 */
	@Param @Require loading: boolean
	/**
	 * 当自定义内容包含List Grid Scroll组件时必传
	 */
	@Param scroller: Scroller = new Scroller()
	/**
	 * 下拉过程提示文案
	 */
	@Param pullingText: ResourceStr = $r("app.string.ibest_text_pulling")
	/**
	 * 下拉释放过程提示文案
     */
	@Param loosingText: ResourceStr = $r("app.string.ibest_text_loosing")
	/**
	 * 下拉加载过程提示文案
	 */
	@Param loadingText: ResourceStr = $r("app.string.ibest_text_loading")
	/**
	 * 下拉刷新成功提示文案
	 */
	@Param successText: ResourceStr = ""
	/**
	 * 下拉刷新成功提示展示时长(ms)
	 */
	@Param successDuration: number = 500
	/**
	 * 动画时长
	 */
	@Param duration: number = 300
	/**
	 * 顶部内容高度
	 */
	@Param headHeight: IBestStringNumber = convertDimensionsWidthUnit(50)
	/**
	 * 默认内容
     */
	@BuilderParam defaultContent: CustomBuilder
	/**
	 * 自定义下拉过程顶部内容
  	 */
	@BuilderParam pullingContent: ($$: IBestRefreshContentParams) => void
	/**
	 * 自定义下拉释放过程顶部内容
  	 */
	@BuilderParam loosingContent: ($$: IBestRefreshContentParams) => void
	/**
	 * 自定义下拉加载过程顶部内容
  	 */
	@BuilderParam loadingContent: CustomBuilder
	/**
	 * 自定义下拉刷新成功提示内容
	 */
	@BuilderParam successContent: CustomBuilder
	/**
	 * 是否启用上滑加载
     */
	@Param isEnableSlideUp: boolean = true
	/**
	 * 上滑过程提示文案
	 */
	@Param slidingUpText: ResourceStr = $r("app.string.ibest_text_slidingUp")
	/**
	 * 上滑释放过程提示文案
	 */
	@Param slideUpLoosingText: ResourceStr = $r("app.string.ibest_text_loosing")
	/**
	 * 上滑加载过程提示文案
	 */
	@Param slideUpLoadingText: ResourceStr = $r("app.string.ibest_text_loading")
	/**
	 * 上滑加载成功提示文案
	 */
	@Param slideUpSuccessText: ResourceStr = ""
	/**
	 * 刷新成功提示展示时长(ms)
	 */
	@Param slideUpSuccessDuration: number = 500
	/**
	 * 上滑加载动画时长
	 */
	@Param slideUpDuration: number = 300
	/**
	 * 顶部内容高度
	 */
	@Param bottomHeight: IBestStringNumber = convertDimensionsWidthUnit(50)
	/**
	 * 自定义上滑过程内容
	 */
	@BuilderParam slidingUpContent: ($$: IBestRefreshContentParams) => void
	/**
	 * 自定义上滑释放过程内容
	 */
	@BuilderParam slideUpLoosingContent: ($$: IBestRefreshContentParams) => void
	/**
	 * 自定义上滑加载过程内容
	 */
	@BuilderParam slideUpLoadingContent: CustomBuilder
	/**
	 * 自定义上滑加载成功提示内容
	 */
	@BuilderParam slideUpSuccessContent: CustomBuilder
	/**
	 * 触发下拉刷新/上滑加载时的回调
	 */
	@Event onRefresh: (direction: 'pull' | 'slideUp') => void = () => {}
	@Event $loading: (isLoading: boolean) => void = () => {}
	
	@Local uniId: number = 0
	@Local scrollTop: number = 0
	@Local isAtEnd: boolean = false
	@Local transY: number = 0
	@Local actionType: 'pull' | 'slideUp' = 'pull'
	@Local refreshStatus: IBestPullRefreshStatus = "normal"
	@Local headSize: number = 0
	@Local bottomSize: number = 0
	private uiContext = this.getUIContext()

	@Builder textTip(){
		Row({space: convertDimensionsWidthUnit(5)}){
			if(this.refreshStatus == "loading") {
				IBestLoading({
					loadingSize: this.baseStyle.fontSizeMd as string
				})
			}
			Text(this.getStatusText())
				.fontColor(IBestPullRefreshColor.textColor)
				.fontSize(this.baseStyle.fontSizeMd)
		}
	}

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		setTimeout(() => {
			this.headSize = getComponentsInfo(this.uiContext, `ibest_pull_up_${this.uniId}`).height
			this.bottomSize = getComponentsInfo(this.uiContext, `ibest_pull_down_${this.uniId}`).height
		}, 50)
	}
	isTouchable(){
		return this.refreshStatus != "loading" && this.refreshStatus != "success"
	}
	ease(distance: number) {
		let absValue = Math.abs(distance)
		const pullDistance = distance > 0 ? this.headSize : this.bottomSize
		if (absValue > pullDistance) {
			if (absValue < pullDistance * 2) {
				absValue = pullDistance + (absValue - pullDistance) / 2;
			} else {
				absValue = pullDistance * 1.5 + (absValue - pullDistance * 2) / 4;
			}
		}
		return distance > 0 ? Math.round(absValue) : -Math.round(absValue)
	}
	// 设置刷新状态
	setRefreshStatus(distance: number, isLoading?: boolean){
		let absValue = Math.abs(distance)
		this.transY = distance
		if(absValue > 0){
			this.actionType = distance > 0 ? 'pull' : 'slideUp'
		}
		if(isLoading){
			this.refreshStatus = "loading"
		}else if(absValue == 0){
			this.refreshStatus = "normal"
		}else if(distance > 0 && absValue < this.headSize || distance < 0 && absValue < this.bottomSize){
			this.refreshStatus = "pulling"
		} else {
			this.refreshStatus = 'loosing'
		}
	}
	getStatusText(): ResourceStr{
		switch(this.refreshStatus){
			case "normal":
				return ""
			case "pulling":
				return this.actionType == 'pull' ? this.pullingText : this.slidingUpText
			case "loosing":
				return this.actionType == 'pull' ? this.loosingText : this.slideUpLoosingText
			case "loading":
				return this.actionType == 'pull' ? this.loadingText : this.slideUpLoadingText
			case "success":
				return this.actionType == 'pull' ? this.successText : this.slideUpSuccessText
		}
	}
	onPanGestureChange(type: string, event: GestureEvent){
		if(this.isTouchable()) {
			switch (type) {
				case "start":
					this.scrollTop = this.scroller.currentOffset()?.yOffset ?? 0
					this.isAtEnd = this.scroller.isAtEnd()
					break
				case "move":
					let newOffset = event.offsetY
					if(newOffset > 0 && this.scrollTop < 1 || newOffset < 0 && this.isAtEnd && this.isEnableSlideUp){
						this.setRefreshStatus(this.ease(newOffset))
					}
					break
				case "end":
					if(this.refreshStatus == "loosing"){
						this.setRefreshStatus(this.transY > 0 ? this.headSize : -this.bottomSize, true)
						this.$loading(true)
						setTimeout(() => {
							this.onRefresh(this.actionType)
						}, 50)
					}else{
						this.setRefreshStatus(0)
					}
					break
			}
		}
	}
	@Monitor("loading")
	loadingChange(){
		if(!this.loading){
			if(this.actionType == "pull" && (this.successContent || this.successText) || this.actionType == "slideUp" && (this.slideUpSuccessContent || this.slideUpSuccessText)){
				this.refreshStatus = "success"
				let duration = this.actionType == "pull" ? this.successDuration : this.slideUpSuccessDuration
				setTimeout(() => {
					this.setRefreshStatus(0)
				}, duration)
			} else {
				this.setRefreshStatus(0)
			}
		}
	}

	build() {
		Column(){
			Column(){
				Row({ space: 10 }){
					Row(){
						if(this.pullingContent){
							this.pullingContent({ distance: this.transY })
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "pulling" ? Visibility.Visible : Visibility.None)
					Row(){
						if(this.loosingContent){
							this.loosingContent({ distance: this.transY })
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "loosing" ? Visibility.Visible : Visibility.None)
					Row(){
						if(this.loadingContent){
							this.loadingContent()
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "loading" ? Visibility.Visible : Visibility.None)
					Row(){
						if(this.successContent){
							this.successContent()
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "success" ? Visibility.Visible : Visibility.None)
				}
				.width(CONTAINER_SIZE.FULL)
				.height(getSizeByUnit(this.headHeight))
				.justifyContent(FlexAlign.Center)
				.position({ x: 0, y: 0 })
				.translate({ y: "-100%" })
				.id(`ibest_pull_up_${this.uniId}`)
				if(this.defaultContent){
					this.defaultContent()
				}
				Row({ space: 10 }){
					Row(){
						if(this.slidingUpContent){
							this.slidingUpContent({ distance: Math.abs(this.transY) })
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "pulling" ? Visibility.Visible : Visibility.None)
					Row(){
						if(this.slideUpLoosingContent){
							this.slideUpLoosingContent({ distance: Math.abs(this.transY) })
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "loosing" ? Visibility.Visible : Visibility.None)
					Row(){
						if(this.slideUpLoadingContent){
							this.slideUpLoadingContent()
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "loading" ? Visibility.Visible : Visibility.None)
					Row(){
						if(this.slideUpSuccessContent){
							this.slideUpSuccessContent()
						}else{
							this.textTip()
						}
					}.visibility(this.refreshStatus == "success" ? Visibility.Visible : Visibility.None)
				}
				.width(CONTAINER_SIZE.FULL)
				.height(getSizeByUnit(this.bottomHeight))
				.justifyContent(FlexAlign.Center)
				.position({ left: 0, bottom: 0 })
				.translate({ y: "100%" })
				.id(`ibest_pull_down_${this.uniId}`)
			}
			.width(CONTAINER_SIZE.FULL)
			.translate({ y: this.transY })
			.animation({
				duration: this.transY > 0 ? this.duration : this.slideUpDuration
			})
			.parallelGesture(
			  	PanGesture({ fingers: 1, direction: PanDirection.Vertical })
					.onActionStart((event: GestureEvent) => {
						this.onPanGestureChange("start", event)
					})
					.onActionUpdate((event: GestureEvent) => {
						this.onPanGestureChange("move", event)
					})
					.onActionEnd((event) => {
						this.onPanGestureChange("end", event)
					})
			)
		}
		.width(CONTAINER_SIZE.FULL)
		.height(CONTAINER_SIZE.FULL)
		.clip(true)
	}
}