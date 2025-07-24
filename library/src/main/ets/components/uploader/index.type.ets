/**
 * 选择类型
 */
export type IBestUploaderSelectType = "image" | "file"
/**
 * 上传文件类型
 */
@ObservedV2
class IBestUploaderFileType{
	/**
	 * 文件在线地址
     */
	@Trace url?: string = ""
	/**
	 * internal协议地址
     */
	@Trace internalUri?: string
	/**
	 * 预览文件地址
     */
	@Trace previewUri?: string = ""
	/**
	 * 缓存地址
     */
	@Trace cacheUri?: string
	/**
	 * 文件名称
     */
	@Trace name?: string = ""
	/**
	 * 文件大小 单位Byte
     */
	@Trace size?: number
	/**
	 * 是否是图片
     */
	@Trace isImage?: boolean
	/**
	 * 上传状态
     */
	@Trace status?: 'ready' | 'uploading' | 'failed' | 'done'
	/**
	 * 上传后地址
	 * @since 0.0.8
	 */
	@Trace uploadUrl?: string
}
export class IBestUploaderFile extends IBestUploaderFileType{
	constructor(value: IBestUploaderFileType) {
		super()
		this.url = value.url || ''
		this.internalUri = value.internalUri || ''
		this.previewUri = value.previewUri || ''
		this.cacheUri = value.cacheUri || ''
		this.name = value.name || ''
		this.size = value.size || 0
		this.isImage = value.isImage || false
		this.status = value.status
		this.uploadUrl = value.uploadUrl || ''
	}
}
/**
 * 文件选择配置项
 */
export interface FileSelectOptions{
	defaultFilePathUri?: string
	fileSuffixFilters?: string[]
}