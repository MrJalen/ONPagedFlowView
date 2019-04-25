//
//  ONImageSubview.h
//  scrollViewDemo
//
//  Created by onion on 2019/4/25.
//  Copyright © 2019 onion. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ONImageSubview : UIView

/**
 *  主图
 */
@property (nonatomic, strong) UIImageView *mainImageView;

/**
 *  用来变色的view
 */
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, copy) void (^didSelectCellBlock)(NSInteger tag, ONImageSubview *cell);

/**
 设置子控件frame,继承后要重写
 
 @param superViewBounds superViewBounds description
 */
- (void)setSubviewsWithSuperViewBounds:(CGRect)superViewBounds;

@end

NS_ASSUME_NONNULL_END
