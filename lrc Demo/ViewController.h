//
//  ViewController.h
//  lrc Demo
//
//  Created by txx on 12-7-17.
//  Copyright (c) 2012年 txx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>
{
    UITableView*            _tableView;
    NSArray*                _tableViewdataSource;
//    
//    float                   rColor;
//    float                   gColor;
//    float                   bColor;
    CGPoint                 _tableViewOffset;
    CGFloat                 _delta;
    NSTimer*                _timer;
    NSInteger               _timerCnt;
    NSInteger               _lrcStart;
    NSInteger               _nowHighlight;
    AVAudioPlayer*          _player;
}


@end
