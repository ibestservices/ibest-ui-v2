import { convertDimensionsWidthUnit, getResourceStr, getSizeByUnit, sleep } from '../../utils/utils'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { IBestTabs } from '../tab'
import { IBestTabItem } from '../tab/index.type'
import { IBestCascaderContentController, IBestCascaderOption, IBestCascaderOptionInstance, IBestCascaderOptionInstanceType } from './index.type'
import { IBestPopup } from '../popup/index'
import { IBestCascaderColor } from './color'
import { IBestIcon } from '../icon'
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestButton } from '../button/index'

@ComponentV2
export struct IBestCascaderContent{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local isLandscape: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.IS_LANDSCAPE)!
	/**
	 * 已选中数据
	 */
	@Param @Require value: IBestStringNumber[]
	/**
	 * 可选项数据源
	 */
	@Param options: IBestCascaderOption[] = []
	/**
	 * 选中颜色
	 */
	@Param activeColor: ResourceColor = ""
	/**
	 * 列表区域高度
	 */
	@Param listHeight: IBestStringNumber = 0
	/**
	 * 单项高度
	 */
	@Param itemHeight: IBestStringNumber = convertDimensionsWidthUnit(40)
	/**
	 * 是否开启动态加载
	 */
	@Param lazy: boolean = false
	@Param controller: IBestCascaderContentController = new IBestCascaderContentController()
	/**
	 * 动态加载函数
	 */
	@Event lazyLoad: ((value: IBestStringNumber, level: number, cb: (arr: IBestCascaderOption[]) => void) => void) | null = null
	/**
	 * 选中项变化时回调函数
	 */
	@Event onChange: (value: IBestStringNumber, selectedOptions: IBestCascaderOption[], index: number) => void = () => {}
	/**
	 * 全部选择完后回调函数
	 */
	@Event onConfirm: (value: IBestCascaderOption[]) => void = () => {}
	@Event $value: (value: IBestStringNumber[]) => void = () => {}

	// 顶部tab栏数据
	@Local tabList: IBestTabItem[] = [
		new IBestTabItem({
			label: $r("app.string.ibest_please_select"),
			name: 0
		})
	]
	// 当前激活tab name
	@Local currentTabName: number = 0
	@Local swiperIndex: number = 0
	// 数据源实例
	@Local optionsInstance: IBestCascaderOptionInstance[][] = []
	private swiperController: SwiperController = new SwiperController()
	private flag: boolean = false

	aboutToAppear(): void {
		this.controller.getSelectedOptions = (): IBestCascaderOption[] => this.getSelectedOptions()
		if(this.options.length){
			if(this.value.length){
				this.createAllOptionsInstance([], this.options, 0)
			}else {
				this.optionsChange()
			}
		}
	}
	getListHeight(){
		return this.listHeight ? getSizeByUnit(this.listHeight) : (this.isLandscape.value ? "60%" : convertDimensionsWidthUnit(350))
	}
	// 创建当前tab下的选项实例
	createOptionsInstance(children: IBestCascaderOption[] = []): IBestCascaderOptionInstance[]{
		return children.length ? children.map((item: IBestCascaderOption) => {
			let obj: IBestCascaderOptionInstanceType = {
				text: item.text,
				value: item.value,
				disabled: item.disabled,
				children: item.children || [],
				actived: false,
				isEnd: item.isEnd
			}
			return new IBestCascaderOptionInstance(obj)
		}) : []
	}
	// 创建全部选项实例
	createAllOptionsInstance(array: IBestCascaderOptionInstance[][] = [], children: IBestCascaderOption[] = [], index: number){
		let curValue = this.value[index]
		let i = children.findIndex((item: IBestCascaderOption) => item.value === curValue)
		i = i > -1 ? i : 0
		array.push(
			children.map((item: IBestCascaderOption) => {
				let obj: IBestCascaderOptionInstanceType = {
					text: item.text,
					value: item.value,
					disabled: item.disabled,
					children: item.children || [],
					actived: curValue === item.value,
					isEnd: item.isEnd
				}
				return new IBestCascaderOptionInstance(obj)
			})
		)
		if(children[i].children?.length){
			this.createAllOptionsInstance(array, children[i].children, index + 1)
		}else{
			this.optionsInstance = array
			let value = this.value
			if(value.length > array.length){
				value = value.slice(0, array.length)
			}
			this.tabList = value.map((item: IBestStringNumber, j: number) => {
				let a = array[j].find((e: IBestCascaderOptionInstance) => e.value == item)
				return new IBestTabItem({
					label: a?.text ?? "",
					name: j
				})
			})
			if(value.length < this.optionsInstance.length){
				this.tabList.push(new IBestTabItem({
					label: $r("app.string.ibest_please_select"),
					name: value.length
				}))
			}
			this.currentTabName = this.swiperIndex = this.tabList.length - 1
		}
	}
	// 选项变化
	@Monitor("options", "options.length")
	optionsChange(){
		if(this.flag){
			this.flag = false
		}else if(this.options.length) {
			this.optionsInstance = []
			this.optionsInstance.push(this.createOptionsInstance(this.options))
		}
	}
	// 顶部tab切换
	tabChange(index: number){
		this.swiperController.changeIndex(index, true)
	}
	// 选中item
	selectItem(index1: number, index2: number, item: IBestCascaderOptionInstance) {
		// 如果选中索引小于当前tab数量,清空tab在索引后的所有项
		if (index1 < this.optionsInstance.length - 1) {
			this.tabList.splice(index1 + 1)
			this.optionsInstance.splice(index1 + 1)
		}
		// 设置当前列表项为选中状态
		this.optionsInstance[index1].forEach((item: IBestCascaderOptionInstance, index: number) => {
			item.actived = index == index2
		})
		// 设置当前tab的文字
		this.tabList[index1].label = item.text
		let selectOption = this.getSelectedOptions()
		let value = selectOption.map((e: IBestCascaderOption) => e.value)
		this.flag = true
		this.$value(value)
		this.onChange(item.value, selectOption, index1)
		if (!(item.children && item.children.length) && (!this.lazy || item.isEnd)) {
			this.onConfirm(selectOption)
		} else if (item.children && item.children.length) {
			this.createNextSwiperData(value, item.children, index1 + 1)
		} else if (this.lazy && this.lazyLoad) {
			this.lazyLoad(item.value, index1 + 1, (arr: IBestCascaderOption[]) => {
				if (arr.length) {
					this.createNextSwiperData(value, arr, index1 + 1)
				}
			})
		}
	}
	// 创建下一个选项的数据实例
	async createNextSwiperData(value: IBestStringNumber[], children: IBestCascaderOption[], index: number){
		await sleep(30)
		let tab = new IBestTabItem({
			label: $r("app.string.ibest_please_select"),
			name: index
		})
		let optionsInstance = this.createOptionsInstance(children)
		if(value[index] !== undefined){
			let i = optionsInstance.findIndex((e: IBestCascaderOptionInstance) => e.value == value[index])
			if(i > -1){
				optionsInstance[i].actived = true
				tab.label = optionsInstance[i].text
			}
		}
		this.optionsInstance.push(optionsInstance)
		this.tabList.push(tab)
		await sleep(50)
		this.tabChange(index)
	}
	// 获取当前已选中的选项
	getSelectedOptions(): IBestCascaderOption[] {
		let arr: IBestCascaderOption[] = []
		this.optionsInstance.forEach((e: IBestCascaderOptionInstance[]) => {
			arr = arr.concat(e.filter(f => f.actived).map(g => {
				let obj: IBestCascaderOption = {
					text: getResourceStr(g.text),
					value: g.value
				}
				return obj
			}))
		})
		return arr
	}

	build() {
		Column({space: this.baseStyle.spaceXsm}){
			Row(){
				IBestTabs({
					tabsList: this.tabList,
					tabWidthType: "auto",
					tabLineColor: this.activeColor || this.baseStyle.primary,
					currentName: this.currentTabName!!,
					onChange: name => {
						this.tabChange(Number(name))
					}
				})
			}
			.padding({ left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs })
			Swiper(this.swiperController) {
				ForEach(this.optionsInstance, (item: IBestCascaderOptionInstance[], index: number) => {
					Scroll(){
						Column(){
							ForEach(item, (item1: IBestCascaderOptionInstance, index1: number) => {
								Row(){
									Text(item1.text)
										.fontColor(item1.actived ? this.activeColor || this.baseStyle.primary : IBestCascaderColor.textColor)
										.fontSize(this.baseStyle.fontSizeMd)
									IBestIcon({
										name: "success",
										iconSize: convertDimensionsWidthUnit(18),
										color: this.activeColor || this.baseStyle.primary
									})
										.visibility(item1.actived ? Visibility.Visible : Visibility.Hidden)
								}
								.width(CONTAINER_SIZE.FULL)
								.height(getSizeByUnit(this.itemHeight))
								.justifyContent(FlexAlign.SpaceBetween)
								.alignItems(VerticalAlign.Center)
								.onClick(() => {
									this.selectItem(index, index1, item1)
								})
								.enabled(!item1.disabled)
								.opacity(item1.disabled ? 0.5 : 1)
							})
						}
						.alignItems(HorizontalAlign.Start)
						.padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd })
					}
					.width(CONTAINER_SIZE.FULL)
					.height(CONTAINER_SIZE.FULL)
					.align(Alignment.Top)
					.padding({ bottom: this.baseStyle.spaceMd })
				}, (_: IBestCascaderOptionInstance[], index: number) => index.toString())
			}
			.width(CONTAINER_SIZE.FULL)
			.height(this.getListHeight())
			.indicator(false)
			.loop(false)
			.duration(100)
			.index(this.swiperIndex)
			.onChange(index => {
				this.currentTabName = index
			})
		}
		.width(CONTAINER_SIZE.FULL)
		.alignItems(HorizontalAlign.Start)
		.backgroundColor(IBestCascaderColor.bgColor)
	}
}

