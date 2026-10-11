import window from '@ohos.window'
import { mergeObject, saveAppStorage } from './utils'
import { bundleManager, common } from '@kit.AbilityKit'
import { IBestStorageKey } from '../model/Global.type'
import { setIBestUIBaseStyle } from '../theme-chalk/src'
import { AppStorageV2, display } from '@kit.ArkUI'
import { IBestGlobalConfig, IBestGlobalConfigType } from '../model/GlobalConfig'

// 全局存储中心
export default class GlobalStore {
	// windowStage
	public static windowStage: window.WindowStage
	// context
	public static context: common.UIAbilityContext
	// 窗口信息
	public static screenWidth: number = 0
	public static windowWidth: number = 0
	public static windowHeight: number = 0
	public static decorHeight: number = 0
	public static isApp: boolean = false
	/**
	 * 初始化
	 */
	public static init(windowStage: window.WindowStage, context: common.UIAbilityContext){
		GlobalStore.windowStage = windowStage
		GlobalStore.context = context
		GlobalStore.getBundleType()
		GlobalStore.getScreenInfo()
		try {
			GlobalStore.setWindowListener()
			GlobalStore.setColorModeListener()
			GlobalStore.getMainWindow().getUIContext().getFont().registerFont({
				familyName: 'ibestFont',
				familySrc: $rawfile('ibest_font.woff')
			})
		}catch (e) {
			console.error(e.code, e.message)
		}
	}
	/**
	 * 获取屏幕信息
	 */
	private static getScreenInfo(){
		const mainWindow: window.Window = GlobalStore.getMainWindow()
		const screenInfo: window.WindowProperties = mainWindow.getWindowProperties()
		GlobalStore.screenWidth = screenInfo.windowRect.width
	}
	/**
	 * 获取规避尺寸
     */
	private static getAvoidSize(size: Size){
		const mainWindow: window.Window = GlobalStore.getMainWindow()
		const avoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
		const systemDht = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
		const topSize = GlobalStore.px2vp(avoidArea.topRect.height)
		const navigationSize = GlobalStore.px2vp(systemDht.bottomRect.height)
		const o = display.getDefaultDisplaySync().orientation
		const decorHeight = mainWindow.getWindowDecorHeight()
		GlobalStore.windowWidth = GlobalStore.px2vp(size.width)
		GlobalStore.windowHeight = GlobalStore.px2vp(size.height)
		GlobalStore.decorHeight = decorHeight
		saveAppStorage(IBestStorageKey.IS_LANDSCAPE, o == 1 || o == 3)
		saveAppStorage(IBestStorageKey.TOP_AVOID_HEIGHT, topSize)
		saveAppStorage(IBestStorageKey.BOTTOM_BAR_HEIGHT, navigationSize)
	}
	/**
	 * 监听窗口尺寸变化
	 */
	public static setWindowListener(){
		GlobalStore.getMainWindow().on("windowSizeChange", size => {
			GlobalStore.getAvoidSize(size)
		})
	}
	/**
	 * 监听配置变化
     */
	private static setColorModeListener(){
		const appContext = GlobalStore.context.getApplicationContext()
		saveAppStorage(IBestStorageKey.COLOR_MODE, GlobalStore.context.config.colorMode as number)
		saveAppStorage(IBestStorageKey.LANGUAGE, GlobalStore.context.config.language as string)
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
	public static setGlobalConfig(option?: Partial<IBestGlobalConfigType>){
		const config = AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG, () => new IBestGlobalConfig(option))
		if(config){
			mergeObject(config, option)
		}else {
			AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG, () => new IBestGlobalConfig(option))
		}
		setIBestUIBaseStyle()
	}
	/**
	 * 获取mainWindow
	 */
	public static getMainWindow(){
		return GlobalStore.windowStage.getMainWindowSync()
	}
	/**
	 * 尺寸转换
	 */
	public static px2vp(value: number){
		return GlobalStore.getMainWindow().getUIContext().px2vp(value)
	}
	public static vp2px(value: number){
		return GlobalStore.getMainWindow().getUIContext().vp2px(value)
	}
}