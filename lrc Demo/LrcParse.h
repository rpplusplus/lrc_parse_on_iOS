//
//  LrcParse.h
//  lrc Demo
//
//  Created by txx on 12-7-17.
//  Copyright (c) 2012年 txx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lyric : NSObject
{
    float                   _time;
    NSString*               _lyricString;
}

@property (nonatomic)               float           time;
@property (nonatomic, retain)       NSString*       lyricString;

@end

enum _kProperty
{
    kArtist,
    kTitle,
    kAlbum,
    kBy
};


typedef enum _kProperty  kProperty;

@interface lyricProperty : NSObject
{
    kProperty               _property;
    NSString*               _detail;
}

@property (nonatomic)           kProperty           property;
@property (nonatomic, retain)   NSString*           detail;
@end



@interface LrcParse : NSObject

+ (NSArray*) parseFromFile:(NSString*) path;

@end
