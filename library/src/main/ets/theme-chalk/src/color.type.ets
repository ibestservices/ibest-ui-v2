export interface ThemeColor {
	DEFAULT: ResourceColor
	PRIMARY: ResourceColor
	SUCCESS: ResourceColor
	WARNING: ResourceColor
	DANGER: ResourceColor
}
/**
 * 灰色
 */
export interface GrayColor {
	GRAY_1: ResourceColor
	GRAY_2: ResourceColor
	GRAY_3: ResourceColor
	GRAY_4: ResourceColor
	GRAY_5: ResourceColor
	GRAY_6: ResourceColor
	GRAY_7: ResourceColor
	GRAY_8: ResourceColor
}
/**
 * 颜色类型枚举
 */
export enum COLOR_TYPE {
	/**
	 * 默认
	 */
	DEFAULT = 'default',
	/**
	 * 主要的
	 */
	PRIMARY = 'primary',
	/**
	 * 成功
	 */
	SUCCESS = 'success',
	/**
	 * 危险
	 */
	DANGER = 'danger',
	/**
	 * 警告
	 */
	WARNING = 'warning'
}
/**
 * 颜色类型
 */
export type ColorType = `${COLOR_TYPE}`

/**
 * 主题透明
 */
export enum COLOR_OPACITY_TYPE {
	/**
	 * 主要透明
     */
	PRIMARY_OPACITY = 'primaryOpacity',
	/**
	 * 成功透明
     */
	SUCCESS_OPACITY = 'successOpacity',
	/**
	 * 警告透明
	 */
	WARNING_OPACITY = 'warningOpacity',
	/**
	 * 危险透明
	 */
	DANGER_OPACITY = 'dangerOpacity'
}
export type ColorOpacityType = `${COLOR_OPACITY_TYPE}`

export interface ColorData {
	default: ResourceColor;
	primary: ResourceColor;
	success: ResourceColor;
	warning: ResourceColor;
	danger: ResourceColor;
	primaryOpacity: ResourceColor;
	successOpacity: ResourceColor;
	warningOpacity: ResourceColor;
	dangerOpacity: ResourceColor;
}