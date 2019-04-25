//
//  ONPagedFlowView.m
//  scrollViewDemo
//
//  Created by onion on 2019/4/25.
//  Copyright © 2019 onion. All rights reserved.
//

#import "ONPagedFlowView.h"

@interface ONPagedFlowView ()

@property (nonatomic, assign, readwrite) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger page;
/**
 *  一页的尺寸
 */
@property (nonatomic,assign) CGSize pageSize;

@end

//子控制器的类名
static NSString *subviewClassName;

@implementation ONPagedFlowView

#pragma mark -  Private Methods
- (void)initialize {
	self.clipsToBounds = YES;
	
	self.needsReload = YES;
	self.pageCount = 0;
	self.leftRightMargin = 30;
	self.topBottomMargin = 30;
	_currentPageIndex = 0;
	
	_minimumPageAlpha = 1.0;
	
	self.visibleRange = NSMakeRange(0, 0);
	
	self.reusableCells = [[NSMutableArray alloc] initWithCapacity:0];
	self.cells = [[NSMutableArray alloc] initWithCapacity:0];
	
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	self.scrollView.scrollsToTop = NO;
	self.scrollView.delegate = self;
	self.scrollView.pagingEnabled = YES;
	self.scrollView.clipsToBounds = NO;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	
	subviewClassName = @"ONImageSubview";
	[self addSubview:self.scrollView];
}

- (void)setLeftRightMargin:(CGFloat)leftRightMargin {
	_leftRightMargin = leftRightMargin * 0.5;
}

- (void)setTopBottomMargin:(CGFloat)topBottomMargin {
	_topBottomMargin = topBottomMargin * 0.5;
}


- (void)adjustCenterSubview {
	if (self.orginPageCount > 0) {
		[_scrollView setContentOffset:CGPointMake(_pageSize.width * self.page, 0) animated:NO];
	}
}

- (void)queueReusableCell:(ONImageSubview *)cell {
	[_reusableCells addObject:cell];
}

- (void)removeCellAtIndex:(NSInteger)index {
	ONImageSubview *cell = [_cells objectAtIndex:index];
	if ((NSObject *)cell == [NSNull null]) {
		return;
	}
	[self queueReusableCell:cell];
	
	if (cell.superview) {
		[cell removeFromSuperview];
	}
	[_cells replaceObjectAtIndex:index withObject:[NSNull null]];
}

- (void)refreshVisibleCellAppearance {
	if (_minimumPageAlpha == 1.0 && self.leftRightMargin == 0 && self.topBottomMargin == 0) {
		return;
	}
	CGFloat offset = _scrollView.contentOffset.x;
	
	for (NSInteger i = self.visibleRange.location; i < self.visibleRange.location + _visibleRange.length; i++) {
		ONImageSubview *cell = [_cells objectAtIndex:i];
		subviewClassName = NSStringFromClass([cell class]);
		CGFloat origin = cell.frame.origin.x;
		CGFloat delta = fabs(origin - offset);
		
		CGRect originCellFrame = CGRectMake(_pageSize.width * i, 0, _pageSize.width, _pageSize.height);//如果没有缩小效果的情况下的本该的Frame
		if (delta < _pageSize.width) {
			cell.coverView.alpha = (delta / _pageSize.width) * _minimumPageAlpha;
			
			// 大小缩放
			CGFloat leftRightInset = self.leftRightMargin * delta / _pageSize.width;
			CGFloat topBottomInset = self.topBottomMargin * delta / _pageSize.width;
			cell.layer.transform = CATransform3DMakeScale((_pageSize.width-leftRightInset*2)/_pageSize.width,(_pageSize.height-topBottomInset*2)/_pageSize.height, 1.0);
			cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
		} else {
			cell.coverView.alpha = _minimumPageAlpha;
			
			// 大小缩放
			cell.layer.transform = CATransform3DMakeScale((_pageSize.width-self.leftRightMargin*2)/_pageSize.width,(_pageSize.height-self.topBottomMargin*2)/_pageSize.height, 1.0);
			cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(self.topBottomMargin, self.leftRightMargin, self.topBottomMargin, self.leftRightMargin));
		}
	}
}

