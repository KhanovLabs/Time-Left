//
//  SKEvent+Helper.m
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKEvent+Helper.h"

static NSString *kDays = @"DAYS LEFT";
static NSString *kHours = @"HRS LEFT";
static NSString *kMinutes = @"MINS LEFT";
static NSString *kSeconds = @"SECS LEFT";
static NSString *kDone = @"DONE";

@implementation SKEvent (Helper)

- (CGFloat)progress
{
    if (self.startDate && self.endDate) {
        NSTimeInterval intervalSinceStart = [self.endDate timeIntervalSinceDate:self.startDate];
        NSTimeInterval intervalSinceNow = [[NSDate date] timeIntervalSinceDate:self.startDate];
        return intervalSinceNow / intervalSinceStart;
    }
    
    NSLog(@"Error: start date or end date is invalid");
    return 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name '%@', startDate '%@', endDate '%@', desc '%@'", self.name, self.startDate, self.endDate, self.details];
}

- (NSInteger)daysLeft
{
    return lroundf([self hoursLeft] / 24.0);
}

- (NSInteger)hoursLeft
{
    return lroundf([self minutesLeft] / 60.0);
}

- (NSInteger)minutesLeft
{
    return lroundf([self secondsLeft] / 60.0);
}

- (NSInteger)secondsLeft
{
    return lroundf([self.endDate timeIntervalSinceDate:[NSDate date]]);
}

- (NSDictionary *)bestNumberAndText
{
    NSNumber *number;
    NSString *text;
    
    if ([self daysLeft] > 2) {
        number = @([self daysLeft]);
        text = kDays;
    }
    else if ([self hoursLeft] > 2) {
        number = @([self hoursLeft]);
        text = kHours;
    }
    else if ([self minutesLeft] > 5) {
        number = @([self minutesLeft]);
        text = kMinutes;
    }
    else if ([self secondsLeft] >= 0) {
        number = @([self secondsLeft]);
        text = kSeconds;
    }
    else {
        number = @(0);
        text = kDone;
    }
    
    return @{@"number": number,
             @"text" : text};
}

@end
