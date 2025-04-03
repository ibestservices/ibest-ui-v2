/**
 * 订阅发布模式
 * 为啥不用鸿蒙的？
 * 怕和业务影响 因为鸿蒙自带的是用事件id区分的。。。
 */
class EventEmitter {
	//用于存储事件及其处理函数
	events = {};
	// 订阅事件
	on(eventName, id, listener) {
		if (!this.events[eventName]) {
			this.events[eventName] = []
		}
		this.events[eventName].push({
			id,
			listener
		})
	}
	// 取消订阅事件
	off(eventName, id) {
		if (!this.events[eventName]) {
			return
		}
		this.events[eventName] = this.events[eventName].filter(e => e.id != id)
	}
	// 发布事件
	emit(eventName, ...args) {
		if (!this.events[eventName]) {
			return
		}
		this.events[eventName].forEach(e => e.listener.apply(this, args))
	}
}
export const emitter = new EventEmitter()