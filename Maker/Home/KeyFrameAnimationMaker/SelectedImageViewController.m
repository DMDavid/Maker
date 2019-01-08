//
//  SelectedImageViewController.m
//  Maker
//
//  Created by Santiago on 2018/12/7.
//  Copyright © 2018 David. All rights reserved.
//

#import "SelectedImageViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface SelectedImageViewController () <CTAssetsPickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *selectedImageSource;

@end

@implementation SelectedImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    self.selectedImageSource = [assets mutableCopy];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSMutableArray *)selectedImageSource {
    if (!_selectedImageSource) {
        _selectedImageSource = [[NSMutableArray alloc] init];
    }
    return _selectedImageSource;
}

@end
