import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit, sleep } from '../../utils/utils';
import { IBestTabItem, IBestTabItemType, TabWidthType } from './index.type';
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';
import { CONTAINER_SIZE } from '../../theme-chalk/src/container';
import { debounce } from '../../utils/DebounceThrottle';
import { IBestTabColor } from './color';
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { AppStorageV2 } from '@kit.ArkUI';
@ComponentV2
export struct IBestTabs{
    /**
     * 全局公共样式
     */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local isLandscape: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.IS_LANDSCAPE)!
	/**
	 * 当前激活的tab的name
	 */
	@Param @Require currentName: IBestStringNumber
    /**
     * 样式类型
     */
    @Param type: 'line' | 'card' = "line"
    /**
     * tab高度
     */
    @Param tabHeight: IBestStringNumber = convertDimensionsWidthUnit(35)
    /**
     * tab宽度类型
     */
    @Param tabWidthType: "auto" | "flex" = "flex"
    /**
     * tab列表
     */
    @Param tabsList: (IBestTabItemType | IBestTabItem)[] = []
    /**
     * 单个tab内边距
     */
    @Param tabPadding: IBestStringNumber = this.baseStyle.spaceXs as string
	/**
	 * 是否显示标记线, 仅type为 `line` 时有效
	 * @since 0.0.2
	 */
	@Param showActiveLine: boolean = true
    /**
     * 标记线宽度是否固定
     */
    @Param isTabLineWidthFixed: boolean = false
    /**
     * 标记线宽度, isTabLineWidthFixed 为true时有效
     */
    @Param tabLineWidth: IBestStringNumber = 0
    /**
     * 标记线高度
     */
    @Param tabLineHeight: IBestStringNumber = convertDimensionsWidthUnit(2)
	/**
	 * 标记线圆角
	 * @since 0.0.2
	 */
	@Param tabLineRadius: IBestStringNumber = 0
    /**
     * 未激活的tab文字颜色
     */
    @Param inactiveTextColor: ResourceColor = IBestTabColor.inactiveTextColor
    /**
     * 激活的tab文字颜色
     */
    @Param activeTextColor: ResourceColor = IBestTabColor.activeTextColor
    /**
     * type 为 `line` 时, 为标记线颜色, type 为 `card` 时, 为标记块背景色
     */
    @Param tabLineColor: ResourceColor = ""
    /**
     * 标记线Y偏移量
     */
    @Param lineOffsetY: IBestStringNumber = 0
    /**
     * tab区域背景颜色
     */
    @Param tabBgColor: ResourceColor = IBestTabColor.bgColor
    /**
     * 默认字体大小
     */
    @Param fontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 是否显示激活背景, 仅type为`line`时有效
     */
    @Param isShowActiveBg: boolean = false
    /**
     * 激活背景色, 仅type为`line`时有效
     */
    @Param activeBgColor: ResourceColor = ""
    /**
     * 非激活背景色, 仅type为`line`时有效
     */
    @Param inactiveBgColor: ResourceColor = ""
    /**
     * 选项圆角, 仅type为`line`时有效
     */
    @Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
	/**
	 * 激活文字字重
	 * @since 0.0.2
	 */
	@Param activeFontWeight: FontWeight = FontWeight.Normal
	/**
	 * 激活文字大小
	 * @since 0.0.2
	 */
	@Param activeFontSize: IBestStringNumber = this.fontSize
	/**
	 * tabContent 内容列表
	 * @since 0.0.2
	 */
	@BuilderParam tabContentBuilder: CustomBuilder
    /**
     * onChange事件回调
     */
    @Event onChange: (name: IBestStringNumber) => void = () => {}
    /**
     * 点击事件
     */
	@Event onTabClick: (name: IBestStringNumber) => void = () => {}
	@Event $currentName: (name: IBestStringNumber) => void = () => {}

	// 唯一id
	@Provider() uniId: number = 0
    @Local isReady: boolean = false
	// tab盒子宽度
	@Local tabContentWidth: number = 0
	// tab宽度列表
	@Local tabsWidthList: TabWidthType[] = []
	// 标记线位移列表
	@Local translateXList: number[] = []
	// 标记块宽度
	@Local tabBoxWidth: number = 0
	@Local realTabLineWidth: number = 0
	// 标记线X偏移量
	@Local translateX: number = 0
	// 标记块X偏移量
	@Local tabBoxTranslateX: number = 0
    @Local swiperIndex: number = 0
    @Local startTransX: number = 0
    @Local startX: number = 0
    @Local touchOffsetX: number = 0
    @Local startTime: number = 0
	private scroller: Scroller = new Scroller()
	private context = this.getUIContext()
	private swiperController: SwiperController = new SwiperController()
	// 列表变化
	@Monitor("tabsList") tabsListChange(){
		sleep(20).then(() => {
			this.getTabsWidth()
		})
	}
	// tabName 变化
	@Monitor("currentName") async currentNameChange(){
		if(this.tabsWidthList.length){
			let index = this.tabsList.findIndex((item: IBestTabItem) => item.name == this.currentName)
			// 获取并改变tabLine的宽度
			this.getAndSetLineWidth(index)
			// 触发回调函数
			this.onChange(this.currentName)
			this.scrollCenter()
			await sleep(20)
			// 切换swiper的index
			this.swiperChange(index, true)
		}
	}
	@Builder tabBoxBuilder(showId: boolean = false){
		Stack({alignContent: Alignment.BottomStart}){
			// 标记块
			if(this.isShowActiveBg || this.type == "card"){
				Row()
					.width(this.tabBoxWidth)
					.height(getSizeByUnit(this.tabHeight))
					.backgroundColor(this.getLineColor())
					.borderRadius(this.type == "line" ? getSizeByUnit(this.radius) : 0)					.translate({ x: this.tabBoxTranslateX })
					.animation({
						duration: this.isReady ? 100 : 0,
						curve: Curve.FastOutSlowIn
					})
			}
			Row(){
				ForEach(this.tabsList, (item: IBestTabItem, index: number) => {
					IBestTab({
						item: item,
						index: index,
						currentName: this.currentName,
						type: this.type,
						tabWidthType: this.tabWidthType,
						tabPadding: this.tabPadding,
						inactiveTextColor: this.inactiveTextColor,
						activeTextColor: this.activeTextColor,
						tabLineColor: this.tabLineColor,
						fontSize: this.fontSize,
						isShowActiveBg: this.isShowActiveBg,
						activeBgColor: this.activeBgColor,
						inactiveBgColor: this.inactiveBgColor,
						radius: this.radius,
						activeFontWeight: this.activeFontWeight,
						activeFontSize: this.activeFontSize,
						initSize: (): void => this.initSize(),
						changeName: (name: IBestStringNumber): void => this.changeName(name)
					})
				}, (_: IBestTabItem, index: number) => index+'')
			}
			.width(this.tabWidthType == "flex" ? "100%" : "")
			.height(getSizeByUnit(this.tabHeight))
			.borderRadius(this.baseStyle.borderRadiusSm)
			.border({ width: this.type == "card" ? 1 : 0, color: this.getLineColor() })
			// 标记线
			if(this.type == "line" && this.showActiveLine){
				Row()
					.width(this.isTabLineWidthFixed ? getSizeByUnit(this.tabLineWidth) : this.realTabLineWidth)
					.height(getSizeByUnit(this.tabLineHeight))
					.backgroundColor(this.getLineColor())
					.borderRadius(getSizeByUnit(this.tabLineRadius))
					.translate({ x: this.translateX })
					.animation({
						duration: this.isReady ? 100 : 0,
						curve: Curve.FastOutSlowIn
					})
					.offset({ y: `-${getSizeByUnit(this.lineOffsetY)}` })
					.id(`ibest_tab_line_${this.uniId}`)
			}
		}
		.backgroundColor(this.tabBgColor)
		.id(showId ? `ibest_tabContent_${this.uniId}` : "")
	}

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
    }
	@Monitor("isLandscape.value")
    onDidBuild(): void {
        this.initSize()
    }
    initSize: () => void = debounce(() => {
        let index = this.tabsList.findIndex((item: IBestTabItem) => item.name == this.currentName)
        this.getTabsWidth()
        this.getAndSetLineWidth(index)
        this.scrollCenter()
        this.swiperChange(index, false)
        setTimeout(() => {
            this.isReady = true
        }, 100)
    }, 200)
	// 切换swiper
	swiperChange(index: number, animated: boolean){
		this.swiperController.changeIndex(index, animated)
	}
    // 获取所有tab的宽度
    getTabsWidth(){
        let tabWidthList: TabWidthType[] = []
        let translateXList: number[] = []
        let tabContentInfo = getComponentsInfo(this.context, `ibest_tabContent_${this.uniId}`)
        this.tabsList.forEach((item: IBestTabItem) => {
            let boxInfo = getComponentsInfo(this.context, `ibestTab_${this.uniId}_box_${item.name}`)
            let textInfo = getComponentsInfo(this.context, `ibestTab_${this.uniId}_text_${item.name}`)
            let tabLineWidth = this.isTabLineWidthFixed ? this.getTabLineWidth() : textInfo.width
            tabWidthList.push({
                boxWidth: boxInfo.width,
                boxLocalLeft: boxInfo.localLeft,
                textWidth: textInfo.width
            })
            translateXList.push(boxInfo.localLeft + (boxInfo.width - tabLineWidth) / 2)
        })
        this.tabsWidthList = tabWidthList
        this.tabContentWidth = tabContentInfo.width
        this.translateXList = translateXList
    }
    // 获取并改变line宽度 位置
    getAndSetLineWidth(index: number){
        if(index > -1) {
            let tabInfo = this.tabsWidthList[index]
            if (this.type == "line") {
                if (!this.isTabLineWidthFixed) {
                    this.realTabLineWidth = tabInfo.textWidth
                }
                this.startTransX = this.translateX = this.translateXList[index]
            }
            if(this.isShowActiveBg || this.type == "card"){
                this.tabBoxWidth = tabInfo.boxWidth
                this.startTransX = this.tabBoxTranslateX = tabInfo.boxLocalLeft
            }
        }
    }
	getLineColor(){
		return this.tabLineColor || this.baseStyle.primary
	}
    getTabLineWidth(){
        return getComponentsInfo(this.context, `ibest_tab_line_${this.uniId}`).width
    }
	changeName(name: IBestStringNumber){
		this.$currentName(name)
		this.onTabClick(name)
	}
    // 滚动居中
    scrollCenter(animate: boolean = true){
        if(this.tabWidthType == "auto"){
            this.scroller.scrollTo({
                xOffset: (this.type == "line" ? this.translateX : this.tabBoxTranslateX) - this.tabContentWidth/2 + this.tabBoxWidth/2,
                yOffset: 0,
                animation: animate ? {
                    duration: animate ? 100 : 0,
                    curve: Curve.FastOutSlowIn
                } : false
            })
        }
    }
    build() {
        Column(){
            if(this.tabWidthType == "auto"){
                Scroll(this.scroller){
                    this.tabBoxBuilder()
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .align(Alignment.Start)
                .constraintSize({ maxHeight: getSizeByUnit(this.tabHeight) })
                .id(`ibest_tabContent_${this.uniId}`)
            }else{
                this.tabBoxBuilder(true)
            }
            if(this.tabContentBuilder){
                Swiper(this.swiperController){
                    this.tabContentBuilder()
                }
                .width(CONTAINER_SIZE.FULL)
                .indicator(false)
                .loop(false)
                .duration(200)
                .effectMode(EdgeEffect.None)
                .index($$this.swiperIndex)
                .monopolizeEvents(true)
                .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
                    let curOffset = extraInfo.currentOffset
                    let transX = curOffset > 0 ? this.translateXList[index] - this.translateXList[index-1] : this.translateXList[index+1] - this.translateXList[index]
                    let x = - curOffset * transX / this.tabContentWidth
                    this.translateX = this.startTransX + x
                })
				.onAnimationStart((index, target, extraInfo) => {
					// 获取速度
					let speed = extraInfo.velocity * -1;
					let transX = extraInfo.currentOffset > 0 ? this.translateXList[index] - this.translateXList[index-1] : this.translateXList[index+1] - this.translateXList[index];
					let x = - extraInfo.currentOffset * transX / this.tabContentWidth
					// 获取剩余时间
					let duration = x / speed;
					if(index != target){
						this.$currentName(this.tabsList[target].name)
					}
					this.context.animateTo({duration: duration}, () => {
						this.translateX = this.translateXList[target]
					})
				})
            }
        }
        .width(CONTAINER_SIZE.FULL)
        .alignItems(HorizontalAlign.Start)
    }
}

