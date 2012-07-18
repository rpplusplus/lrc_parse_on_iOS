//
//  ViewController.m
//  lrc Demo
//
//  Created by txx on 12-7-17.
//  Copyright (c) 2012年 txx. All rights reserved.
//

#import "ViewController.h"
#import "LrcParse.h"

#define kNormalRColor .42
#define kNormalGColor .24
#define kNormalBColor .10
#define kHighLightRColor 1
#define kHighLightGColor 0
#define kHighLightBColor 0
#define kTableViewCellHeight 20

@interface ViewController ()
//- (void) changeColor: (UISlider*) slider;
- (void) scrollTableView;

@end

@implementation ViewController
/*
- (void) changeColor:(UISlider *)slider
{
    if (slider.tag == 1)
    {
        rColor = slider.value;
    }
    
    if (slider.tag == 2)
    {
        gColor = slider.value;
    }
    
    if (slider.tag == 3)
    {
        bColor = slider.value;
    }
    
    NSLog(@"r = %.2f", rColor);
    NSLog(@"g = %.2f", gColor);
    NSLog(@"b = %.2f", bColor);
    
    UITableViewCell* cell = [(UITableView*)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
    cell.textLabel.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
}
*/

- (void) scrollTableView
{
    _timerCnt ++;
    _tableViewOffset.y+=_delta;
    _tableView.contentOffset = _tableViewOffset;
    
    
    if (_nowHighlight >= _tableViewdataSource.count-1) return;
    if ((int)([(lyric*)[_tableViewdataSource objectAtIndex:_nowHighlight+1] time] * 1000) == _timerCnt)
    {
        if (_nowHighlight >= _lrcStart)
        {
            UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_nowHighlight inSection:0]];
            cell.textLabel.textColor = [UIColor colorWithRed:kNormalRColor
                                                       green:kNormalGColor
                                                        blue:kNormalBColor
                                                       alpha:1];
        }
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_nowHighlight+1 inSection:0]];
        cell.textLabel.textColor = [UIColor colorWithRed:kHighLightRColor
                                                   green:kHighLightGColor
                                                    blue:kHighLightBColor
                                                   alpha:1];
        _nowHighlight ++;
    }
}



#pragma mark - avaudioPlayDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_timer invalidate];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableViewdataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"- -"];

    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"- -"] autorelease];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
        cell.textLabel.textColor = [UIColor colorWithRed:.42
                                                   green:.24
                                                    blue:.10
                                                   alpha:1];
    }
    
    id item = [_tableViewdataSource objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[lyric class]])
    {
        cell.textLabel.text = [(lyric*)item lyricString];
    }
    else
    {
        cell.textLabel.text = [item description];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}

#pragma mark -  UIViewController LifeCircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"dango"
                                                     ofType:@"lrc"];
    _tableViewdataSource = [[LrcParse parseFromFile:path] retain];
    
    for (int i=0; i<_tableViewdataSource.count; i++) {
        if ([[_tableViewdataSource objectAtIndex:i] isKindOfClass:[lyric class]])
        {
            _lrcStart = i;
            break;
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IMG_0393.jpg"]] autorelease];
    _tableView.scrollEnabled = NO;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.view = _tableView;
    [_tableView release];
    
    path = [[NSBundle mainBundle] pathForResource:@"dango"
                                           ofType:@"mp3"];
    NSURL* url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError* error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                     error:&error];
    [_player prepareToPlay];
    [_player play];
    _player.delegate = self;
    
    float winSize = [[UIScreen mainScreen] bounds].size.height;
    _delta = (_tableViewdataSource.count - (winSize / 20) / 2) * 20 / (_player.duration * 1000);
    _timerCnt = 0;
    _nowHighlight = _lrcStart - 1;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.001
                                              target:self
                                            selector:@selector(scrollTableView)
                                            userInfo:nil
                                             repeats:YES];
    
    /*
     rColor = gColor = bColor = 1;
     
     UISlider* sliderR = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
     [self.view addSubview:sliderR];
     [sliderR release];
     [sliderR addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
     sliderR.value = 1;
     sliderR.tag = 1;
     
     UISlider* sliderG = [[UISlider alloc] initWithFrame:CGRectMake(0, 30, 320, 20)];
     [sliderG addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
     [self.view addSubview:sliderG];
     [sliderG release];
     sliderG.value = 1;
     sliderG.tag = 2;
     
     UISlider* sliderB = [[UISlider alloc] initWithFrame:CGRectMake(0, 60, 320, 20)];
     [sliderB addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventValueChanged];
     [self.view addSubview:sliderB];
     [sliderB release];
     sliderB.value = 1;
     sliderB.tag = 3;
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) dealloc
{
    [_tableViewdataSource release];
    
    [super dealloc];
}
@end
