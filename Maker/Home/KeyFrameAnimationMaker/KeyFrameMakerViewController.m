//
//  KeyFrameMakerViewController.m
//  Maker
//
//  Created by David on 2018/12/7.
//  Copyright © 2018 David. All rights reserved.
//

#import "KeyFrameMakerViewController.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import <CTAssetsPickerController/CTAssetsPickerController.h>

#import "DMSubmitView.h"

#import <AssetsLibrary/AssetsLibrary.h>


#define WWScreamW [UIScreen mainScreen].bounds.size.width
#define WWScreamH [UIScreen mainScreen].bounds.size.height

#define vedioSize CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)
//CGSizeMake(320, 480)

@interface KeyFrameMakerViewController () <CTAssetsPickerControllerDelegate>

//视频地址
@property(nonatomic,strong)NSString*theVideoPath;

@property (nonatomic, strong) NSMutableArray *selectedImageSource;

@property (nonatomic, strong) UIButton *selectedImageButton;
@property (nonatomic, strong) UIButton *vedioMakerButton;
@property (nonatomic, strong) UIButton *showVedioButton;

@property (nonatomic, strong) DMSubmitView *subview;

@end

@implementation KeyFrameMakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    UIButton *rightButton =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightButton setTitle:@"保存视频" forState:UIControlStateNormal];
    rightButton.titleLabel.textAlignment = NSTextAlignmentRight;
//    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    rightButton.titleLabel.font = [UIFont systemFontOfSize:12];
    rightButton.frame = CGRectMake(0, 0, 100, 50);
    [rightButton addTarget:self action:@selector(saveVedioAction) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:rightButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
    
    [self setupView];
    
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            picker.showsEmptyAlbums = YES;
            
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
    
    [self newSubmitView];
}

//保存视频
- (void)saveVedioAction {
    NSLog(@"************%@",self.theVideoPath);
    
    // 文件管理器
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    
    if (![fileManager fileExistsAtPath:self.theVideoPath]) {
        [DMHud showText:@"文件不存在"];
        return;
    }
    
    [self saveVideo:self.theVideoPath];
    
    
}

//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    
    if (videoPath) {
        NSURL *url = [NSURL URLWithString:videoPath];
        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
        if (compatible)
        {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}


//保存视频完成之后的回调
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
        [DMHud showText:[NSString stringWithFormat:@"保存视频失败%@", error.localizedDescription]];
//        [self hideHUD];
//        [self showHintMiddle:@"视频保存失败"];
    }
    else {
        NSLog(@"保存视频成功");
        [DMHud showText:@"保存视频成功"];
//        [self hideHUD];
//        [self showHintMiddle:@"视频保存成功"];
    }
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    // assets contains PHAsset objects.
    
    [self.selectedImageSource removeAllObjects];
    
    //选中的图片
    NSMutableArray *orignalImages = [assets mutableCopy];
    
    //对图片进行裁剪，方便合成等比例视频
    for (int i = 0; i < orignalImages.count; i++) {
        
        PHAsset *asset = orignalImages[i];
        
        __weak typeof(self) weakSelf = self;
        
        [self fetchImageWithAsset:asset imageBlock:^(NSData *imageData) {
            UIImage *imageNew = [UIImage imageWithData:imageData];

            CGSize targetSize = CGSizeZero;
//            if (imageNew.size.width > imageNew.size.height) {
//
//            }
            
            //对图片大小进行压缩--
            imageNew = [weakSelf imageWithImage:imageNew scaledToSize:vedioSize];
//            imageNew = [weakSelf imageCompressWithSimple:imageNew];
        
            [weakSelf.selectedImageSource addObject:imageNew];
        }];
    }
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)fetchImageWithAsset:(PHAsset*)mAsset imageBlock:(void(^)(NSData*))imageBlock {
    
    [[PHImageManager defaultManager] requestImageDataForAsset:mAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        if (orientation != UIImageOrientationUp) {
            UIImage* image = [UIImage imageWithData:imageData];
            // 尽然弯了,那就板正一下
            image = [self fixOrientation:image];
            // 新的 数据信息 （不准确的）
            imageData = UIImageJPEGRepresentation(image, 1.0);
        }
        
        // 直接得到最终的 NSData 数据
        if (imageBlock) {
            imageBlock(imageData);
        }
        
    }];
}

/** 解决旋转90度问题 */
- (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (void)selectedImageButtonDidClick {
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            picker.showsEmptyAlbums = YES;
            
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (void)setupView {
    
    self.selectedImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.selectedImageButton setTitle:@"选择照片" forState:UIControlStateNormal];
//    [self.selectedImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.selectedImageButton addTarget:self action:@selector(selectedImageButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectedImageButton];
    [self.selectedImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@100);
    }];
    
//    self.vedioMakerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [self.vedioMakerButton setTitle:@"生成视频"forState:UIControlStateNormal];
//    [self.vedioMakerButton addTarget:self action:@selector(productVedioAction)forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.vedioMakerButton];
//    [self.vedioMakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.selectedImageButton.mas_bottom).offset(30);
//    }];
    
    self.showVedioButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.showVedioButton setTitle:@"展示视频"forState:UIControlStateNormal];
    [self.showVedioButton addTarget:self action:@selector(playAction)forControlEvents:UIControlEventTouchUpInside];
//    button1.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.showVedioButton];
    [self.showVedioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.selectedImageButton.mas_bottom).offset(30);
    }];
}

