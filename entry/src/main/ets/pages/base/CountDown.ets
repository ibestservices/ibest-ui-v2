import { CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import { IBestButton, IBestCountDown, IBestCountDownController, IBestToast } from '@ibestservices/ibest-ui-v2';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function CountDownBuilder(_: string, title: string){
	CountDownPage({title})
}

@Entry
@ComponentV2
struct CountDownPage {
	@Param title: string = ''
	@Local time: number = 30 * 60 * 60 * 1000

	@Local time1: number = 3 * 1000
	private controller: IBestCountDownController = new IBestCountDownController()

	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						IBestCountDown({
							time: this.time
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义格式' }) {
						IBestCountDown({
							time: this.time,
							format: "DD 天 HH 时 mm 分 ss 秒"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '毫秒级渲染' }) {
						IBestCountDown({
							time: this.time,
							format: 'HH:mm:ss:SSS'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '手动控制' }) {
						Column({space: SPACE.MD}){
							IBestCountDown({
								time: this.time1,
								format: 'ss:SSS',
								autoStart: false,
								controller: this.controller,
								onFinish: () => {
									IBestToast.show("已结束")
								}
							})
							Row(){
								IBestButton({
									type: 'primary',
									text: "开始",
									onBtnClick: () => {
										this.controller.start()
									}
								})
								IBestButton({
									type: 'primary',
									text: "暂停",
									onBtnClick: () => {
										this.controller.pause()
									}
								})
								IBestButton({
									type: 'primary',
									text: "重置",
									onBtnClick: () => {
										this.controller.reset()
									}
								})
							}
							.width(CONTAINER_SIZE.FULL)
							.justifyContent(FlexAlign.SpaceBetween)
						}
					}
				}
			}
			.layoutWeight(1)
			.padding({ left: SPACE.SM, right: SPACE.SM })
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg2)
	}
}