- (void)setPageAtIndex:(NSInteger)pageIndex {
	NSParameterAssert(pageIndex >= 0 && pageIndex < [_cells count]);
	ONImageSubview *cell = [_cells objectAtIndex:pageIndex];
	
	if ((NSObject *)cell == [NSNull null]) {
		cell = [_dataSource flowView:self cellForPageAtIndex:pageIndex % self.orginPageCount];
		NSAssert(cell!=nil, @"datasource must not return nil");
		[_cells replaceObjectAtIndex:pageIndex withObject:cell];
		
		cell.tag = pageIndex % self.orginPageCount;
		// 每个 卡片frame
		[cell setSubviewsWithSuperViewBounds:CGRectMake(0, 0, _pageSize.width, _pageSize.height)];
		
		__weak __typeof(self) weakSelf = self;
		cell.didSelectCellBlock = ^(NSInteger tag, ONImageSubview *cell) {
			[weakSelf singleCellTapAction:tag withCell:cell];
		};
		
		// 不是缩放动画  此处需对每个cell的frame进行设置
		if (pageIndex == 0) {
			cell.frame = CGRectMake( -25, 0, _pageSize.width, _pageSize.height);
		} else {
			cell.frame = CGRectMake(_pageSize.width * pageIndex - 25, 0, _pageSize.width, _pageSize.height);
		}

		if (!cell.superview) {
			[_scrollView addSubview:cell];
		}
	}
}

- (void)setPagesAtContentOffset:(CGPoint)offset {
	//计算_visibleRange
	CGPoint startPoint = CGPointMake(offset.x - _scrollView.frame.origin.x, offset.y - _scrollView.frame.origin.y);
	CGPoint endPoint = CGPointMake(startPoint.x + self.bounds.size.width, startPoint.y + self.bounds.size.height);
	
	NSInteger startIndex = 0;
	for (int i =0; i < [_cells count]; i++) {
		if (_pageSize.width * (i +1) > startPoint.x) {
			startIndex = i;
			break;
		}
	}
	
	NSInteger endIndex = startIndex;
	for (NSInteger i = startIndex; i < [_cells count]; i++) {
		//如果都不超过则取最后一个
		if ((_pageSize.width * (i + 1) < endPoint.x && _pageSize.width * (i + 2) >= endPoint.x) || i+ 2 == [_cells count]) {
			endIndex = i + 1;//i+2 是以个数，所以其index需要减去1
			break;
		}
	}
	
	//可见页分别向前向后扩展一个，提高效率
	startIndex = MAX(startIndex - 1, 0);
	endIndex = MIN(endIndex + 1, [_cells count] - 1);
	
	self.visibleRange = NSMakeRange(startIndex, endIndex - startIndex + 1);
	for (NSInteger i = startIndex; i <= endIndex; i++) {
		[self setPageAtIndex:i];
	}
	
	for (int i = 0; i < startIndex; i ++) {
		[self removeCellAtIndex:i];
	}
	
	for (NSInteger i = endIndex + 1; i < [_cells count]; i ++) {
		[self removeCellAtIndex:i];
	}
}

