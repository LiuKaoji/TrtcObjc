//
//  MainTableVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/20.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "MainTableVC.h"
#import "MainModel.h"
#import "TRTCBaseVC.h"

@interface MainTableVC ()
@property (nonatomic,strong)NSArray *exampleModels;
@end

@implementation MainTableVC

+(instancetype)exampleInit{
    return [[self alloc] init];
}

-(NSArray *)exampleModels{
    if(!_exampleModels){
        _exampleModels = @[[MainModel model:@"相册视频" Detail:@"AVAssetReader" className:@"SendVideoVC"],
                           [MainModel model:@"原生采集" Detail:@"AVCapture" className:@"AVCaptureVC"],
                           [MainModel model:@"开源采集" Detail:@"GPUImage" className:@"GPUImageVC"],
                           [MainModel model:@"渲染回调" Detail:@"LocalVideoRender"  className:@"RenderVC"],
                           [MainModel model:@"美颜回调" Detail:@"LocalVideoProcess" className:@"ProcessVC"],
                           [MainModel model:@"音频转储" Detail:@"AudioFrameDelegate" className:@"AudioDumpVC"]];
    }
    return _exampleModels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TRTC实时音视频";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exampleModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SystemCell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SystemCell"];
    }
    MainModel *model = self.exampleModels[indexPath.row];
    cell.textLabel.text = model.item;
    cell.detailTextLabel.text = model.detail;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转控制器
    MainModel *model = self.exampleModels[indexPath.row];
    Class kClass = NSClassFromString(model.className);
    TRTCBaseVC *vc = [[kClass alloc] init];
    [vc setDemoTitle:[NSString stringWithFormat:@"%@ - %d", model.item, ROOM_ID]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

@end
