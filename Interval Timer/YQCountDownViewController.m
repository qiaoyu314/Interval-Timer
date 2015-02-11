//
//  YQCountDownViewController.m
//  Interval Timer
//
//  Created by Yu Qiao on 1/11/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

#import "YQCountDownViewController.h"
#import "Timer+TimerWithHelper.h"
#import <AudioToolbox/AudioToolbox.h>

@interface YQCountDownViewController ()
@property (weak, nonatomic) IBOutlet UILabel *reminingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStateLabel;
@property (weak, nonatomic) IBOutlet UIView *timerView;
@property (weak, nonatomic) IBOutlet UILabel *totalReminingLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalEscapingLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminingCycleLabel;

@property(nonatomic, weak)IBOutlet UIButton *pauseButton;
@property(nonatomic, weak)IBOutlet UIButton *cancleButton;

@property(nonatomic, weak) NSTimer *countDowntTimer;
@property(nonatomic)int currentReminingTime;
@property(nonatomic)int totoalReminingTime;
@property(nonatomic)timerState currentState;
@property(nonatomic)NSInteger reminingCycle;
@property(nonatomic)BOOL firstTime;



@end

@implementation YQCountDownViewController

//some global variables
int totalTime;
UIColor *myYellow;
UIColor *myGrey;
NSInteger totalCycleString;
CFURLRef *soundURL;
SystemSoundID   soundID;



#pragma mark - setter

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
    self.currentStateLabel.text = [self convertTimerStateToString:currentState];
}

-(void)setReminingCycle:(NSInteger)reminingCycle
{
    _reminingCycle = reminingCycle;
    if (self.firstTime) {
        totalCycleString = [self.timer.cycle integerValue];
        self.firstTime = false;
    }
    self.reminingCycleLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)reminingCycle,(long)totalCycleString];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set button shape and color
    [self setUpButtons];
    //set up timer
    [self setupTimer];
    
}

-(void)setUpButtons
{
    self.pauseButton.layer.cornerRadius = 40.0f;
    self.pauseButton.layer.borderWidth = 1.5;
    self.pauseButton.layer.borderColor = [UIColor greenColor].CGColor;
    [self.pauseButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.cancleButton.layer.cornerRadius =40.0f;
    self.cancleButton.layer.borderWidth = 1.5;
    if (!myYellow) {
        myYellow = [UIColor colorWithRed:255/255.0f green:215/255.0f blue:0/255.0f alpha:1];
    }
    if (!myGrey) {
        myGrey = [UIColor colorWithRed:238/255.0f green:230/255.0f blue:221/255.0f alpha:1];
    }
    //disable cancle button
    [self.cancleButton setEnabled:NO];
    self.cancleButton.layer.borderColor = myGrey.CGColor;
    [self.cancleButton setTitleColor:myGrey forState:UIControlStateNormal];

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
        self.currentState = [self goToNextState];
        if (self.currentState != TIMER_END) {
            self.countDowntTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
            
            //play sound
            AudioServicesPlaySystemSound(1005);
        }else{
            //use a different sound when timer ends
            AudioServicesPlaySystemSound(1010);
            //timer ends
            //dispaly
            [[UIApplication sharedApplication ] setIdleTimerDisabled:NO] ;
            [self.pauseButton setEnabled:false];
            self.pauseButton.layer.borderColor = myGrey.CGColor;
            [self.pauseButton setTitleColor:myGrey forState:UIControlStateNormal];
            self.timerView.backgroundColor = [UIColor blackColor];
        }
    }
}

-(void)setupTimer
{
    self.firstTime = true;
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
    //dispaly
    [[UIApplication sharedApplication ] setIdleTimerDisabled:YES];
    
}
-(void)startTimer
{
    self.countDowntTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

#pragma mark - some helper

//conver timerState to string
-(NSString *)convertTimerStateToString:(timerState)state
{
    NSString *result;
    switch (state) {
        case TIMER_WARM_UP:
            result = [NSString stringWithFormat:@"WARM UP"];
            break;
        case TIMER_ROUND:
            result = [NSString stringWithFormat:@"ROUND"];
            break;
        case TIMER_REST:
            result = [NSString stringWithFormat:@"REST"];
            break;
        case TIMER_COOL_DOWN:
            result = [NSString stringWithFormat:@"COOL DOWN"];
            break;
        case TIMER_END:
            result = [NSString stringWithFormat:@"END"];
        default:
            result = [NSString stringWithFormat:@"END"];
            break;
    }
    return result;
}

//get next state. will not set any other properties
-(timerState)getNextState:(timerState)state
{
    timerState returnState;
    switch (self.currentState) {
        case TIMER_WARM_UP:
            returnState = TIMER_ROUND;
            break;
        case TIMER_ROUND:
            //if it's the last cycle, go to cool down
            if (self.reminingCycle == 1) {
                self.reminingCycle --;
                if ([self.timer.cooldownLength intValue] > 0) {
                    returnState = TIMER_COOL_DOWN;
                }else{
                    returnState = TIMER_END;
                }
            }else{
                if ([self.timer.restLength intValue] > 0) {
                    returnState = TIMER_REST;
                }
                else{
                    //rest is not set
                    returnState = TIMER_ROUND;
                }
            }
            break;
        case TIMER_REST:
            self.currentReminingTime = [self.timer.roundLength intValue];
            returnState = TIMER_ROUND;
            break;
        default:
            returnState = TIMER_END;
            break;
    }
    return returnState;
}

//set next state to current state. will set reminingCycle
-(timerState)goToNextState
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

#pragma mark - pause and restart timer
- (IBAction)startAndPauseTimer
{
    if ([self.pauseButton.titleLabel.text isEqualToString:@"Start"]) {
        //start timer
        [self startTimer];
        //chage title and color
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.pauseButton.layer.borderColor = [UIColor redColor].CGColor;
        [self.pauseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        //enable cancle button
        [self.cancleButton setEnabled:YES];
        self.cancleButton.layer.borderColor = [UIColor blackColor].CGColor;
        [self.cancleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    else if ([self.pauseButton.titleLabel.text isEqualToString:@"Pause"]) {
        [self.countDowntTimer invalidate];
        [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
        self.pauseButton.layer.borderColor = [UIColor greenColor].CGColor;
        [self.pauseButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }else{
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.countDowntTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        self.pauseButton.layer.borderColor = [UIColor redColor].CGColor;
        [self.pauseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
    
}


- (IBAction)cancleTimer {
    [self.countDowntTimer invalidate];
    [self setupTimer];
    //set up start button
    [self.pauseButton setEnabled:true];
    [self.pauseButton setTitle:@"Start" forState:UIControlStateNormal];
    self.pauseButton.layer.borderColor = [UIColor greenColor].CGColor;
    [self.pauseButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    //disable cancle button
    [self.cancleButton setEnabled:NO];
    self.cancleButton.layer.borderColor = myGrey.CGColor;
    [self.cancleButton setTitleColor:myGrey forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self cancleTimer];
}


@end