#pragma mark - Override Methods
- (id)initWithFrame:(CGRect)frame {
	if (self == [super initWithFrame:frame]) {
		[self initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self == [super initWithCoder:aDecoder]) {
		[self initialize];
	}
	return self;
}


#pragma mark - ONPagedFlowView API
- (void)reloadData {
	_needsReload = YES;
	
	//移除所有self.scrollView的子控件
	for (UIView *view in self.scrollView.subviews) {
		if ([NSStringFromClass(view.class) isEqualToString:subviewClassName] || [view isKindOfClass:[ONImageSubview class]]) {
			[view removeFromSuperview];
		}
	}
	
	if (_needsReload) {
		//重置pageCount
		if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInFlowView:)]) {
			
			//原始页数
			self.orginPageCount = [_dataSource numberOfPagesInFlowView:self];
			
			//总页数
			_pageCount = self.orginPageCount == 1 ? 1: [_dataSource numberOfPagesInFlowView:self];
			
			//如果总页数为0，return
			if (_pageCount == 0) {
				return;
			}
		}
		
		//重置pageWidth
		_pageSize = CGSizeMake(self.bounds.size.width - 4 * self.leftRightMargin, (self.bounds.size.width - 4 * self.leftRightMargin) * 9 /16);
		if (self.delegate && self.delegate && [self.delegate respondsToSelector:@selector(sizeForPageInFlowView:)]) {
			_pageSize = [self.delegate sizeForPageInFlowView:self];
		}
		
		[_reusableCells removeAllObjects];
		_visibleRange = NSMakeRange(0, 0);
		
		//填充cells数组
		[_cells removeAllObjects];
		for (NSInteger index=0; index<_pageCount; index++) {
			[_cells addObject:[NSNull null]];
		}
		
		// 重置_scrollView的contentSize
		_scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
		_scrollView.contentSize = CGSizeMake(_pageSize.width * _pageCount,0);
		CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		_scrollView.center = theCenter;
		
		if (self.orginPageCount > 1) {
			//滚到开始
			[_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
			self.page = self.orginPageCount;
		}
		_needsReload = NO;
	}
	
	[self setPagesAtContentOffset:_scrollView.contentOffset];//根据当前scrollView的offset设置cell
	[self refreshVisibleCellAppearance];//更新各个可见Cell的显示外貌
}

- (ONImageSubview *)dequeueReusableCell {
	ONImageSubview *cell = [_reusableCells lastObject];
	if (cell) {
		[_reusableCells removeLastObject];
	}
	
	return cell;
}

- (void)scrollToPage:(NSUInteger)pageNumber {
	if (pageNumber < _pageCount) {
		self.page = pageNumber;
		[_scrollView setContentOffset:CGPointMake(_pageSize.width * self.page, 0) animated:YES];
		[self setPagesAtContentOffset:_scrollView.contentOffset];
		[self refreshVisibleCellAppearance];
	}
}

#pragma mark - hitTest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if ([self pointInside:point withEvent:event]) {
		CGPoint newPoint = CGPointZero;
		newPoint.x = point.x - _scrollView.frame.origin.x + _scrollView.contentOffset.x;
		newPoint.y = point.y - _scrollView.frame.origin.y + _scrollView.contentOffset.y;
		if ([_scrollView pointInside:newPoint withEvent:event]) {
			return [_scrollView hitTest:newPoint withEvent:event];
		}
		return _scrollView;
	}
	return nil;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (self.orginPageCount == 0) {
		return;
	}
	
	NSInteger pageIndex;
	pageIndex = (int)round(_scrollView.contentOffset.x / _pageSize.width) % self.orginPageCount;
	
	[self setPagesAtContentOffset:scrollView.contentOffset];
	[self refreshVisibleCellAppearance];
	
	if (_delegate && [_delegate respondsToSelector:@selector(didScrollToPage:inFlowView:)] && _currentPageIndex != pageIndex && pageIndex >= 0) {
		[_delegate didScrollToPage:pageIndex inFlowView:self];
	}
	_currentPageIndex = pageIndex;
}

#pragma mark --将要开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
}

#pragma mark --结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
}

#pragma mark --将要结束拖拽
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (self.orginPageCount > 1) {
		if (self.page == floor(_scrollView.contentOffset.x / _pageSize.width)) {
			self.page = floor(_scrollView.contentOffset.x / _pageSize.width) + 1;
		} else {
			self.page = floor(_scrollView.contentOffset.x / _pageSize.width);
		}
	}
}

//点击了cell
- (void)singleCellTapAction:(NSInteger)selectTag withCell:(ONImageSubview *)cell {
	if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCell:withSubViewIndex:)]) {
		[self.delegate didSelectCell:cell withSubViewIndex:selectTag];
	}
}

@end
