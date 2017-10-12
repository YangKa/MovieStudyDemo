//
//  ImagePickerController.m
//  MovieStudyDemo
//
//  Created by qiager on 2017/10/12.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "ImagePickerController.h"

//UIKit
#import <MobileCoreServices/MobileCoreServices.h>


@interface ImagePickerController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIVideoEditorControllerDelegate>{
    UIImagePickerController *picker;
}

@end

@implementation ImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self captureMovieByImagePicker];
    
}

//UIKit
- (void)captureMovieByImagePicker{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        
        picker = [[UIImagePickerController alloc] init];
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;//相机
        picker.mediaTypes = @[(NSString*)kUTTypeImage, (NSString*)kUTTypeLivePhoto];
        //picker.mediaTypes = @[(NSString*)kUTTypeMovie];//默认只有拍照界面kUTTypeImage
        //        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
        //            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;//前后摄像头
        //        }
        
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        
        //自定义overlay
       // [self addCameraOverlayView];
        
        
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

- (void)addCameraOverlayView{
    picker.showsCameraControls = NO;//YES 拍完照后需要在代理方法里dismiss picker。自定义可以mutilate capture
    
    UIView *cameraOverlay = [[UIView alloc] initWithFrame:picker.view.bounds];
    cameraOverlay.backgroundColor = [UIColor clearColor];
    picker.cameraOverlayView = cameraOverlay;
    
    UIButton *flashButton = [[UIButton alloc] initWithFrame:CGRectMake(cameraOverlay.frame.size.width - 125, 25, 50, 50)];
    flashButton.backgroundColor = [UIColor lightGrayColor];
    [flashButton setTitle:@"闪光" forState:UIControlStateNormal];
    [flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flashButton addTarget:self action:@selector(adjustFlashMode) forControlEvents:UIControlEventTouchUpInside];
    [cameraOverlay addSubview:flashButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(cameraOverlay.frame.size.width - 75, 25, 50, 50)];
    cancelButton.backgroundColor = [UIColor blueColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [cameraOverlay addSubview:cancelButton];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, cameraOverlay.frame.size.height- 100, cameraOverlay.frame.size.width, 100)];
    bottomView.backgroundColor = [UIColor clearColor];
    [cameraOverlay addSubview:bottomView];
    
    UIButton *beginButton = [[UIButton alloc] initWithFrame:CGRectMake(25, 25, 100, 50)];
    beginButton.backgroundColor = [UIColor blueColor];
    [beginButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [beginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [beginButton addTarget:picker action:@selector(startVideoCapture) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:beginButton];
    
    UIButton *captureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    captureButton.center = CGPointMake(bottomView.frame.size.width/2, bottomView.frame.size.height/2);
    captureButton.backgroundColor = [UIColor redColor];
    captureButton.layer.cornerRadius = captureButton.frame.size.width/2;
    captureButton.layer.masksToBounds = YES;
    [captureButton addTarget:picker action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:captureButton];
    
    UIButton *endButton = [[UIButton alloc] initWithFrame:CGRectMake(cameraOverlay.frame.size.width - 125, 25, 100, 50)];
    endButton.backgroundColor = [UIColor blueColor];
    [endButton setTitle:@"结束录制" forState:UIControlStateNormal];
    [endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [endButton addTarget:picker action:@selector(stopVideoCapture) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:endButton];
}

#pragma mark
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismiss];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@", info);
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        NSLog(@"image=%@", info[UIImagePickerControllerOriginalImage]);
    }
    
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        NSURL *pathURL = info[UIImagePickerControllerMediaURL];
        NSLog(@"movie Path=%@", info[UIImagePickerControllerMediaURL]);
        [self openVideoEditControllerWithPath:pathURL.path];
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor{
    
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error{
    
}

- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath{
    [self dismiss];
}
#pragma mark
#pragma mark moive edit
- (void)openVideoEditControllerWithPath:(NSString*)moivePath{
    if ([UIVideoEditorController canEditVideoAtPath:moivePath]) {
        UIVideoEditorController *vedioEditController = [[UIVideoEditorController alloc] init];
        vedioEditController.videoPath = moivePath;
        vedioEditController.delegate = self;
        [picker presentViewController:vedioEditController animated:YES completion:nil];
        
    }
}

#pragma mark
#pragma mark Working with Live Photos

#pragma mark
#pragma mark
- (void)dismiss{
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

//调整闪光模式
- (void)adjustFlashMode{
    //UIImagePickerControllerCameraFlashModeOn、
    //UIImagePickerControllerCameraFlashModeOff、
    //UIImagePickerControllerCameraFlashModeAuto
    picker.cameraFlashMode = picker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn? UIImagePickerControllerCameraFlashModeOff:UIImagePickerControllerCameraFlashModeOn;
}


@end