@ComponentV2
export struct IBestCascader{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 弹框显隐
	 */
	@Param @Require visible: boolean
	/**
	 * 已选项
	 */
	@Param @Require value: IBestStringNumber[]
	/**
	 * 标题
	 */
	@Param title: ResourceStr = $r("app.string.ibest_please_select")
	/**
	 * 可选项数据源
	 */
	@Param options: IBestCascaderOption[] = []
	/**
	 * 选中颜色
	 */
	@Param activeColor: ResourceColor = ""
	/**
	 * 列表区域高度
	 */
	@Param listHeight: IBestStringNumber = 0
	/**
	 * 单项高度
	 */
	@Param itemHeight: IBestStringNumber = convertDimensionsWidthUnit(40)
	/**
	 * 选择任意一级选项
	 * 开启后弹框将不再自动关闭，需点击按钮关闭
	 * @since 1.0.6
	 */
	@Param selectAnyLevel: boolean = false
	/**
	 * 是否开启动态加载
	 */
	@Param lazy: boolean = false
	/**
	 * 动态加载函数
	 */
	@Event lazyLoad: ((value: IBestStringNumber, level: number, cb: (arr: IBestCascaderOption[]) => void) => void) | null = null
	/**
	 * 选中项变化时回调函数
	 */
	@Event onChange: (value: IBestStringNumber, selectedOptions: IBestCascaderOption[], index: number) => void = () => {}
	/**
	 * 全部选择完回调
	 * selectAnyLevel为false时选择完最后一级触发，为true时点击按钮触发
	 */
	@Event onConfirm: (value: IBestCascaderOption[]) => void = () => {}
	@Event $visible: (visible: boolean) => void = () => {}
	@Event $value: (value: IBestStringNumber[]) => void = () => {}

