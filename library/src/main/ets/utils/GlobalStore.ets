import window from '@ohos.window'
import font from '@ohos.font'
import { getWindowAvoidSize, saveAppStorage } from './utils'
import { bundleManager, common } from '@kit.AbilityKit'
import { IBestBaseDataType, IBestGlobalConfig, IBestGlobalConfigType, IBestStorageKey } from '../model/Global.type'
import { setIBestUIBaseStyle } from '../theme-chalk/src'
import { AppStorageV2, display } from '@kit.ArkUI'

// 全局存储中心
export default class GlobalStore {
	// windowStage
	public static windowStage: window.WindowStage
	// context
	public static context: common.UIAbilityContext
	// 屏幕信息
	public static screenWidth: number = 0
	public static screenHeight: number = 0
	public static isApp: boolean = false
	/**
	 * 初始化
	 */
	public static init(windowStage: window.WindowStage, context: common.UIAbilityContext){
		GlobalStore.windowStage = windowStage
		GlobalStore.context = context
		// 获取顶部和底部规避尺寸
		GlobalStore.getAvoidSize()
		// 获取屏幕尺寸
		GlobalStore.getScreenSize()
		// 获取是否是应用
		GlobalStore.getBundleType()
		// 设置旋转监听
		GlobalStore.screenRotateListener()
		// 监听颜色模式变化
		GlobalStore.setColorModeListener()
		// 注册字体
		font.registerFont({
			familyName: 'ibestFont',
			familySrc: $rawfile('vant_font.woff')
		})
	}
	/**
	 * 获取规避尺寸
     */
	private static getAvoidSize(){
		let res = getWindowAvoidSize()
		saveAppStorage(IBestStorageKey.TOP_AVOID_HEIGHT, res.topSize)
		saveAppStorage(IBestStorageKey.BOTTOM_BAR_HEIGHT, res.navigationSize)
	}
	/**
	 * 获取屏幕尺寸
     */
	private static getScreenSize(){
		let mainWindow = GlobalStore.windowStage.getMainWindowSync()
		let screenInfo: window.WindowProperties = mainWindow.getWindowProperties()
		let o = display.getDefaultDisplaySync().orientation
		let screenWidth = o == 1 || o == 3 ? screenInfo.windowRect.height : screenInfo.windowRect.width
		let screenHeight = o == 1 || o == 3 ? screenInfo.windowRect.width : screenInfo.windowRect.height
		GlobalStore.screenWidth = screenWidth
		GlobalStore.screenHeight = screenHeight
		saveAppStorage(IBestStorageKey.IS_LANDSCAPE, o == 1 || o == 3)
		mainWindow.on("avoidAreaChange", data => {
			if (data.type == window.AvoidAreaType.TYPE_KEYBOARD) {
				saveAppStorage(IBestStorageKey.KEYBOARD_HEIGHT, px2vp(data.area.bottomRect.height))
			}
		})
	}
	/**
	 * 监听屏幕旋转
	 */
	private static screenRotateListener() {
		display.on("change", () => {
			setTimeout(() => {
				GlobalStore.getScreenSize()
				GlobalStore.getAvoidSize()
			}, 300)
		})
	}
	/**
	 * 监听配置变化
     */
	private static setColorModeListener(){
		let appContext = GlobalStore.context.getApplicationContext()
		saveAppStorage(IBestStorageKey.COLOR_MODE, GlobalStore.context.config.colorMode as number)
		appContext.on('environment', {
			onConfigurationUpdated(config) {
				saveAppStorage(IBestStorageKey.COLOR_MODE, config.colorMode)
				saveAppStorage(IBestStorageKey.LANGUAGE, config.language)
			},
			onMemoryLevel() {}
		})
	}
	/**
	 * 获取是否是元服务
	 */
	private static getBundleType(){
		GlobalStore.isApp = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).appInfo.bundleType == bundleManager.BundleType.APP
	}
	/**
	 * 设置全局配置
	 */
	public static setGlobalConfig(option?: IBestGlobalConfigType){
		AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG, () => new IBestGlobalConfig(option))
		setIBestUIBaseStyle()
	}
}