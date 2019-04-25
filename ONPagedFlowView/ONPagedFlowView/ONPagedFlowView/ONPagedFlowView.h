//
//  ONPagedFlowView.h
//  scrollViewDemo
//
//  Created by onion on 2019/4/25.
//  Copyright © 2019 onion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONImageSubview.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ONPagedFlowViewDataSource;
@protocol ONPagedFlowViewDelegate;

@interface ONPagedFlowView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic,assign) BOOL needsReload;
/**
 *  总页数
 */
@property (nonatomic,assign) NSInteger pageCount;

@property (nonatomic,strong) NSMutableArray *cells;
@property (nonatomic,assign) NSRange visibleRange;
/**
 *  如果以后需要支持reuseIdentifier，这边就得使用字典类型了
 */
@property (nonatomic,strong) NSMutableArray *reusableCells;

@property (nonatomic,assign)   id <ONPagedFlowViewDataSource> dataSource;
@property (nonatomic,assign)   id <ONPagedFlowViewDelegate>   delegate;

/**
 *  非当前页的透明比例
 */
@property (nonatomic, assign) CGFloat minimumPageAlpha;

/**
 左右间距,默认20
 */
@property (nonatomic, assign) CGFloat leftRightMargin;

/**
 上下间距,默认30
 */
@property (nonatomic, assign) CGFloat topBottomMargin;

/**
 *  当前是第几页
 */
@property (nonatomic, assign, readonly) NSInteger currentPageIndex;

/**
 *  原始页数
 */
@property (nonatomic, assign) NSInteger orginPageCount;

/**
 *  刷新视图
 */
- (void)reloadData;

/**
 *  获取可重复使用的Cell
 */
- (ONImageSubview *)dequeueReusableCell;

/**
 *  滚动到指定的页面
 */
- (void)scrollToPage:(NSUInteger)pageNumber;

/**
 调整中间页居中，经常出现滚动卡住一半时调用
 */
- (void)adjustCenterSubview;

@end


@protocol  ONPagedFlowViewDelegate <NSObject>

@optional
/**
 *  当前显示cell的Size(中间页显示大小)
 */
- (CGSize)sizeForPageInFlowView:(ONPagedFlowView *)flowView;

/**
 *  滚动到了某一列
 */
- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(ONPagedFlowView *)flowView;

/**
 *  点击了第几个cell
 */
- (void)didSelectCell:(ONImageSubview *)subView withSubViewIndex:(NSInteger)subIndex;

@end


@protocol ONPagedFlowViewDataSource <NSObject>

/**
 *  返回显示View的个数
 */
- (NSInteger)numberOfPagesInFlowView:(ONPagedFlowView *)flowView;

/**
 *  给某一列设置属性
 */
- (ONImageSubview *)flowView:(ONPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
