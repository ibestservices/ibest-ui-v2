import { modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import { IBestLoading } from '@ibestservices/ibest-ui-v2';
import CustomNavBar from '../../components/CustomNavBar';
@Builder
export function LoadingBuilder(_: string, title: string){
	LoadingPage({title})
}

@Entry
@ComponentV2
struct LoadingPage {
	@Param title: string = ''
	@Builder EmptyContain() {
		Row().width("100%").height(200)
	}
	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '加载类型' }) {
						Row({space: SPACE.MD}) {
							IBestLoading()
							IBestLoading({
								loadingIconType: 'spinner'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义颜色' }) {
						Row({space: SPACE.MD}) {
							IBestLoading({
								loadingColor: '#DB3131'
							})
							IBestLoading({
								loadingColor: '#DB3131',
								loadingIconType: 'spinner'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义大小' }) {
						Row({space: SPACE.MD}) {
							IBestLoading({
								loadingSize: 40
							})
							IBestLoading({
								loadingSize: 40,
								loadingIconType: 'spinner'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '加载文案' }) {
						IBestLoading({
							loadingText: '加载中...'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '水平排列' }) {
						IBestLoading({
							loadingText: '加载中...',
							vertical: false
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义文本颜色' }) {
						Row({space: SPACE.MD}) {
							IBestLoading({
								loadingText: '加载中...',
								loadingTextColor: 'rgb(25, 137, 250)'
							})
							IBestLoading({
								loadingText: '加载中...',
								loadingColor: '#3D8AF2',
								loadingTextColor: 'rgb(25, 137, 250)'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '包含内容' }) {
						IBestLoading({
							defaultBuilder: this.EmptyContain,
							loadingMaskColor: 'rgba(0,0,0,0.5)',
							loadingColor: 'rgb(25, 137, 250)'
						})
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
			.padding({ left: SPACE.SM, right: SPACE.SM })
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}