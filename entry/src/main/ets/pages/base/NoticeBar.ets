import { IBestNoticeBar, IBestToast } from '@ibestservices/ibest-ui-v2';
import { modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function NoticeBarBuilder(_: string, title: string){
	NoticeBarPage({title})
}

@Entry
@ComponentV2
struct NoticeBarPage {
	@Param title: string = ''

	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法', titlePaddingLeft: SPACE.MD }) {
						IBestNoticeBar({
							leftIcon: "volume-o",
							text:"无论我们能活多久，我们能够享受的只有无法分割的此刻，此外别无其他。"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '滚动播放', titlePaddingLeft: SPACE.MD }) {
						Column({space: SPACE.MD}){
							IBestNoticeBar({
								scrollable: true,
								text: "今人不见古时月, 今月曾经照古人。"
							})
							IBestNoticeBar({
								scrollable: false,
								text: "不会回头的东西有四件：说出口的话、离弦的箭、逝去的生活和失去的机会。"
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '多行展示', titlePaddingLeft: SPACE.MD }) {
						IBestNoticeBar({
							text: "不会回头的东西有四件：说出口的话、离弦的箭、逝去的生活和失去的机会。",
							wrapable: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '通知栏模式', titlePaddingLeft: SPACE.MD }) {
						Column({space: SPACE.MD}){
							IBestNoticeBar({
								mode: "closeable",
								text: "今人不见古时月, 今月曾经照古人。"
							})
							IBestNoticeBar({
								mode: "link",
								text: "今人不见古时月, 今月曾经照古人。",
								onBarClick: () => {
									IBestToast.show("点击了通知栏")
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义样式', titlePaddingLeft: SPACE.MD }) {
						IBestNoticeBar({
							leftIcon: "info-o",
							leftIconColor: modeColor.primaryColor,
							bgColor: "#ecf9ff",
							text: "今人不见古时月, 今月曾经照古人。",
							textColor: modeColor.primaryColor
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '垂直滚动', titlePaddingLeft: SPACE.MD }) {
						IBestNoticeBar({
							leftIcon: "volume-o",
							vertical: true,
							verticalTextList: [
							  	"今人不见古时月, 今月曾经照古人。",
								"不会回头的东西有四件：说出口的话、离弦的箭、逝去的生活和失去的机会。",
								"无论我们能活多久，我们能够享受的只有无法分割的此刻，此外别无其他。"
							]
						})
					}
				}
			}
			.layoutWeight(1)
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}