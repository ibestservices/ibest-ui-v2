/**
 * Host-testable helpers for getComponentsInfo.
 * ArkUI-X Android may leave UIContext.getComponentUtils() undefined.
 */

export type IBestComInfoLike = {
	width: number
	height: number
	localLeft: number
	localTop: number
	screenLeft: number
	screenTop: number
	windowLeft: number
	windowTop: number
}

export type ComponentRectLike = {
	size: { width: number; height: number }
	localOffset: { x: number; y: number }
	screenOffset: { x: number; y: number }
	windowOffset: { x: number; y: number }
}

export type ComponentUtilsLike = {
	getRectangleById: (key: string) => ComponentRectLike
}

export type UIContextLike = {
	getComponentUtils?: () => ComponentUtilsLike | undefined | null
	px2vp: (px: number) => number
}

export function createEmptyComInfo(): IBestComInfoLike {
	return {
		width: 0,
		height: 0,
		localLeft: 0,
		localTop: 0,
		screenLeft: 0,
		screenTop: 0,
		windowLeft: 0,
		windowTop: 0
	}
}

/**
 * Resolve component rect info. When getComponentUtils is missing (ArkUI-X Android),
 * return a zeroed IBestComInfoType instead of throwing.
 */
export function getComponentsInfoSafe(context: UIContextLike, key: string): IBestComInfoLike {
	const utils = context.getComponentUtils ? context.getComponentUtils() : undefined
	if (utils == null) {
		return createEmptyComInfo()
	}
	const info = utils.getRectangleById(key)
	return {
		width: context.px2vp(info.size.width),
		height: context.px2vp(info.size.height),
		localLeft: context.px2vp(info.localOffset.x),
		localTop: context.px2vp(info.localOffset.y),
		screenLeft: context.px2vp(info.screenOffset.x),
		screenTop: context.px2vp(info.screenOffset.y),
		windowLeft: context.px2vp(info.windowOffset.x),
		windowTop: context.px2vp(info.windowOffset.y)
	}
}
