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

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate
                            ,AVCaptureFileOutputRecordingDelegate>{
    AVCaptureSession *_captureSession;
                                UIImagePickerController *picker;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
        
        picker.mediaTypes = @[(NSString*)kUTTypeMovie];//默认只有拍照界面kUTTypeImage
//        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
//            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;//前后摄像头
//        }

        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
	
        /*
        //自定义overlay
        picker.showsCameraControls = NO;//YES 拍完照后需要在代理方法里dismiss picker。自定义可以mutilate capture
        UIView *cameraOverlay = [[UIView alloc] initWithFrame:picker.view.bounds];
        cameraOverlay.backgroundColor = [UIColor clearColor];
        picker.cameraOverlayView = cameraOverlay;
        
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
        */
        
        picker.delegate = self;
        

        [self presentViewController:picker animated:YES completion:nil];
    }

}

- (void)dismiss{
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@", info);
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        NSLog(@"image=%@", info[UIImagePickerControllerOriginalImage]);
    }
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        NSLog(@"movie Path=%@", info[UIImagePickerControllerMediaURL]);
    }
}

#pragma mark
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
    //防抖不是在设备上配置的，而是在AVCaptureConnection上配置
    AVCaptureConnection *connection = [[AVCaptureConnection alloc] init];
    
    AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    if ([videoDevice.activeFormat isVideoStabilizationModeSupported:stabilizationMode]){
        [connection setPreferredVideoStabilizationMode:stabilizationMode];
    }
    
    //视频 HDR (高动态范围图像)
    videoDevice.automaticallyAdjustsVideoHDREnabled = YES;
    
    //开始录制
//    [fileOutput startRecordingToOutputFileURL:nil recordingDelegate:self];
//    [fileOutput stopRecording];
//    [fileOutput pauseRecording];
//    [fileOutput resumeRecording];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
