//
//  ViewController.m
//  MovieStudyDemo
//
//  Created by qiager on 2017/10/11.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "ViewController.h"
//UIKit
#import <MobileCoreServices/MobileCoreServices.h>
//AVCaptureSession
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    AVCaptureSession *_captureSession;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

//UIKit
- (void)captureMovieByImagePicker{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;//相机
        picker.mediaTypes = @[(NSString*)kUTTypeMovie];//默认只有拍照界面kUTTypeImage
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;//前后摄像头
        }
        
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        picker.showsCameraControls = NO;
        UIView *cameraOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, picker.view.frame.size.height-100, picker.view.frame.size.width, 100)];
        cameraOverlay.backgroundColor = [UIColor redColor];
        picker.cameraOverlayView = cameraOverlay;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(25, 25, 50, 50)];
        button.backgroundColor = [UIColor blueColor];
        [button addTarget:picker action:@selector(startVideoCapture) forControlEvents:UIControlEventTouchUpInside];
        [cameraOverlay addSubview:button];
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(cameraOverlay.frame.size.width - 75, 25, 50, 50)];
        button1.backgroundColor = [UIColor blueColor];
        [button1 addTarget:picker action:@selector(stopVideoCapture) forControlEvents:UIControlEventTouchUpInside];
        [cameraOverlay addSubview:button1];
        
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
}

//AVFoundation 中的AVCaptureSession
- (void)captureMovieByAVFoundation{
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
    
    //video input
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice
                                                                              error:nil];
    //audio input
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    
    //file output
    AVCaptureMovieFileOutput *fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([_captureSession canAddInput:videoInput]) {
        [_captureSession addInput:videoInput];
    }
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
    }
    if ([_captureSession canAddOutput:fileOutput]) {
        [_captureSession addOutput:fileOutput];
    }
    
    //设置帧速率
    NSError *error;
    CMTime frameDuration = CMTimeMake(1, 60);
    BOOL frameRateSupport = NO;
    NSArray *supportFrameRanges = [videoDevice.activeFormat videoSupportedFrameRateRanges];
    for (AVFrameRateRange *range in supportFrameRanges) {
        
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration)
            && CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupport = YES;
        }
    }
    
    if (supportFrameRanges && [videoDevice lockForConfiguration:&error]) {
        [videoDevice setActiveVideoMinFrameDuration:frameDuration];
        [videoDevice setActiveVideoMaxFrameDuration:frameDuration];
        [videoDevice unlockForConfiguration];
    }
    
    //视频防抖
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
