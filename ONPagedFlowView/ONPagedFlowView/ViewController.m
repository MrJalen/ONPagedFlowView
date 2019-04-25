//
//  ViewController.m
//  ONPagedFlowView
//
//  Created by onion on 2019/4/25.
//  Copyright © 2019 onion. All rights reserved.
//

#define K_Width  [UIScreen mainScreen].bounds.size.width
#define K_Height [UIScreen mainScreen].bounds.size.height

#define kIsiPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
#define kTitleViewHeight (kIsiPhoneX ? 88 : 64)
#define kStatusHeight (kIsiPhoneX ? 44 : 20)

#define kColorWithHex(hexValue) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#import "ViewController.h"
#import "ONPagedFlowView.h"

@interface ViewController () <ONPagedFlowViewDelegate,ONPagedFlowViewDataSource>

/**
 *  图片数组
 */
@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	UIView *nav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, K_Width, kTitleViewHeight)];
	nav.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:nav];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, kStatusHeight, K_Width,  kTitleViewHeight - kStatusHeight)];
	label.textAlignment = NSTextAlignmentCenter;
	label.text = @"ONPagedFlowView";
	label.textColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize:17];
	[nav addSubview:label];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	for (int index = 0; index < 3; index++) {
		UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"integral%02d",index]];
		[self.imageArray addObject:image];
	}
	[self setupUI];
}

- (void)setupUI {
	ONPagedFlowView *pageFlowView = [[ONPagedFlowView alloc] initWithFrame:CGRectMake(0, kTitleViewHeight, K_Width,  K_Width / 375 * 154)];
	pageFlowView.delegate = self;
	pageFlowView.dataSource = self;
	pageFlowView.minimumPageAlpha = 0.1;
	[pageFlowView reloadData];
	[self.view addSubview:pageFlowView];
}

#pragma mark - ONPagedFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(ONPagedFlowView *)flowView {
	CGFloat viewWidth = K_Width / 375 * 280;
	CGFloat viewHeight = viewWidth * 130 / 280;
	return CGSizeMake(viewWidth, viewHeight);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
	NSLog(@"点击了第%ld张图",(long)subIndex + 1);
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(ONPagedFlowView *)flowView {
	NSLog(@"ViewController 滚动到了第%ld页",(long)pageNumber);
}

#pragma mark - ONPagedFlowViewDataSource
- (NSInteger)numberOfPagesInFlowView:(ONPagedFlowView *)flowView {
	return self.imageArray.count;
}

- (ONImageSubview *)flowView:(ONPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index {
	ONImageSubview *bannerView = [flowView dequeueReusableCell];
	if (!bannerView) {
		bannerView = [[ONImageSubview alloc] init];
		bannerView.tag = index;
	}
	//在这里下载网络图片
	// [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:hostUrlsImg,imageDict[@"img"]]] placeholderImage:[UIImage imageNamed:@""]];
	bannerView.mainImageView.image = self.imageArray[index];
	
	return bannerView;
}

#pragma mark -
- (NSMutableArray *)imageArray {
	if (_imageArray == nil) {
		_imageArray = [NSMutableArray array];
	}
	return _imageArray;
}

@end
