//
//  Timer+TimerWithHelper.m
//  Interval Timer
//
//  Created by Yu Qiao on 1/11/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

#import "Timer+TimerWithHelper.h"

@implementation Timer (TimerWithHelper)

-(NSNumber *)getTotal
{
    int total = [self.warmUpLength intValue] +
                [self.roundLength intValue] * [self.cycle intValue] +
                [self.restLength intValue] * ([self.cycle intValue] - 1) +
                [self.cooldownLength intValue];
    
    return [NSNumber numberWithInt:total];
}
+(NSNumber *)getHours:(NSNumber *)length
{
    return [[NSNumber alloc]initWithInteger:[length integerValue]/3600];
}

+(NSNumber *)getMinutes:(NSNumber *)length
{
    return [[NSNumber alloc]initWithInteger:[length integerValue]%3600/60];
}
+(NSNumber *)getSeconds:(NSNumber *)length
{
    return [[NSNumber alloc]initWithInteger:[length integerValue]%3600%60];
}


+(NSString *)getLengthInString:(NSNumber *)length
{
    NSString *hours = [NSString stringWithFormat:@"%@",[self getHours:length]];
    if ([hours length] == 1) {
         hours = [NSString stringWithFormat:@"0%@",hours];
    }
    NSString *minutes = [NSString stringWithFormat:@"%@",[self getMinutes:length]];
    if ([minutes length] == 1) {
         minutes = [NSString stringWithFormat:@"0%@",minutes];
    }
    NSString *seconds = [NSString stringWithFormat:@"%@",[self getSeconds:length]];
    if ([seconds length] == 1) {
        seconds = [NSString stringWithFormat:@"0%@",seconds];
    }
    return [NSString stringWithFormat:@"%@:%@:%@",hours,minutes,seconds];
}
@end
