import { IBestNavBar } from '@ibestservices/ibest-ui';
import { COLOR_BLUE, CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import RouterUtil from '../../utils/routerUtil';
import { getRandomColor } from '../../utils/utils';

@Builder
export function NavBarBuilder(name: string, title: string){
	NavBarPage({title})
}

@Entry
@ComponentV2
struct NavBarPage {
	@Param title: string = ''
	@Local searchVal: string = ''
	@Local navBarBgColor: string = "#3D8AF2"

	@Builder leftBuilder(){
		Row({space: SPACE.BASE}){
			Image($r("app.media.ibest_icon_star_o"))
				.width(16)
			Text("自定义左侧")
		}
	}
	@Builder rightBuilder(){
		Row({space: SPACE.BASE}){
			Image($r("app.media.icon_like"))
				.width(16)
			Text("自定义右侧")
		}
	}
	@Builder titleBuilder(){
		TextInput({text: this.searchVal, placeholder: "请输入搜索内容"}).width("100%").height("70%")
	}

	build() {
		NavDestination() {
			IBestNavBar({
				title: this.title,
				isShowStatusBar: true,
				onLeftClick: () => {
					RouterUtil.pop()
				}
			})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法', titlePaddingLeft: SPACE.MD }){
						IBestNavBar({
							title: $r("app.string.app_name")
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义样式', titlePaddingLeft: SPACE.MD }){
						Column({space: SPACE.XS}){
							IBestNavBar({
								title: $r("app.string.app_name"),
								titleColor: COLOR_BLUE.DEFAULT,
								titleFontSize: 14,
								titleFontWeight: FontWeight.Bold,
								navBarBgColor: COLOR_BLUE.MINI,
								leftIconColor: COLOR_BLUE.DEFAULT
							})
							IBestNavBar({
								title: $r("app.string.app_name"),
								titleColor: COLOR_BLUE.DEFAULT,
								leftIconColor: COLOR_BLUE.DEFAULT,
								bgLinearGradient: {
									angle: 90,
									colors: [[0xff0000, 0.0], [0x0000ff, 0.3], [0xffff00, 1.0]]
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '标题居左', titlePaddingLeft: SPACE.MD }){
						IBestNavBar({
							title: $r("app.string.app_name"),
							titleTextAlign: "left"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义显示区域', titlePaddingLeft: SPACE.MD }){
						Column({space: SPACE.XS}){
							IBestNavBar({
								leftIcon: "https://img1.baidu.com/it/u=498751481,2849377151&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=800",
								leftLabel: $r("app.string.app_name"),
								leftIconRadius: 999
							})
							IBestNavBar({
								isShowLeft: false,
								title: $r("app.string.app_name"),
								titleIcon: $r("app.media.app_icon"),
							})
							IBestNavBar({
								isShowLeft: false,
								isShowRight: true,
								rightIcon: "https://img1.baidu.com/it/u=498751481,2849377151&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=800",
								rightLabel: $r("app.string.app_name")
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义标题内容', titlePaddingLeft: SPACE.MD }){
						Column({space: SPACE.MD}){
							IBestNavBar({
								titleBuilder: (): void => this.titleBuilder()
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义左右内容', titlePaddingLeft: SPACE.MD }){
						Column({space: SPACE.XS}){
							IBestNavBar({
								title: $r("app.string.app_name"),
								leftLabel: "返回",
								isShowRight: true,
								rightIcon: "wap-nav",
								rightLabel: "更多"
							})
							IBestNavBar({
								title: $r("app.string.app_name"),
								leftBuilder: (): void => this.leftBuilder(),
								isShowRight: true,
								rightBuilder: (): void => this.rightBuilder()
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '二级标题', titlePaddingLeft: SPACE.MD }){
						IBestNavBar({
							title: $r("app.string.app_name"),
							subTitle: "一套轻量、可定制化主题的鸿蒙UI组件库"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '显示状态栏', titlePaddingLeft: SPACE.MD }){
						IBestNavBar({
							title: "点我修改颜色",
							titleColor: COLOR_BLUE.DEFAULT,
							leftIconColor: COLOR_BLUE.DEFAULT,
							navBarBgColor: this.navBarBgColor,
							isShowStatusBar: true,
							onTitleClick: () => {
								this.navBarBgColor = getRandomColor()
							}
						})
					}
				}
				ListItem().height(50)
			}
			.width(CONTAINER_SIZE.FULL)
			.layoutWeight(1)
		}
		.hideBackButton(true)
		.backgroundColor(modeColor.bg)
	}
}