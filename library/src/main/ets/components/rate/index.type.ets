/**
 * rate 选项
 */
@ObservedV2
export class RateOption {
	@Trace value: number = 0
	constructor(value: number) {
		this.value = value
	}
}