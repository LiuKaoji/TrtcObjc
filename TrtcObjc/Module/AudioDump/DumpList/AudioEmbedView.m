//
//  AudioEmbedView.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/14.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "AudioEmbedView.h"
#import "AudioDumpConfig.h"
#import "PCMUtils.h"
#import "DumpFileModel.h"

static NSString *DumpCellID = @"DumpCellID";

@interface AudioEmbedView ()<UITableViewDelegate,UITableViewDataSource>

/// UI
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *seekSlider;
/// 播放
@property (nonatomic, strong) NSMutableArray *dumpFiles;
@property (nonatomic, assign) NSInteger playIndex;
@property (nonatomic, assign) int32_t playId;
@property (nonatomic, assign) BOOL isDragingSlider;
@property (nonatomic, assign) double durationMs;

@end

@implementation AudioEmbedView

- (void)awakeFromNib{
    [super awakeFromNib];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    
    _playIndex = -1;
    [self readDumpFiles];
}

-(void)readDumpFiles{
    
    _dumpFiles = [NSMutableArray array];
    
    NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:D_RootFolder error:nil];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.pathExtension isEqualToString:@"pcm"]) {
            DumpFileModel *model = [DumpFileModel modelWithPath:D_RootFolder Name:obj];
            [_dumpFiles addObject:model];
        }
    }];
    
    [_dumpFiles sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    [self.listTableView reloadData];
}

#pragma mark -Xib
- (IBAction)onClickBack:(id)sender {
    
    if(self.hideHandle){
        self.hideHandle();
    }
    [self removeFromSuperview];
}

- (IBAction)onClickTrash:(id)sender {
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:D_RootFolder error:NULL];
    
    [contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSFileManager defaultManager] removeItemAtPath:[D_RootFolder stringByAppendingPathComponent:obj] error:nil];
    }];
    [self readDumpFiles];
}

- (IBAction)siderTouchCancel:(id)sender {
    
    self.isDragingSlider = NO;
}

- (IBAction)sliderTouchUpOutSide:(id)sender {
    
    self.isDragingSlider = NO;
}

- (IBAction)sliderTouchDown:(id)sender {
   
    self.isDragingSlider = YES;
}

- (IBAction)sliderValueChange:(id)sender {
    
    double pos = self.seekSlider.value * _durationMs;
    self.currentLabel.text = formatTimeInterval(pos/1000);
}

- (IBAction)sliderTouchUpInside:(id)sender {
    
    double pos = self.seekSlider.value * _durationMs;
    [[[TRTCCloud sharedInstance] getAudioEffectManager] seekMusicToPosInMS:_playId pts:pos];
    self.isDragingSlider = NO;
}


#pragma mark - TableViewDelegate&DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dumpFiles.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DumpCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DumpCellID];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    cell.textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    cell.detailTextLabel.textColor = [UIColor lightTextColor];
    
    DumpFileModel *model = _dumpFiles[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.size;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    _playIndex = indexPath.row;
    
    /// 停止播放
    [[[TRTCCloud sharedInstance] getAudioEffectManager] stopPlayMusic:_playId];
    
    ///转换pcm2wav
    DumpFileModel *model = _dumpFiles[indexPath.row];
    NSString *pcmPath = model.path;
    NSString *wavPath = [pcmPath stringByAppendingString:@".wav"];
    [PCMUtils pcm2Wav:pcmPath wavPath:wavPath];
    
    ///播放音频
    _playId = arc4random() % (1000 - 300000 + 1) + 300000;
    TXAudioMusicParam *param = [[TXAudioMusicParam alloc] init];
    param.path = wavPath;
    param.ID   = _playId;///1000~300000随机数
    __weak __typeof__(self) weakSelf = self;
    [[[TRTCCloud sharedInstance] getAudioEffectManager] startPlayMusic:param onStart:^(NSInteger errCode) {
        //__strong __typeof(self) strongSelf = weakSelf;
        if (errCode < 0) {
            NSLog(@"[AudioEmbedView] - 播放Wav预览失败");
        }
        
    } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
        __strong __typeof(self) strongSelf = weakSelf;
        
        if (!strongSelf.isDragingSlider) {
            strongSelf.currentLabel.text = formatTimeInterval(progressMs/1000);
            strongSelf.seekSlider.value = (double)progressMs/(double)durationMs;
        }
        strongSelf.durationLabel.text = formatTimeInterval(durationMs/1000);
        strongSelf.durationMs = durationMs;
        
    } onComplete:^(NSInteger errCode) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.currentLabel.text = @"00:00";
        strongSelf.seekSlider.value = 0;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

+(void)show:(dispatch_block_t)hideHandle{
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;

    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"AudioEmbedView" owner:nil options:nil];
    AudioEmbedView *embedView = [nibContents lastObject];
    embedView.hideHandle = hideHandle;
    [keyWindow addSubview:embedView];
    
}
@end
