import { IBestNavBar } from '@ibestservices/ibest-ui-v2'
import RouterUtil from '../utils/routerUtil'
@ComponentV2
export default struct CustomNavBar {
	@Param title: ResourceStr = ""
	build() {
		IBestNavBar({
			title: this.title,
			isShowStatusBar: true,
			onLeftClick: () => {
				RouterUtil.pop()
			}
		})
	}
}