# 版本记录

## 1.1.2 - 6.0.1(21)
#### 新增:
1. 新增 IBestTabBar 标签栏 组件;
2. IBestCell 新增 valueFontSize 属性;
3. IBestSearch 新增 caretColor属性;
4. IBestBadge、IBestAvatar 新增 xOffset、yOffset 属性;
5. IBestCard 新增 leftIcon、leftIconColor、leftIconSize、value、valueColor、valueFontSize;
6. IBestTabs、IBestSegmented 选项支持动态更新;
7. IBestSegmented options 新增 IBestSegmentedItem 类型;
8. IBestTable 新增 scrollBarState 属性, 支持设置多级表头.

#### 优化:
1. IBestCaliper 性能优化;
2. IBestPullRefresh 内容高度优化.

## 1.1.1
#### 新增:
1. 新增 IBestWeekPicker 周选择 组件;
2. 新增 IBestCard 卡片 组件;
3. 新增 IBestMosaic 马赛克 组件;
4. 新增 IBestGridsAlbum 九宫格相册 组件;
5. 新增 IBestInputTag 标签输入框 组件;
6. IBestCalendar 支持滑动切换月份;
7. IBestPicker、IBestDatePicker、IBestDateTimePicker、IBestTimePicker 新增 fontColor、fontWeight、selectedFontSize、selectedFontColor、selectedFontWeight 属性;
8. IBestTable 新增 spanMethod 属性,支持合并单元格;
9. IBestContactAddress 新增 regionData 属性;
10. IBestFloatBubble isMagnetic autoHide支持动态更新.

#### 优化:
1. 移除 @ibestservices/area-data、dayjs、Lunar 依赖.

#### bug修复:
1. IBestNavBar 标题居左,且右侧自定义超过两个图标时,标题位置显示异常问题.

## 1.0.7
#### 新增:
1. 新增 IBestTree 树形控件;
2. 全局配置新增 fontNames 属性,支持在包含图标的组件上使用自定义图标;
3. IBestButton 新增 btnBorder 属性;
4. IBestCascader 新增 selectAnyLevel 属性;
5. IBestCheckbox 新增 radius 属性;
6. IBestField required rules支持动态验证;
7. IBestToast show方法支持Resource类型;
8. IBestActionSheet 新增 keyboardAvoidMode 属性;
9. IBestProgress 新增 radius 属性;
10. IBestSteps 支持异步、动态更新.

#### bug修复:
1. IBestCaliper 小数刻度显示问题;
2. IBestImagePreview closeOnClickImage为false时不生效问题，优化性能;
3. IBestPullRefresh onRefresh 初始状态时重复执行问题.

## 1.0.5 - 5.1.1(19)
#### 新增:
1. 新增 IBestPrice 价格组件;
2. 新增 IBestRollingText 翻滚文本组件;
3. IBestSwitch 新增 componentWidth componentPadding activeText inactiveText activeIcon inactiveIcon textFontSize activeTextColor inactiveTextColor activeValue inactiveValue 属性;
4. IBestField 新增 inputFilter 属性;
5. IBestForm 新增导出 IBestFieldValidateInfo IBestFormValidateResult IBestFieldValidateResult 类型;
6. IBestSlider 新增 onTouchStart onTouchMove onTouchEnd 事件;
7. IBestHighLight 新增 lineHeight 属性;
8. IBestPullRefresh 支持自动下拉加载;
9. IBestSideBarItem 新增 contentPadding 属性.

#### bug修复:
1. IBestSideBarItem defaultBuilder不生效问题;
2. IBestNavBar isShowRight动态配置时右侧间距问题;
3. IBestTableColumn cellAlign 不生效问题;
4. IBestStepper onChange事件参数在非双向绑定时异常问题.

## 1.0.4
#### 新增：
1. 新增 IBestCaliper 卡尺 组件;
2. 新增 IBestReadMore 查看更多 组件;
3. 新增 IBestSegmented 分段控制器 组件;
4. IBestIcon 新增 iconAnimation 属性;
5. IBestActionSheet onSelect 新增 name 参数;
6. IBestSlider 新增 ticks 属性;
7. IBestStepper 新增 minusBtnBgColor minusBtnBorderColor minusBtnIconColor plusBtnBgColor plusBtnBorderColor plusBtnIconColor inputBgColor 属性.

#### bug修复:
1. IBestPicker 选项value值为0时切换返回空问题;
2. IBestCascader 异步加载方式重复打开报错问题;
3. IBestRadio type为dot时中心不显示问题.

## 1.0.3
#### 新增:
1. IBestIcon 新增 fontName 属性,支持使用自定义图标;
2. IBestCalendar 新增 value 属性, 支持双向绑定;
3. IBestSearch 新增 outPadding 属性;
4. IBestDropdownMenu 新增 dropDownIconSize 属性, IBestDropdownItem 新增 maxHeight beforeOpen 事件, IBestDropdownMenuOption 新增 iconPosition 属性;
5. IBestHighlight 新增 onKeywordClick 事件;
6. IBestImageCropper 新增 enableRotate maxAngle 属性, IBestImageCropperController 新增 setScale setAngle reset 方法;
7. IBestTabItemType 新增 iconPosition 属性.

#### 优化:
1. IBestCollapseItem readOnly为true时不显示右侧箭头.

#### bug修复:
1. IBestSteps type为num类型时，activeColor 属性未生效问题;
2. IBestColorPicker 滑动时色相滑块抖动问题;
3. IBestSideBar maxHeight 无效问题;
4. IBestCollapseItem isShowBorder 无效问题;
5. IBestTable 高度问题;
6. 部分组件 Monitor 传参问题.

