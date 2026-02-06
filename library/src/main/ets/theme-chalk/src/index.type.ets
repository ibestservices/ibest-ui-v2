import { convertDimensionsWidthUnit } from '../../utils/utils'
import { BORDER_RADIUS } from './border'
import { BorderRadiusData } from './border.type'
import { COLOR_OPACITY, THEME_COLOR } from './color'
import { ColorData } from './color.type'
import { FONT_SIZE } from './font'
import { FontSizeData } from './font.type'
import { LINE_HEIGHT } from './line-height'
import { LineHeightData } from './line-height.type'
import { SPACE } from './space'
import { SpaceData } from './space.type'

/**
 * 根据默认的兜底style生成的类型
 */
export interface IBestUIBaseStyleType extends FontSizeData, ColorData, SpaceData, BorderRadiusData, LineHeightData {
	// 滚动效果
	scrollEdgeEffect: EdgeEffect,
	// 滚动条颜色
	scrollBarColor: string,
	animationDuration: number
}

@ObservedV2
export class IBestUIBaseStyle implements IBestUIBaseStyleType {
	@Trace default: ResourceColor
	@Trace primary: ResourceColor
	@Trace success: ResourceColor
	@Trace warning: ResourceColor
	@Trace danger: ResourceColor
	@Trace primaryOpacity: ResourceColor
	@Trace successOpacity: ResourceColor
	@Trace warningOpacity: ResourceColor
	@Trace dangerOpacity: ResourceColor
	@Trace spaceMini: string
	@Trace spaceBase: string
	@Trace spaceX: string
	@Trace spaceXs: string
	@Trace spaceSm: string
	@Trace spaceXsm: string
	@Trace spaceMd: string
	@Trace spaceLg: string
	@Trace spaceXl: string
	@Trace fontSizeXs: string
	@Trace fontSizeSm: string
	@Trace fontSizeMd: string
	@Trace fontSizeLg: string
	@Trace fontSizeXl: string
	@Trace borderRadiusSm: string
	@Trace borderRadiusMd: string
	@Trace borderRadiusLg: string
	@Trace borderRadiusXl: string
	@Trace borderRadiusMax: string
	@Trace lineHeightXs: string
	@Trace lineHeightXsm: string
	@Trace lineHeightSm: string
	@Trace lineHeightMd: string
	@Trace lineHeightLg: string
	@Trace scrollEdgeEffect: EdgeEffect
	@Trace scrollBarColor: string
	@Trace animationDuration: number
	constructor(value: Partial<IBestUIBaseStyleType>) {
		this.default = value.default ?? THEME_COLOR.DEFAULT
		this.primary = value.primary ?? THEME_COLOR.PRIMARY
		this.success = value.success ?? THEME_COLOR.SUCCESS
		this.warning = value.warning ?? THEME_COLOR.WARNING
		this.danger = value.danger ?? THEME_COLOR.DANGER
		this.primaryOpacity = value.primaryOpacity ?? COLOR_OPACITY.PRIMARY
		this.successOpacity = value.successOpacity ?? COLOR_OPACITY.SUCCESS
		this.warningOpacity = value.warningOpacity ?? COLOR_OPACITY.WARNING
		this.dangerOpacity = value.dangerOpacity ?? COLOR_OPACITY.DANGER
		this.spaceMini = value.spaceMini ?? convertDimensionsWidthUnit(SPACE.MINI)
		this.spaceBase = value.spaceBase ?? convertDimensionsWidthUnit(SPACE.BASE)
		this.spaceX = value.spaceX ?? convertDimensionsWidthUnit(SPACE.X)
		this.spaceXs = value.spaceXs ?? convertDimensionsWidthUnit(SPACE.XS)
		this.spaceSm = value.spaceSm ?? convertDimensionsWidthUnit(SPACE.SM)
		this.spaceXsm = value.spaceXsm ?? convertDimensionsWidthUnit(SPACE.XSM)
		this.spaceMd = value.spaceMd ?? convertDimensionsWidthUnit(SPACE.MD)
		this.spaceLg = value.spaceLg ?? convertDimensionsWidthUnit(SPACE.LG)
		this.spaceXl = value.spaceXl ?? convertDimensionsWidthUnit(SPACE.XL)
		this.fontSizeXs = value.fontSizeXs ?? convertDimensionsWidthUnit(FONT_SIZE.XS, true)
		this.fontSizeSm = value.fontSizeSm ?? convertDimensionsWidthUnit(FONT_SIZE.SM, true)
		this.fontSizeMd = value.fontSizeMd ?? convertDimensionsWidthUnit(FONT_SIZE.MD, true)
		this.fontSizeLg = value.fontSizeLg ?? convertDimensionsWidthUnit(FONT_SIZE.LG, true)
		this.fontSizeXl = value.fontSizeXl ?? convertDimensionsWidthUnit(FONT_SIZE.XL, true)
		this.borderRadiusSm = value.borderRadiusSm ?? convertDimensionsWidthUnit(BORDER_RADIUS.SM)
		this.borderRadiusMd = value.borderRadiusMd ?? convertDimensionsWidthUnit(BORDER_RADIUS.MD)
		this.borderRadiusLg = value.borderRadiusLg ?? convertDimensionsWidthUnit(BORDER_RADIUS.LG)
		this.borderRadiusXl = value.borderRadiusXl ?? convertDimensionsWidthUnit(BORDER_RADIUS.XL)
		this.borderRadiusMax = value.borderRadiusMax ?? convertDimensionsWidthUnit(BORDER_RADIUS.MAX)
		this.lineHeightXs = value.lineHeightXs ?? convertDimensionsWidthUnit(LINE_HEIGHT.XS)
		this.lineHeightXsm = value.lineHeightXsm ?? convertDimensionsWidthUnit(LINE_HEIGHT.XSM)
		this.lineHeightSm = value.lineHeightSm ?? convertDimensionsWidthUnit(LINE_HEIGHT.SM)
		this.lineHeightMd = value.lineHeightMd ?? convertDimensionsWidthUnit(LINE_HEIGHT.MD)
		this.lineHeightLg = value.lineHeightLg ?? convertDimensionsWidthUnit(LINE_HEIGHT.LG)
		this.scrollEdgeEffect = value.scrollEdgeEffect ?? EdgeEffect.Fade
		this.scrollBarColor = value.scrollBarColor ?? '#dbdfe6'
		this.animationDuration = value.animationDuration ?? 200
	}
}

export type IBestUIBaseStyleValue = ResourceColor | EdgeEffect
export type IBestUIBaseStyleObjType = Record<keyof IBestUIBaseStyleType, IBestUIBaseStyleValue>