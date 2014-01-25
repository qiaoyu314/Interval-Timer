//
//  YQCountDownViewController.m
//  Interval Timer
//
//  Created by Yu Qiao on 1/11/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

#import "YQCountDownViewController.h"
#import "Timer+TimerWithHelper.h"

@interface YQCountDownViewController ()
@property (weak, nonatomic) IBOutlet UILabel *reminingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStateLabel;
@property (weak, nonatomic) IBOutlet UIView *timerView;
@property (weak, nonatomic) IBOutlet UILabel *totalReminingLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalEscapingLabel;

@property(nonatomic, weak) NSTimer *countDowntTimer;
@property(nonatomic)int currentReminingTime;
@property(nonatomic)int totoalReminingTime;
@property(nonatomic)timerState currentState;
@property(nonatomic)NSInteger reminingCycle;

@property(nonatomic, weak)IBOutlet UIButton *pauseButton;
@property(nonatomic, weak)IBOutlet UIButton *restartButton;
@end

@implementation YQCountDownViewController

int totalTime;

-(void)setCurrentReminingTime:(int)currentReminingTime
{
    _currentReminingTime = currentReminingTime;
    if (_currentReminingTime < 4) {
        self.timerView.backgroundColor = [UIColor redColor];

    }else{
        self.timerView.backgroundColor = [UIColor blackColor];
    }
    [self updateReminingTime:_currentReminingTime];
    
}

-(void)setTotoalReminingTime:(int)totoalReminingTime
{
    _totoalReminingTime = totoalReminingTime;
    self.totalReminingLabel.text = [Timer getLengthInString:[NSNumber numberWithInt:totoalReminingTime]];
    int totalEscapingTime = totalTime - totoalReminingTime;
    self.totalEscapingLabel.text =[Timer getLengthInString:[NSNumber numberWithInt:totalEscapingTime]];
}

-(void)setCurrentState:(timerState)currentState
{
    _currentState = currentState;
    switch (currentState) {
        case TIMER_WARM_UP:
            self.currentStateLabel.text = @"Warm Up";
            break;
        case TIMER_ROUND:
            self.currentStateLabel.text = @"Round";
            break;
        case TIMER_REST:
            self.currentStateLabel.text = @"Rest";
            break;
        case TIMER_COOL_DOWN:
            self.currentStateLabel.text = @"Cool Down";
            break;
        case TIMER_END:
            self.currentStateLabel.text = @"End";
        default:
            break;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view.
    
    [self timerSetup];
    
    [[UIApplication sharedApplication ] setIdleTimerDisabled:YES] ;
    
}


-(void)timerAction:(NSTimer *)timer
{
    //update label
    self.currentReminingTime --;
    self.totoalReminingTime --;
}

-(void)updateReminingTime:(NSTimeInterval)reminingTime
{
    self.reminingTimeLabel.text = [Timer getLengthInString:[NSNumber numberWithDouble:reminingTime]];
    if (reminingTime == 0) {
        //cancel the timer;
        [self.countDowntTimer invalidate];
        //start next stage
        self.currentState = [self nextState];
        if (self.currentState != TIMER_END) {
            self.countDowntTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        }else{
            //end
            self.timerView.backgroundColor = [UIColor blackColor];
        }
    }
}

-(void)timerSetup
{
    totalTime = [self.timer.getTotal intValue];
    self.totoalReminingTime = totalTime;
    if ([self.timer.warmUpLength intValue] == 0) {
        self.currentState = TIMER_ROUND;
        self.currentReminingTime = [self.timer.roundLength intValue];
        
    }else{
        self.currentState = TIMER_WARM_UP;
        self.currentReminingTime = [self.timer.warmUpLength intValue];
    }
    self.reminingCycle = [self.timer.cycle integerValue];
    self.countDowntTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

-(timerState)nextState
{
    switch (self.currentState) {
        case TIMER_WARM_UP:
            self.reminingCycle = [self.timer.cycle integerValue];
            self.currentReminingTime = [self.timer.roundLength intValue];
            return TIMER_ROUND;
            break;
        case TIMER_ROUND:
            //if it's the last cycle, go to cool down
            if (self.reminingCycle == 1) {
                self.reminingCycle --;
                if ([self.timer.cooldownLength intValue] > 0) {
                    self.currentReminingTime = [self.timer.cooldownLength intValue];
                    return TIMER_COOL_DOWN;
                }else{
                    return TIMER_END;
                }
            }else{
                if ([self.timer.restLength intValue] > 0) {
                    self.currentReminingTime = [self.timer.restLength intValue];
                    return TIMER_REST;
                }
                else{
                    //rest is not set
                    self.reminingCycle --;
                    self.currentReminingTime = [self.timer.roundLength  intValue];
                    return TIMER_ROUND;
                }
                
            }
            break;
        case TIMER_REST:
            self.reminingCycle --;
            self.currentReminingTime = [self.timer.roundLength intValue];
            return  TIMER_ROUND;
            break;
        default:
            return TIMER_END;
            break;
    }
}


- (IBAction)pauseTimer
{
    if ([self.pauseButton.titleLabel.text isEqualToString:@"Pause"]) {
        [self.countDowntTimer invalidate];
        [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
    }else{
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.countDowntTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
    
    
}


- (IBAction)restartTimer {
    [self.countDowntTimer invalidate];
    [self timerSetup];
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
}


@end