## 1.0.2
#### 新增：
1. IBestCheckBox value值新增 string number 类型，新增 trueValue falseValue 属性;
2. IBestField 新增 inputFontColor borderSizeType borderLeft fieldPadding bdColor prefixIcon prefixSize suffixIcon suffixSize showValue 属性, type 新增 new-password 类型;
3. IBestForm 新增 setFormValues 方法.

#### 优化：
1. IBestCheckBox 异步切换时动画.

#### bug修复：
1. IBestCellGroup 在存在title时，顶部圆角不生效问题;
2. IBestForm value为boolean类型且自定义表单项时，值为false会触发校验问题;
3. IBestTextEllipsis 字符串中有表情时行数异常问题;
4. IBestDropdownMenu 在close方法执行多次时报错问题;
5. IBestPasswordInput 在使用系统键盘时无法输入问题;
6. IBestField 在传入number类型的值时无法初始赋值问题;
7. 修复在5.0.5编辑器下stepper报错问题.

## 1.0.1
#### 新增:
1. 新增 IBestAvatar 头像组件;
2. 新增 IBestAvatarGroup 头像组组件;
3. 新增 IBestSectorProgress 扇形进度条;
4. IBestButton 新增 btnPadding stateEffect 属性;
5. IBestCellGroup 新增 outerMargin 属性;
6. IBestPicker IBestDatePicker IBestDateTimePicker IBestTimePicker 新增 radius 属性;
7. IBestDivider 新增 dashGap dashWidth rightLineColor rightDashed 属性;
8. IBestBadge 新增 icon iconSize iconColor 属性;
9. IBestTabs 新增 outerRadius 属性;
10. 全局配置新增 avatar 属性;

#### Bug修复:
1. IBestCollapseItem 内容变化时高度未自适应问题;
2. IBestSteps 步骤较多时进度与点无法对齐问题;
3. IBestStepper 有小数时无法增加问题;
4. IBestDropdownMenu 在页面返回没有关闭问题;

## 0.0.9 - 5.0.5(17)
#### 新增:
1. 新增 IBestContactAddress 联系人地址组件;
2. IBestCell 新增 arrowSize arrowColor cellPadding 属性;
3. IBestCalendar 新增 showOtherMonthDate 属性;
4. IBestCountDown 新增 onFinish 事件;
5. IBestCountTo 新增 onFinish 事件;
6. IBestDatePicker 新增 lunar 属性, 支持显示农历;
7. IBestNavbar 新增 expandSafeAreaType 属性;
8. IBestUpload 新增 imageSelectOption fileSelectOption beforeRemove 属性, onRemove onFileClick 事件; IBestUploaderFile 类型新增 uploadUrl 属性;
9. IBestTextEllipsis 新增 textFontWeight actionFontWeight 属性;
10. IBestHighLight keywords 新增 IBestHighlightKeywords 类型, 支持设置不同颜色、字体大小的高亮词;
11. IBestSteps 新增 bgColor 属性.

#### 优化:
1. IBestCell 传入rightIcon时保留箭头, 左右图标支持内置图标名;
2. 部分组件 radius 支持自定义设置位置.

#### Bug修复:
1. IBestTable 自定义表格内容时，边框线高度不一致问题;
2. IBestButton btnBorderRadius 0未生效问题;
3. IBestProgress 进度条宽度较宽时文字错位问题;
4. IBestHighlight text动态修改时，文字未同步变化问题;
5. IBestField autosize 为true时 inputAlign不生效问题.

## 0.0.7
#### 新增:
1. IBestDropdownMenu 下拉菜单组件;
2. IBestGuide 引导组件;
3. IBestToast 增加 onClosed 事件;
4. IBestCellGroup 增加 titlePadding;
5. IBestCell 增加 titleFontSize labelFontSize 属性;
6. IBestSlider 增加 customSecondButton 属性.

#### 优化:
1. IBestCascader 选项支持动态传入;
2. IBestCell 使用valueBuilder时保留箭头;
3. IBestCollapse 支持activeName切换;
4. IBestCollapseItem 优化高度获取;
5. IBestPopup 优化居中时关闭的延迟.

#### Bug修复:
1. IBestNoticeBar 在文字未超出宽度时也会自动滚动问题;
2. IBestFloatBubble 点击穿透问题.

## 0.0.6
#### 新增:
1. IBestFloatBubble 悬浮球 组件;
2. IBestCarKeyboard 车牌键盘 组件;
3. IBestCarInput 车牌输入框 组件;
4. IBestPasswordInput 增加 autoFocus showCursor highlightType 属性;
5. IBestWatermark 增加 contentInteractive 属性.

#### 优化:
1. 日历农历初一日显示为月份.

#### Bug修复:
1. IBestImagePreview 侧滑关闭后无法打开问题;
2. 修复 IBestDialog buttonSpace 不生效问题.

## 0.0.5
#### 新增:
1. IBestCountTo 数字滚动 组件;
2. IBestSkeleton 骨架屏 组件;
3. IBestSteps 步骤条 组件;
4. IBestPopup  增加  keyboardAvoidMode keyboardAvoidDistance levelMode levelUniqueId 参数;
5. IBestDialog 增加 keyboardAvoidMode 参数;
6. IBestCheckGroup、IBestRadioGroup 增加 disabled 参数.

#### Bug修复:
1. IBestActionSheet IBestDialogUtil 优化多窗口关闭;
2. IBestPasswordInput 最后一位输入问题;
3. IBestCheckBox 禁用状态在分组中失效问题;
4. IBestStepper 输入时无法限制大小问题.

## 0.0.4 - 5.0.3(15)
#### Bug修复:
1. 部分组件报错问题。