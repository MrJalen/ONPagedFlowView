# ONPagedFlowView

项目中涉及到多种会员积分
需做一个类似于淘票票的卡片滑动

# 效果图
![image](https://github.com/MrJalen/ONPagedFlowView/raw/master/ONPagedFlowView/ONPagedFlowView/pagedFlow.mov)

# 使用
</br>
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourcetype {</br>
	ONImagePickerController *imagePicker = [ONImagePickerController sharedInstance];</br>
	[imagePicker showImagePickerWithPresentController:self sourceType:sourcetype allowEdit:YES cutFrame:CGRectMake(0, (kScreenHeight - kScreenWidth/1.6)/2, kScreenWidth, kScreenWidth/1.6)];</br>
	[imagePicker setChooseImageBlock:^(UIImage * _Nonnull image) {</br>
		NSLog(@"--image--%@",image);</br>
		self.imageView.image = image;</br>
	}];
}
</br>
- (void)setupUI {</br>
	ONPagedFlowView *pageFlowView = [[ONPagedFlowView alloc] initWithFrame:CGRectMake(0, kTitleViewHeight, K_Width,  K_Width / 375 * 154)];</br>
	pageFlowView.delegate = self;</br>
	pageFlowView.dataSource = self;</br>
	pageFlowView.minimumPageAlpha = 0.1;</br>
	[pageFlowView reloadData];</br>
	[self.view addSubview:pageFlowView];</br>
}

# 使用 Delegate
</br>
ONPagedFlowViewDelegate</br>
- (CGSize)sizeForPageInFlowView:(ONPagedFlowView *)flowView {</br>
	CGFloat viewWidth = K_Width / 375 * 280;</br>
	CGFloat viewHeight = viewWidth * 130 / 280;</br>
	return CGSizeMake(viewWidth, viewHeight);</br>
}</br>

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {</br>
	NSLog(@"点击了第%ld张图",(long)subIndex + 1);</br>
}</br>

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(ONPagedFlowView *)flowView {</br>
	NSLog(@"ViewController 滚动到了第%ld页",(long)pageNumber);</br>
}</br>

ONPagedFlowViewDataSource</br>
- (NSInteger)numberOfPagesInFlowView:(ONPagedFlowView *)flowView {</br>
	return self.imageArray.count;</br>
}</br>

主图处理</br>
- (ONImageSubview *)flowView:(ONPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index {</br>
	ONImageSubview *bannerView = [flowView dequeueReusableCell];</br>
	if (!bannerView) {</br>
		bannerView = [[ONImageSubview alloc] init];</br>
		bannerView.tag = index;</br>
	}</br>
	//在这里下载网络图片</br>
	// [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:hostUrlsImg,imageDict[@"img"]]] placeholderImage:[UIImage imageNamed:@""]];</br>
	bannerView.mainImageView.image = self.imageArray[index];</br>
	
	return bannerView;</br>
}
