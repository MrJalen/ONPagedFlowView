//
//  ONImageSubview.m
//  scrollViewDemo
//
//  Created by onion on 2019/4/25.
//  Copyright © 2019 onion. All rights reserved.
//

#import "ONImageSubview.h"

@implementation ONImageSubview

- (instancetype)initWithFrame:(CGRect)frame {
	if (self == [super initWithFrame:frame]) {
		[self addSubview:self.mainImageView];
		[self addSubview:self.coverView];
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleCellTapAction:)];
		[self addGestureRecognizer:singleTap];
	}
	return self;
}

- (void)singleCellTapAction:(UIGestureRecognizer *)gesture {
	if (self.didSelectCellBlock) {
		self.didSelectCellBlock(self.tag, self);
	}
}

- (void)setSubviewsWithSuperViewBounds:(CGRect)superViewBounds {
	if (CGRectEqualToRect(self.mainImageView.frame, superViewBounds)) {
		return;
	}
	self.mainImageView.frame = superViewBounds;
	self.coverView.frame = superViewBounds;
}

- (UIImageView *)mainImageView {
	if (_mainImageView == nil) {
		_mainImageView = [[UIImageView alloc] init];
		_mainImageView.userInteractionEnabled = YES;
	}
	return _mainImageView;
}

- (UIView *)coverView {
	if (_coverView == nil) {
		_coverView = [[UIView alloc] init];
		_coverView.backgroundColor = [UIColor clearColor];
	}
	return _coverView;
}

@end
