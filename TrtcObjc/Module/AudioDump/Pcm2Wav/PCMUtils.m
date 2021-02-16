//
//  PCMUtils.m
//  TrtcObjc
//
//  Created by kaoji on 2021/2/15.
//  Copyright © 2021 issuser. All rights reserved.
//  ////源码访问https://github.com/yangsheng1107/pcm2wav/blob/master/src/wav.c

#import "PCMUtils.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#import "AudioDumpConfig.h"

#if 1
#define swap_u16
#define swap_16
#define swap_u32
#define swap_32
#define swap_u64
#define swap_64
#else
#define swap_u16 swap_uint16
#define swap_16 swap_int16
#define swap_u32 swap_uint32
#define swap_32 swap_int32
#define swap_u64 swap_uint64
#define swap_64 swap_int64
#endif

@implementation PCMUtils

////////////// Endian swaping functions //////////

//! Byte swap unsigned short
uint16_t swap_uint16( uint16_t val )
{
    return (val << 8) | (val >> 8 );
}

//! Byte swap short
int16_t swap_int16( int16_t val )
{
    return (val << 8) | ((val >> 8) & 0xFF);
}

//! Byte swap unsigned int
uint32_t swap_uint32( uint32_t val )
{
    val = ((val << 8) & 0xFF00FF00 ) | ((val >> 8) & 0xFF00FF );
    return (val << 16) | (val >> 16);
}

//! Byte swap int
int32_t swap_int32( int32_t val )
{
    val = ((val << 8) & 0xFF00FF00) | ((val >> 8) & 0xFF00FF );
    return (val << 16) | ((val >> 16) & 0xFFFF);
}

//! Byte swap int64
int64_t swap_int64( int64_t val )
{
    val = ((val << 8) & 0xFF00FF00FF00FF00ULL ) | ((val >> 8) & 0x00FF00FF00FF00FFULL );
    val = ((val << 16) & 0xFFFF0000FFFF0000ULL ) | ((val >> 16) & 0x0000FFFF0000FFFFULL );
    return (val << 32) | ((val >> 32) & 0xFFFFFFFFULL);
}

//! Byte swap uint64
uint64_t swap_uint64( uint64_t val )
{
    val = ((val << 8) & 0xFF00FF00FF00FF00ULL ) | ((val >> 8) & 0x00FF00FF00FF00FFULL );
    val = ((val << 16) & 0xFFFF0000FFFF0000ULL ) | ((val >> 16) & 0x0000FFFF0000FFFFULL );
    return (val << 32) | (val >> 32);
}

////////////// Endian swaping wrapper functions //////////
void fwrite64(int64_t value, FILE *f)
{
    int64_t item = swap_64(value);
    fwrite(&item, sizeof(int64_t),1,f);
}

void fwriteU64(uint64_t value, FILE *f)
{
    uint64_t item = swap_u64(value);
    fwrite(&item, sizeof(uint64_t),1,f);
}
 

void fwrite32(int32_t value, FILE *f)
{
    int32_t item = swap_32(value);
    fwrite(&item, sizeof(int32_t),1,f);
}

void fwriteU32(uint32_t value, FILE *f)
{
    uint32_t item = swap_u32(value);
    fwrite(&item, sizeof(uint32_t),1,f);
}
 
void fwrite16(int16_t value, FILE *f)
{
    int16_t item = swap_16(value);
    fwrite(&item, sizeof(int16_t),1,f);
}

void fwriteU16(uint16_t value, FILE *f)
{
    uint16_t item = swap_u16(value);
    fwrite(&item, sizeof(uint16_t),1,f);
}

void fwrite8(int8_t *value, FILE *f)
{
    fwrite(value, sizeof(int8_t), strlen(value),f);
}

void fwriteU8(uint8_t *value, FILE *f)
{
    fwrite(value, sizeof(uint8_t), strlen(value),f);
}

////////////// file write sample functions //////////
int pcm2wav(char* in,char* out,short NumChannels, short BitsPerSample,int SamplingRate)
{
    FILE *fin,*fout;
    char buffer[1028];
    int ByteRate = NumChannels*BitsPerSample*SamplingRate/8;
    short BlockAlign = NumChannels*BitsPerSample/8;
    int chunkSize = 16;
    short audioFormat = 1;
    int DataSize;
    int totalSize;
    int n;

    //get total length
    if((fin = fopen(in,"rb")) == NULL)
    {
        printf("Error opening %s file error \n", in);
        return -1;
    }
    fseek ( fin , 0, SEEK_END );
    DataSize = ftell (fin);
    totalSize = 36 + DataSize;

    if((fout = fopen(out, "wb")) == NULL)
    {
        printf("Error opening %s file error \n", out);
        return -1;
    }

    //totOutSample = 0;
    fwrite8("RIFF", fout);
    fwrite32(totalSize, fout);
    fwrite8("WAVE", fout);
    fwrite8("fmt ", fout);
    fwrite32(chunkSize, fout);
    fwrite16(audioFormat, fout);
    fwrite16(NumChannels, fout);
    fwrite32(SamplingRate, fout);
    fwrite32(ByteRate, fout);
    fwrite16(BlockAlign, fout);
    fwrite16(BitsPerSample, fout);
    fwrite8("data", fout);
    fwrite32(DataSize, fout);

    //ready to flush pcm data
    fflush(fout);
    fseek ( fin , 0, SEEK_SET );

    while((n = fread(buffer, 1, sizeof(buffer), fin)) > 0) {
        if(n != fwrite(buffer, 1, n, fout)) {
            perror("fwrite");
        }
        fflush(fout);
    }

    fclose(fin);
    fclose(fout);

    return 0;
}

+ (void)pcm2Wav:(NSString *)pcmPath wavPath:(NSString *)wavPath;{
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
//        return;
//    }
    pcm2wav((char *)[pcmPath UTF8String],(char *)[wavPath UTF8String],D_Channels,D_BitsPerSample,D_SampleRate);
}

@end
