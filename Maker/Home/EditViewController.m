//
//  EditViewController.m
//  Maker
//
//  Created by David on 2019/1/8.
//  Copyright © 2019 David. All rights reserved.
//

#import "EditViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface EditViewController ()<CTAssetsPickerControllerDelegate>

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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


- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    // assets contains PHAsset objects.
    
    //选中的图片
    NSMutableArray *orignalImages = [assets mutableCopy];
    
    //对图片进行裁剪，方便合成等比例视频
    for (int i = 0; i < orignalImages.count; i++) {
        
        PHAsset *asset = orignalImages[i];
        
        __weak typeof(self) weakSelf = self;
        
    }
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
