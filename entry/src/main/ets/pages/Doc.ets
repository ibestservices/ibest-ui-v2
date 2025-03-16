import { IBestNavBar } from '@ibestservices/ibest-ui'
import { webview } from '@kit.ArkWeb'
import { CONTAINER_SIZE } from '../assets/styles/BaseStyle'
import GlobalStore from '../utils/global'
import RouterUtil from '../utils/routerUtil'

@Builder
export function DocBuilder(name: string){
	Doc()
}

@Entry
@Component
struct Doc {
	private controller: webview.WebviewController = new webview.WebviewController()
	build() {
		NavDestination(){
			IBestNavBar({
				title: "文档",
				isShowStatusBar: true,
				onLeftClick: () => {
					RouterUtil.pop()
				}
			})
			Web({
				src: $r("app.string.app_doc_url"),
				controller: this.controller
			})
				.layoutWeight(1)
		}
		.hideBackButton(true)
	}
}