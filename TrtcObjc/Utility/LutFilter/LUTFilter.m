//
//  LUTFilter.m
//  TrtcOjc
//
//  Created by kaoji on 2021/1/5.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "LUTFilter.h"

#define LUTPATH  [[NSBundle mainBundle] pathForResource:@"LUT" ofType:@"bundle"]

@implementation LUTFilter
{
   @protected CIFilter *_lutFilter;
   @protected CIContext *_ciContext;
   @protected unsigned long _lutIndex;
  
   @protected NSMutableArray *_lutData;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

-(void)prepare{
    
    /// 读取LUT图
    _lutData = [NSMutableArray array];
    NSString *lutBundlePath = [[NSBundle mainBundle] pathForResource:@"LUT" ofType:@"bundle"];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:lutBundlePath error:nil];
    if(files.count == 0){
        NSAssert(files.count == 0, @"LUT图数据缺失");
    }
    [_lutData addObjectsFromArray: files];
    
    /// 初始化滤镜
    _lutFilter = [self filterWithLUT:_lutData[0] dimension:64];
    
    /// 初始化上下文
    _ciContext = [[CIContext alloc] initWithOptions:nil];

}

-(void)nextFilter{
    
    _lutIndex = _lutIndex + 1;
    _lutIndex = MIN(MAX(0, _lutIndex),_lutData.count - 1);
    
    /// 更新滤镜
    _lutFilter = [self filterWithLUT:_lutData[_lutIndex] dimension:64];
}

/// 处理buffer 数据
-(void)processTrtcFrame:(TRTCVideoFrame *)srcFrame to:(TRTCVideoFrame *)dstFrame{
    
    /// 01. buffer to CIImage
    CIImage *sourceImage = [[CIImage alloc] initWithCVPixelBuffer:srcFrame.pixelBuffer];
    
    /// 02. bind to filter
    [_lutFilter setValue:sourceImage forKey:kCIInputImageKey];
    
    /// 03. process Image
    CIImage *outputImage = _lutFilter.outputImage;
    
    /// 04. render to destination-buffer
    [_ciContext render:outputImage toCVPixelBuffer:dstFrame.pixelBuffer];
}

-(CIFilter *) filterWithLUT:(NSString *)name dimension:(NSInteger)n
{
    NSString *lutPath = [LUTPATH stringByAppendingPathComponent:name];
    UIImage *image = [UIImage imageWithContentsOfFile:lutPath];
    
    NSInteger width = CGImageGetWidth(image.CGImage);
    NSInteger height = CGImageGetHeight(image.CGImage);
    NSInteger rowNum = height / n;
    NSInteger columnNum = width / n;
    
    if ((width % n != 0) || (height % n != 0) || (rowNum * columnNum != n))
    {
        NSLog(@"Invalid colorLUT");
        return nil;
    }
    
    unsigned char *bitmap = [self createRGBABitmapFromImage:image.CGImage];
    
    if (bitmap == NULL)
    {
        return nil;
    }
    
    NSInteger size = n * n * n * sizeof(float) * 4;
    float *data = malloc(size);
    int bitmapOffest = 0;
    int z = 0;
    for (int row = 0; row <  rowNum; row++)
    {
        for (int y = 0; y < n; y++)
        {
            int tmp = z;
            for (int col = 0; col < columnNum; col++)
            {
                for (int x = 0; x < n; x++) {
                    float r = (unsigned int)bitmap[bitmapOffest];
                    float g = (unsigned int)bitmap[bitmapOffest + 1];
                    float b = (unsigned int)bitmap[bitmapOffest + 2];
                    float a = (unsigned int)bitmap[bitmapOffest + 3];
                    
                    NSInteger dataOffset = (z*n*n + y*n + x) * 4;
                    
                    data[dataOffset] = r / 255.0;
                    data[dataOffset + 1] = g / 255.0;
                    data[dataOffset + 2] = b / 255.0;
                    data[dataOffset + 3] = a / 255.0;
                    
                    bitmapOffest += 4;
                }
                z++;
            }
            z = tmp;
        }
        z += columnNum;
    }
    
    free(bitmap);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorCube"];
    [filter setValue:[NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES] forKey:@"inputCubeData"];
    [filter setValue:[NSNumber numberWithInteger:n] forKey:@"inputCubeDimension"];
    
    return filter;
}

- (unsigned char *)createRGBABitmapFromImage:(CGImageRef)image
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    unsigned char *bitmap;
    int bitmapSize;
    int bytesPerRow;
    
    size_t width   = CGImageGetWidth(image);
    size_t height  = CGImageGetHeight(image);
    
    bytesPerRow    = (width * 4);
    bitmapSize     = (bytesPerRow * height);
    
    bitmap = malloc( bitmapSize );
    if (bitmap == NULL)
    {
        return NULL;
    }
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        free(bitmap);
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmap,
                                     width,
                                     height,
                                     8,
                                     bytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease( colorSpace );
    
    if (context == NULL)
    {
        free (bitmap);
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    CGContextRelease(context);
    
    return bitmap;
}
@end
