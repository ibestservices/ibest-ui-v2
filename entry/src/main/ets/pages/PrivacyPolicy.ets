import { IBestNavBar } from '@ibestservices/ibest-ui'
import { webview } from '@kit.ArkWeb'
import { CONTAINER_SIZE } from '../assets/styles/BaseStyle'
import RouterUtil from '../utils/routerUtil'

@Builder
export function PrivacyPolicyBuilder(name: string){
	PrivacyPolicy()
}

@Entry
@Component
struct PrivacyPolicy {
	private webController: webview.WebviewController = new webview.WebviewController()
	build() {
		NavDestination() {
			IBestNavBar({
				title: "隐私政策",
				isShowStatusBar: true,
				onLeftClick: () => {
					RouterUtil.pop()
				}
			})
			Web({
				src: "https://ibestservices.github.io/ibest-ui/PrivacyPolicy.html",
				controller: this.webController
			})
				.cacheMode(CacheMode.Online)
				.layoutWeight(1)
				.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
		}
		.hideBackButton(true)
	}
}