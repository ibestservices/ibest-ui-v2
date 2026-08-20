import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { test } from 'node:test'
import { fileURLToPath } from 'node:url'
import { createEmptyComInfo, getComponentsInfoSafe } from '../library/src/main/ets/utils/componentInfo.ts'

const ZEROED = {
	width: 0,
	height: 0,
	localLeft: 0,
	localTop: 0,
	screenLeft: 0,
	screenTop: 0,
	windowLeft: 0,
	windowTop: 0
}

test('createEmptyComInfo returns a zeroed IBestComInfoType', () => {
	assert.deepEqual(createEmptyComInfo(), ZEROED)
})

test('getComponentsInfoSafe does not throw when getComponentUtils returns undefined', () => {
	const context = {
		getComponentUtils: () => undefined,
		px2vp: (px: number) => {
			throw new Error(`px2vp should not run on the guard path, got ${px}`)
		}
	}
	assert.doesNotThrow(() => getComponentsInfoSafe(context, 'ibest_rate_1'))
	assert.deepEqual(getComponentsInfoSafe(context, 'ibest_rate_1'), ZEROED)
})

test('getComponentsInfoSafe does not throw when getComponentUtils is missing', () => {
	const context = {
		px2vp: (px: number) => px
	}
	assert.doesNotThrow(() => getComponentsInfoSafe(context, 'ibest_swipe_left_1'))
	assert.deepEqual(getComponentsInfoSafe(context, 'ibest_noticeBar_1'), ZEROED)
})

test('getComponentsInfoSafe maps rectangle values when ComponentUtils exists', () => {
	const context = {
		getComponentUtils: () => ({
			getRectangleById: (key: string) => {
				assert.equal(key, 'ibest_cell_1')
				return {
					size: { width: 20, height: 10 },
					localOffset: { x: 2, y: 4 },
					screenOffset: { x: 6, y: 8 },
					windowOffset: { x: 10, y: 12 }
				}
			}
		}),
		px2vp: (px: number) => px / 2
	}
	assert.deepEqual(getComponentsInfoSafe(context, 'ibest_cell_1'), {
		width: 10,
		height: 5,
		localLeft: 1,
		localTop: 2,
		screenLeft: 3,
		screenTop: 4,
		windowLeft: 5,
		windowTop: 6
	})
})

test('utils.ets getComponentsInfo delegates to the guarded helper', () => {
	const here = dirname(fileURLToPath(import.meta.url))
	const source = readFileSync(join(here, '../library/src/main/ets/utils/utils.ets'), 'utf8')
	assert.match(source, /getComponentsInfoSafe/)
	assert.doesNotMatch(source, /context\.getComponentUtils\(\)\.getRectangleById/)
})