	private controller = new IBestCascaderContentController()

	@Builder baseBuilder() {
		IBestCascaderContent({
			value: this.value,
			options: this.options,
			activeColor: this.activeColor,
			listHeight: this.listHeight,
			itemHeight: this.itemHeight,
			lazy: this.lazy,
			lazyLoad: this.lazyLoad,
			onChange: this.onChange,
			controller: this.controller,
			onConfirm: (value: IBestCascaderOption[]) => {
				if(!this.selectAnyLevel) {
					this.onGetResult(value)
				}
			}
		})
		if(this.selectAnyLevel){
			IBestButton({
				type: "primary",
				text: $r("app.string.ibest_text_confirm"),
				btnWidth: CONTAINER_SIZE.FULL,
				btnHeight: 34,
				round: true,
				onBtnClick: () => {
					this.onGetResult(this.controller.getSelectedOptions())
				}
			}).margin({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd, top: this.baseStyle.spaceMd })
		}
	}
	onGetResult(value: IBestCascaderOption[]){
		this.$value(value.map((e: IBestCascaderOption) => e.value))
		this.onConfirm(value)
		this.$visible(false)
	}
	build() {
		IBestPopup({
			visible: this.visible,
			title: this.title,
			isShowHeader: true,
			popupAlign: "bottom",
			popupHeight: "auto",
			safeAreaInsetBottom: true,
			closeOnBackPress: true,
			contentBuilder: ():void => this.baseBuilder(),
			$visible: (visible: boolean): void => this.$visible(visible)
		})
	}
}