//提交按钮
- (void)newSubmitView {
    self.subview = [[DMSubmitView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    self.subview.delegate = self;
    self.subview.center = CGPointMake(self.view.center.x, 250);
    [self.view addSubview:self.subview];
    
    [self.subview setupSubmitViewTitle:@"生成视频"];
}

#pragma mark -
- (void)submitViewStartShowProgressViewStatus {
    if (self.selectedImageSource.count == 0) {
        [DMHud showText:@"请先选择照片"];
        return;
    }
    
    [self productVedioAction];
}


//对图片尺寸进行压缩--
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);

    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];

    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();

    // End the context
    UIGraphicsEndImageContext();

    // Return the new image.
    return newImage;
}


//- (UIImage*)imageCompressWithSimple:(UIImage*)image{
//    CGSize size = image.size;
//    CGFloat scale = 1.0;
//    //TODO:KScreenWidth屏幕宽
//
//    CGFloat KScreenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat KScreenHeight = [UIScreen mainScreen].bounds.size.height;
//
//    if (size.width > KScreenWidth || size.height > KScreenHeight) {
//        if (size.width > size.height) {
//            scale = KScreenWidth / size.width;
//        }else {
//            scale = KScreenHeight / size.height;
//        }
//    }
//    CGFloat width = size.width;
//    CGFloat height = size.height;
//    CGFloat scaledWidth = width * scale;
//    CGFloat scaledHeight = height * scale;
//    CGSize secSize =CGSizeMake(scaledWidth, scaledHeight);
//    //TODO:设置新图片的宽高
//    UIGraphicsBeginImageContext(secSize); // this will crop
//    [image drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
//    UIImage* newImage= UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}


#pragma mark- 生成视频

//视频合成按钮点击操作
- (void)productVedioAction {
    
    //设置mov路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString *moviePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"maker"]];
    
    self.theVideoPath = moviePath;
    
    NSError *error = nil;
    
    //    转成UTF-8编码
    unlink([moviePath UTF8String]);
    
    NSLog(@"path->%@",moviePath);
    
    //     iphone提供了AVFoundation库来方便的操作多媒体设备，AVAssetWriter这个类可以方便的将图像和音频写成一个完整的视频文件
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSParameterAssert(videoWriter);
    
    if(error) {
        NSLog(@"error =%@",[error localizedDescription]);
        return;
    }
    
    //mov的格式设置 编码格式 宽度 高度
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   
                                   [NSNumber numberWithInt:vedioSize.width],AVVideoWidthKey,
                                   
                                   [NSNumber numberWithInt:vedioSize.height],AVVideoHeightKey, nil];
    
    
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    //    AVAssetWriterInputPixelBufferAdaptor提供CVPixelBufferPool实例,
    //    可以使用分配像素缓冲区写入输出文件。使用提供的像素为缓冲池分配通常
    //    是更有效的比添加像素缓冲区分配使用一个单独的池
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if([videoWriter canAddInput:writerInput]){
        
        NSLog(@"11111");
        
    }else{
        
        NSLog(@"22222");
        
    }
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue",NULL);
    
    int __block frame = 0;
    
    __weak typeof(self) weakSelf = self;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        
        while([writerInput isReadyForMoreMediaData]) {
            
            if(frame++ >= [weakSelf.selectedImageSource count] * 10) {
                [writerInput markAsFinished];
                
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"完成");
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
//                        [DMHud showText:@"视频合成完毕"];
                        
                    }];
                    
                }];
                break;
            }
            
            CVPixelBufferRef buffer = NULL;
            
            float idx = frame / 10.0;
            
            NSLog(@"idx==%f",idx);
            NSString *progress = [NSString stringWithFormat:@"%0.2f",idx / [weakSelf.selectedImageSource count]];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
//                [DMHud showText:[NSString stringWithFormat:@"合成进度:%@",progress]];
                NSLog(@"%@", [NSString stringWithFormat:@"合成进度:%@",progress]);
                
                //更新
                [weakSelf.subview updateProgressViewWitCurrenthData:idx totalData:weakSelf.selectedImageSource.count];
                
            }];
            
            if (idx >= weakSelf.selectedImageSource.count) {
                return ;
            }
            
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[weakSelf.selectedImageSource objectAtIndex:idx]CGImage]size:vedioSize];
            
            if(buffer){
                
                //设置每秒钟播放图片的个数
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,10)]) {
                    
                    NSLog(@"FAIL");
                    
                } else {
                    
                    NSLog(@"OK");
                }
                
                CFRelease(buffer);
            }
        }
    }];
    
    
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                             
                             [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata !=NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    
    //    当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    
    if (context == nil) {
        return nil;
    }
    
    NSParameterAssert(context);
    
    //使用CGContextDrawImage绘制图片  这里设置不正确的话 会导致视频颠倒
    
    //    当通过CGContextDrawImage绘制图片到一个context中时，如果传入的是UIImage的CGImageRef，因为UIKit和CG坐标系y轴相反，所以图片绘制将会上下颠倒
    
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    // 释放色彩空间
    
    CGColorSpaceRelease(rgbColorSpace);
    
    // 释放context
    
    CGContextRelease(context);
    
    // 解锁pixel buffer
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}

//视频播放按钮点击操作
- (void)playAction {
    
    NSLog(@"************%@",self.theVideoPath);
    
    // 文件管理器
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    
    if (![fileManager fileExistsAtPath:self.theVideoPath]) {
        [DMHud showText:@"文件不存在"];
        return;
    }
    
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:self.theVideoPath];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    playerLayer.frame = CGRectMake(0, WWScreamH /2 , WWScreamW, WWScreamH/2);
    
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.view.layer addSublayer:playerLayer];
    
    [player play];
    
}


- (NSMutableArray *)selectedImageSource {
    if (!_selectedImageSource) {
        _selectedImageSource = [[NSMutableArray alloc] init];
    }
    return _selectedImageSource;
}

@end
