//
//  LrcParse.m
//  lrc Demo
//
//  Created by txx on 12-7-17.
//  Copyright (c) 2012年 txx. All rights reserved.
//

#import "LrcParse.h"

#include <string>
#include <iostream>
#include <vector>

using namespace std;


@implementation lyric
@synthesize time        = _time;
@synthesize lyricString = _lyricString;
- (void) dealloc
{
    [_lyricString release];
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<time: %.3f, lyric: %@>", _time, _lyricString];
}
@end


@implementation lyricProperty
@synthesize property    = _property;
@synthesize detail      = _detail;
- (void) dealloc
{
    [_detail release];
    [super dealloc];
}

- (NSString*) description
{
    if (_property == kAlbum) return [NSString stringWithFormat:@"专辑: %@", _detail];
    if (_property == kTitle) return [NSString stringWithFormat:@"曲名: %@", _detail];
    if (_property == kArtist) return [NSString stringWithFormat:@"表演者: %@", _detail];
    if (_property == kBy) return [NSString stringWithFormat:@"编辑: %@", _detail];
    return @"%&$%^^%$#^%!!";
}
@end


@interface LrcParse ()
+ (NSArray*)    parseTheLrc:(NSArray*) arr;
+ (double)      calcWeight:(id) item;
@end

@implementation LrcParse

+ (double)      calcWeight:(id) item
{
    if ([item isKindOfClass:[lyric class]])
    {
        return [(lyric*) item time];
    }
    else
    {
        kProperty property = [(lyricProperty*) item property];
        if (property == kTitle) return -4;
        if (property == kArtist) return -3;
        if (property == kTitle) return -2;
        if (property == kBy) return -1;
    }
    return 0;
}

/*
 The Lrc file must satisfy the sample format on the wiki: http://en.wikipedia.org/wiki/LRC_(file_format)
 So... If Lrc is illegal, it may be crash ...
 
 Time-Tag:
    [mm:ss.xx] where mm is minutes, ss is seconds and xx is hundredths of a second.

 ID-Tag:
    [al:Album where the song is from]
    [ar:Lyrics artist]
    [by:Creator of the LRC file]
    [offset:+/- Overall timestamp adjustment in milliseconds, + shifts time up, - shifts down]
    [ti:Lyrics (song) title]
 */


+ (NSArray*) parseTheLrc:(NSArray *)arr
{
    NSMutableArray* lrcArray = [NSMutableArray arrayWithCapacity:arr.count];

    int  offset = 0;
    
    for (NSString* str in arr) {
        if (str.length > 2)
        {
            vector <string> queue;
            
            string __tmp([str cStringUsingEncoding:NSUTF8StringEncoding]);
            
            int pos = __tmp.find(']');
            while (pos != string::npos)
            {
                string _tmp = __tmp.substr(0, pos+1);
                __tmp.erase(0, pos + 1);
                
                queue.push_back(_tmp);
                pos = __tmp.find(']');
            }
            
            for (vector<string>::iterator it = queue.begin(); it != queue.end(); it ++)
            {
                pos = (*it).find(':');
                string leftPart  = (*it).substr(1, pos-1);
                string rightPart = (*it).substr(pos+1, (*it).length()-pos-2);
                if (leftPart == "" || rightPart == "") continue;
                
                if ((*it)[1]>='0' && (*it)[1] <='9')// time - tag
                {
                    lyric* _lyric = [[lyric alloc] init];
                    int minute = atoi(leftPart.c_str());
                    double second = atof(rightPart.c_str());
                    second += minute * 60;
                    
                    _lyric.time = second;
                    _lyric.lyricString = [NSString stringWithUTF8String: __tmp.c_str()];
                    
                    [lrcArray addObject: _lyric];
                    [_lyric release];
                }
                else                                // ID - tag
                {
                    lyricProperty* _lrcProperty = [[lyricProperty alloc] init];
                    if (leftPart == "al")  _lrcProperty.property = kAlbum;
                    if (leftPart == "ar")  _lrcProperty.property = kArtist;
                    if (leftPart == "ti")  _lrcProperty.property = kTitle;
                    if (leftPart == "by")  _lrcProperty.property = kBy;
                    
                    if (leftPart == "offset")
                        offset += atoi(rightPart.c_str());  // how many offset in lrc files? God knows..
                    
                    _lrcProperty.detail = [NSString stringWithUTF8String: rightPart.c_str()];
                    [lrcArray addObject:_lrcProperty];
                    [_lrcProperty release];
                }
            }
        }
    }
    
    if (offset)
    {
        for (id item in lrcArray) {
            if ([item isKindOfClass:[lyric class]]) {
                lyric* _tmp = (lyric*) item;
                _tmp.time += offset;
            }
        }
    }
    
    [lrcArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        double a = [self calcWeight: obj1];
        double b = [self calcWeight:obj2];
            
        if (a < b) return NSOrderedAscending;
        if (a == b) return NSOrderedSame;
        else return NSOrderedDescending;
    }];
    
    return [[lrcArray retain] autorelease];
}

+(NSArray*) parseFromFile:(NSString *)path
{
    NSError* error = nil;
    NSString* str = [[NSString alloc] initWithContentsOfFile:path
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];    
    if (!str || error)
        assert(@"ERROR: The lrc file may not exist or not be utf8 encoding!");

    NSArray* arr = [str componentsSeparatedByString:@"\n"];
    [str release];
    return [self parseTheLrc:[[arr retain] autorelease]];
}

@end
