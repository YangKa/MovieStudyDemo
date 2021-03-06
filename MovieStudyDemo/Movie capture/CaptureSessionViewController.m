//
//  CaptureSessionViewController.m
//  MovieStudyDemo
//
//  Created by qiager on 2017/10/12.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "CaptureSessionViewController.h"

//AVCaptureSession
#import <AVFoundation/AVFoundation.h>

@interface CaptureSessionViewController ()<AVCaptureFileOutputRecordingDelegate>{
    AVCaptureSession *_captureSession;
    
    AVCaptureMovieFileOutput *_fileOutput;
    
}

@end

@implementation CaptureSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    _fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    _fileOutput.de
    
    if ([_captureSession canAddInput:videoInput]) {
        [_captureSession addInput:videoInput];
    }
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
    }
    if ([_captureSession canAddOutput:_fileOutput]) {
        [_captureSession addOutput:_fileOutput];
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
}

- (void)addPreviewLayer{
    
}

- (void)startRecording{
    //开始录制
    if (_fileOutput.isRecording) {
        [_fileOutput resumeRecording];
    }else{
       [_fileOutput startRecordingToOutputFileURL:nil recordingDelegate:self];
    }
    
}

- (void)stopRecording{
    [_fileOutput stopRecording];
}

- (void)pauseRecording{
    [_fileOutput pauseRecording];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    
}

@end
