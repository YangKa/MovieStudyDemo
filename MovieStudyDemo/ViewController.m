//
//  ViewController.m
//  MovieStudyDemo
//
//  Created by qiager on 2017/10/11.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "ViewController.h"

#import "ImagePickerController.h"
#import "CaptureSessionViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSArray *_list;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _list = @[@"imagePicker", @"captureSession"];
    
    [self addTableView];
}

- (void)addTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = _list[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        ImagePickerController *vc = [ImagePickerController new];
        [self presentViewController:vc animated:YES completion:nil];
    }
    if (indexPath.row == 1) {
        CaptureSessionViewController *vc = [CaptureSessionViewController new];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