@ComponentV2
struct IBestTab{
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Consumer() uniId: number = 0
    @Param @Require item: IBestTabItem
    @Param @Require index: number
	@Param @Require currentName: IBestStringNumber
    @Param @Require type: 'line' | 'card'
    @Param @Require tabWidthType: "auto" | "flex"
    @Param @Require tabPadding: IBestStringNumber
    @Param @Require inactiveTextColor: ResourceColor
    @Param @Require activeTextColor: ResourceColor
    @Param @Require tabLineColor: ResourceColor
    @Param @Require fontSize: IBestStringNumber
    @Param @Require isShowActiveBg: boolean
    @Param @Require activeBgColor: ResourceColor
    @Param @Require inactiveBgColor: ResourceColor
    @Param @Require radius: Length | BorderRadiuses | LocalizedBorderRadiuses
	@Param @Require activeFontWeight: FontWeight
	@Param @Require activeFontSize: IBestStringNumber
    @Event initSize: () => void = () => {}
    @Event changeName: (name: IBestStringNumber) => void = () => {}
    @Monitor("item.number") numberChange(){
        this.initSize()
    }
	@Monitor("item.label") labelChange(){
        this.initSize()
    }
	getIsActive(){
		return this.currentName == this.item.name
	}
    getLineColor(){
        return this.tabLineColor || this.baseStyle.primary
    }
    getFontColor(){
        return this.getIsActive() ? this.type == "card" ? "#fff" : this.activeTextColor : this.type == "card" ? this.getLineColor() : this.inactiveTextColor
    }
    build() {
        Row() {
            Row(){
                if(this.item.icon) {
                    Image(this.item.icon)
                        .width(getSizeByUnit(this.fontSize))
                        .aspectRatio(1)
                        .margin({right: this.baseStyle.spaceBase})
                        .fillColor(this.getFontColor())
                }
                Text(){
                    Span(this.item.label)
                    if(typeof this.item.number !== "undefined"){
                        Span(`(${this.item.number})`)
                    }
                }
                .height(CONTAINER_SIZE.FULL)
                .fontSize(getSizeByUnit(this.getIsActive() ? this.activeFontSize : this.fontSize, true))
                .fontColor(this.getFontColor())
                .maxLines(1)
                .textOverflow({overflow: TextOverflow.Ellipsis})
				.fontWeight(this.getIsActive() ? this.activeFontWeight : FontWeight.Normal)
            }
            .id(`ibestTab_${this.uniId}_text_${this.item.name}`)
        }
        .backgroundColor(this.type == "line" && this.isShowActiveBg ? this.getIsActive() ? this.activeBgColor : this.inactiveBgColor : "")
        .justifyContent(FlexAlign.Center)
        .padding({left: getSizeByUnit(this.tabPadding), right: getSizeByUnit(this.tabPadding)})
        .layoutWeight(this.tabWidthType == "flex" ? 1 : 0)
		.borderRadius(this.type == "line" ? getSizeByUnit(this.radius) : 0)        .border({ width: { left: this.type == "card" && this.index > 0 ? 1 : 0 }, color: this.getLineColor() })
        .clip(true)
        .enabled(!this.item.isDisable)
        .opacity(this.item.isDisable ? 0.3 : 1)
        .id(`ibestTab_${this.uniId}_box_${this.item.name}`)
        .onClick(() => {
            this.changeName(this.item.name)
        })
    }
}
