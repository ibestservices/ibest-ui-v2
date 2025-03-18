import {
	IBestButton,
	IBestCell,
	IBestCellGroup,
	IBestIcon,
	IBestNavBar,
	IBestPopup,
	IBestToast
} from '@ibestservices/ibest-ui-v2'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import { CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle'
import RouterUtil from '../../utils/routerUtil'

@Builder
export function PopupBuilder(name: string, title: string){
	PopupPage({title})
}

@Extend(Column) function positionColStyle(bd: boolean = false){
	.layoutWeight(1)
	.height(75)
	.justifyContent(FlexAlign.Center)
	.border({width:{left: bd ? 1 : 0}, color: modeColor.borderColor})
	.stateStyles({
		normal:{
			.backgroundColor(modeColor.bg2)
		},
		pressed:{
			.backgroundColor(modeColor.active)
		}
	})
}

@Entry
@ComponentV2
struct PopupPage {
	@Param title: string = ''
	@Local baseVisible: boolean = false
	@Local upVisible: boolean = false
	@Local downVisible: boolean = false
	@Local leftVisible: boolean = false
	@Local rightVisible: boolean = false
	@Local showHeaderVisible: boolean = false
	@Local cusCloseIconVisible: boolean = false
	@Local centerCornerVisible: boolean = false
	@Local bottomCornerVisible: boolean = false
	@Local bgImageVisible: boolean = false
	@Local cusHeightVisible: boolean = false
	@Local eventVisible: boolean = false
	@Local safeAreaVisible: boolean = false
	@Local popupWidth: number = 300
	@Local popupHeight: number = 150

	@Builder centerBuilder() {
		Column()
			.width(CONTAINER_SIZE.FULL)
			.aspectRatio(1)
			.justifyContent(FlexAlign.Center)
	}
	@Builder cusHeightBuilder() {
		Column({space: SPACE.MD}) {
			IBestButton({
				text: $r("app.string.custom_switch", $r("app.string.width")),
				type: "primary",
				onBtnClick: () => {
					this.popupWidth = this.popupWidth == 300 ? 260 : 300
				}
			})
			IBestButton({
				text: $r("app.string.custom_switch", $r("app.string.height")),
				type: "primary",
				onBtnClick: () => {
					this.popupHeight = this.popupHeight == 150 ? 300 : 150
				}
			})
		}
		.width(CONTAINER_SIZE.FULL)
		.padding(20)
		.justifyContent(FlexAlign.Center)
	}
	@Builder safeBuilder() {
		Column(){
			Text($r("app.string.content")).fontSize(14)
			Text($r("app.string.content")).fontSize(14)
		}
		.width(CONTAINER_SIZE.FULL)
		.height(CONTAINER_SIZE.FULL)
		.justifyContent(FlexAlign.SpaceBetween)
		.alignItems(HorizontalAlign.Center)
	}

	build() {
		NavDestination(){
			IBestNavBar({
				title: this.title,
				isShowStatusBar: true,
				onLeftClick: () => {
					RouterUtil.pop()
				}
			})
			List() {
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.basic_usage"), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							IBestCell({
								title: $r("app.string.show_popup"),
								isLink: true,
								hasBorder: false,
								onCellClick: () => {
									this.baseVisible = true
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.position"), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							Row(){
								Column({space: 8}){
									IBestIcon({
										name: "arrow-up",
										iconSize: 25
									})
									Text($r("app.string.custom_popup_direction", $r("app.string.top")))
										.fontSize(12)
								}
								.positionColStyle()
								.onClick(() => {
									this.upVisible = true
								})
								Column({space: 8}){
									IBestIcon({
										name: "arrow-down",
										iconSize: 25
									})
									Text($r("app.string.custom_popup_direction", $r("app.string.bottom")))
										.fontSize(12)
								}
								.positionColStyle(true)
								.onClick(() => {
									this.downVisible = true
								})
								Column({space: 8}){
									IBestIcon({
										name: "arrow-left",
										iconSize: 25
									})
									Text($r("app.string.custom_popup_direction", $r("app.string.left")))
										.fontSize(12)
								}
								.positionColStyle(true)
								.onClick(() => {
									this.leftVisible = true
								})
								Column({space: 8}){
									IBestIcon({
										name: "arrow",
										iconSize: 25
									})
									Text($r("app.string.custom_popup_direction", $r("app.string.right")))
										.fontSize(12)
								}
								.positionColStyle(true)
								.onClick(() => {
									this.rightVisible = true
								})
							}
							.width(CONTAINER_SIZE.FULL)
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.title"), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							IBestCell({
								title: $r("app.string.title"),
								isLink: true,
								onCellClick: () => {
									this.showHeaderVisible = true
								}
							})
							IBestCell({
								title: $r("app.string.custom_custom", $r("app.string.icon")),
								isLink: true,
								hasBorder: false,
								onCellClick: () => {
									this.cusCloseIconVisible = true
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.radius"), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							IBestCell({
								title: $r("app.string.center"),
								isLink: true,
								onCellClick: () => {
									this.centerCornerVisible = true
								}
							})
							IBestCell({
								title: $r("app.string.bottom"),
								isLink: true,
								hasBorder: false,
								onCellClick: () => {
									this.bottomCornerVisible = true
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.background_image"), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							IBestCell({
								title: $r("app.string.background_image"),
								isLink: true,
								hasBorder: false,
								onCellClick: () => {
									this.bgImageVisible = true
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.custom_dynamics", $r("app.string.height")), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							IBestCell({
								title: $r("app.string.custom_dynamics", $r("app.string.height")),
								isLink: true,
								hasBorder: false,
								onCellClick: () => {
									this.cusHeightVisible = true
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.event"), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							IBestCell({
								title: $r("app.string.event"),
								isLink: true,
								hasBorder: false,
								onCellClick: () => {
									this.eventVisible = true
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.safe_area"), titlePaddingLeft: SPACE.MD }) {
						IBestCellGroup({ inset: true }) {
							IBestCell({
								title: $r("app.string.safe_area"),
								isLink: true,
								hasBorder: false,
								onCellClick: () => {
									this.safeAreaVisible = true
								}
							})
						}
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
			// 基础展示
			IBestPopup({
				visible: this.baseVisible!!,
				popupWidth: this.popupWidth,
				contentBuilder: (): void => this.centerBuilder()
			})
			// 弹框位置
			IBestPopup({
				visible: this.upVisible!!,
				popupAlign: "top"
			})
			IBestPopup({
				visible: this.downVisible!!,
				popupAlign: "bottom"
			})
			IBestPopup({
				visible: this.leftVisible!!,
				popupAlign: "left"
			})
			IBestPopup({
				visible: this.rightVisible!!,
				popupAlign: "right"
			})
			// 关闭图标
			IBestPopup({
				visible: this.showHeaderVisible!!,
				popupWidth: this.popupWidth,
				isShowHeader: true,
				title: $r("app.string.title"),
				contentBuilder: (): void => this.centerBuilder()
			})
			IBestPopup({
				visible: this.cusCloseIconVisible!!,
				popupAlign: "bottom",
				isShowHeader: true,
				title: $r("app.string.title"),
				closeIcon: "https://ibestui.ibestservices.com/favicon.ico"
			})
			// 圆角弹窗
			IBestPopup({
				visible: this.centerCornerVisible!!,
				popupWidth: this.popupWidth,
				cornerRadius: 10,
				contentBuilder: (): void => this.centerBuilder()
			})
			IBestPopup({
				visible: this.bottomCornerVisible!!,
				popupAlign: "bottom",
				cornerRadius: 30
			})
			// 背景图片
			IBestPopup({
				visible: this.bgImageVisible!!,
				popupWidth: this.popupWidth,
				popupHeight: 200,
				bgImage: "https://img1.baidu.com/it/u=1502587040,2600645085&fm=253&fmt=auto&app=120&f=JPEG?w=1422&h=800",
				contentBuilder: (): void => this.centerBuilder()
			})
			// 动态高度
			IBestPopup({
				visible: this.cusHeightVisible!!,
				popupWidth: this.popupWidth,
				popupHeight: this.popupHeight,
				contentBuilder: (): void => this.cusHeightBuilder()
			})
			// 事件监听
			IBestPopup({
				visible: this.eventVisible!!,
				popupAlign: "bottom",
				onOpen: () => {
					IBestToast.show("open")
				},
				onClose: () => {
					IBestToast.show("close")
				}
			})
			// 安全区域适配
			IBestPopup({
				visible: this.safeAreaVisible!!,
				popupAlign: "left",
				contentBuilder: (): void => this.safeBuilder(),
				safeAreaInsetTop: true,
				safeAreaInsetBottom: true
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}