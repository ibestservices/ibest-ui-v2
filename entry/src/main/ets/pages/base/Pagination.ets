import { IBestPagination } from '@ibestservices/ibest-ui-v2';
import { modeColor } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function PaginationBuilder(_: string, title: string){
	PaginationPage({title})
}

@Entry
@ComponentV2
struct PaginationPage {
    @Param title: string = ''

    @Local currentPage: number = 1
    @Local currentPage1: number = 1
    @Local currentPage2: number = 1
    @Local currentPage3: number = 1
    @Local currentPage4: number = 1

    build() {
        NavDestination() {
			CustomNavBar({ title: this.title })
			List(){
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						IBestPagination({
							currentPage: this.currentPage!!,
							totalItems: 24,
							itemsPerPage: 5,
							onChange: (value: number) => {
								console.log('当前页码:', value)
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '简单模式' }) {
						IBestPagination({
							currentPage: this.currentPage1!!,
							pageCount: 12,
							mode: 'simple'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义样式' }) {
						IBestPagination({
							currentPage: this.currentPage2!!,
							totalItems: 24,
							itemsPerPage: 5,
							textColor: "#ddd",
							bgColor: "#13ce66",
							activeBgColor: "#f56c6c"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '显示省略号' }) {
						IBestPagination({
							currentPage: this.currentPage3!!,
							totalItems: 125,
							showPageSize: 3,
							forceEllipses: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义按钮' }) {
						IBestPagination({
							currentPage: this.currentPage4!!,
							totalItems: 125,
							showPageSize: 5,
							prevText: 'prev',
							nextText: 'next'
						})
					}
				}
			}
			.padding({ left: 20, right: 20 })
        }
        .hideTitleBar(true)
        .backgroundColor(modeColor.bg)
    }
}
