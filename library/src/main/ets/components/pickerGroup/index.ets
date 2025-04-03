import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { IBestTabs } from '../tab'
import { IBestTabItemType } from '../tab/index.type'
import { convertDimensionsWidthUnit } from '../../utils/utils'
import { IBestPickerGroupColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestStorageKey } from '../../model/Global.type'
@ComponentV2
export struct IBestPickerGroup{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 标题
	 */
	@Param title: ResourceStr = ""
	/**
	 * 顶部标签栏列表
	 */
	@Param tabs: ResourceStr[] = []
	/**
	 * 下一步
	 */
	@Param nextStepText: ResourceStr = ""
	/**
	 * 当前激活tabName
	 */
	@Param currentName: number = 0
	/**
	 * 是否显示头部工具栏
	 */
	@Param showToolBar: boolean = true
	/**
	 * 确认按钮文字
	 */
	@Param confirmText: ResourceStr = $r("app.string.ibest_text_confirm")
	/**
	 * 取消按钮文字
	 */
	@Param cancelText: ResourceStr = $r("app.string.ibest_text_cancel")
	/**
	 * 默认插槽
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 确认按钮点击事件
	 */
	@Event onConfirm: () => void = () => {}
	/**
	 * 取消按钮点击事件
	 */
	@Event onCancel: () => void = () => {}
	/**
	 * currentName变化事件
	 */
	@Event onTabNameChange: (name: number) => void = () => {}
	@Event $currentName: (name: number) => void = () => {}

	// 渲染的tab列表
	@Local tabsList: IBestTabItemType[] = []
	// swiper索引
	@Local swiperIndex: number = 0
	@Local tabName: number = 0

	private swiperController: SwiperController = new SwiperController()

	@Monitor("currentName") valueChange(){
		this.tabName = this.currentName
		this.tabChange(this.tabName)
	}
	@Monitor("tabName") modelValueChange(){
		this.$currentName(this.tabName)
	}

	aboutToAppear(): void {
		this.tabName = this.currentName
		this.init()
	}
	// 初始化tabList
	init(){
		this.tabsList = this.tabs.map((item, index) => {
			let obj: IBestTabItemType = {
				label: item,
				name: index + ''
			}
			return obj
		})
	}
	// tabName 改变
	tabNameChange(){
		this.tabChange(this.currentName)
	}
	// tab切换
	tabChange(index: number){
		this.swiperController.changeIndex(index, true)
		this.onTabNameChange(this.currentName)
	}
	// 确认按钮点击
	onConfirmClick(){
		if(this.nextStepText && this.swiperIndex < this.tabsList.length - 1){
			let index = this.swiperIndex + 1
			this.tabName = index
			this.tabChange(index)
		}else{
			this.onConfirm()
		}
	}

	build() {
		Column(){
			if(this.showToolBar){
				Stack({alignContent: Alignment.Center}) {
					Row(){
						Text(this.cancelText)
							.height(CONTAINER_SIZE.FULL)
							.fontSize(this.baseStyle.fontSizeMd)
							.fontColor(IBestPickerGroupColor.textColor2)
							.padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd })
							.onClick(() => {
								this.onCancel()
							})
						Text(this.nextStepText && this.swiperIndex < this.tabsList.length - 1 ? this.nextStepText : this
							.confirmText)
							.height(CONTAINER_SIZE.FULL)
							.fontSize(this.baseStyle.fontSizeMd)
							.fontColor(this.baseStyle.primary)
							.padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd })
							.onClick(() => {
								this.onConfirmClick()
							})
					}
					.width(CONTAINER_SIZE.FULL)
					.height(convertDimensionsWidthUnit(44))
					.justifyContent(FlexAlign.SpaceBetween)
					Text(this.title)
						.constraintSize({ maxWidth: "50%" })
						.fontWeight(600)
						.fontSize(this.baseStyle.fontSizeLg)
						.fontColor(IBestPickerGroupColor.textColor)
						.maxLines(1)
						.textOverflow({ overflow: TextOverflow.Ellipsis })
				}
			}
			Row(){
				IBestTabs({
					currentName: this.tabName!!,
					tabsList: this.tabsList,
					tabWidthType: "auto",
					onChange: name => {
						this.tabChange(Number(name))
					}
				})
			}
			.padding({ left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs, bottom: this.baseStyle.spaceXs })
			Swiper(this.swiperController) {
				if(this.defaultBuilder){
					this.defaultBuilder()
				}
			}
			.width(CONTAINER_SIZE.FULL)
			.disableSwipe(true)
			.indicator(false)
			.loop(false)
			.duration(100)
			.index($$this.swiperIndex)
		}
		.width(CONTAINER_SIZE.FULL)
		.alignItems(HorizontalAlign.Start)
		.backgroundColor(IBestPickerGroupColor.bg2)
	}
}