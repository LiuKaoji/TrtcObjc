//
//  MainTableVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/20.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "MainTableVC.h"

@interface MainTableVC ()
@property (nonatomic,strong)NSArray *exampleTitles;
@property (nonatomic,strong)NSArray *exampleSubTitles;
@property (nonatomic,strong)NSArray *exampleClass;
@end

@implementation MainTableVC

+(instancetype)exampleInit{
    return [[self alloc] init];
}

-(NSArray *)exampleTitles{
    if(!_exampleTitles){
        _exampleTitles = @[@"文件流发送",
                           @"摄像头采集",
                           @"老美颜接口",
                           @"新美颜接口"];
    }
    return _exampleTitles;
}

-(NSArray *)exampleSubTitles{
    if(!_exampleSubTitles){
        _exampleSubTitles = @[@"自定义发送",
                              @"音视频采集",
                              @"老美颜接口",
                              @"新美颜接口"];
    }
    return _exampleSubTitles;
}

-(NSArray *)exampleClass{
    if(!_exampleClass){
        _exampleClass = @[@"SendVideoVC",@"CaptureVC",@"RenderVC",@"ProcessVC"];
    }
    return _exampleClass;
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
    return self.exampleTitles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SystemCell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SystemCell"];
    }

    cell.textLabel.text = self.exampleTitles[indexPath.row];
    cell.detailTextLabel.text = self.exampleSubTitles[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转 栗子🌰 控制器
    Class kClass = NSClassFromString(self.exampleClass[indexPath.row]);
    UIViewController *vc = [[kClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

@end
