//
//  SKPushManager.m
//  Time Left
//
//  Created by Salavat Khanov on 1/31/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKPushManager.h"

@interface SKPushManager ()
@property (strong, nonatomic) NSMutableArray *notifications;
@end

@implementation SKPushManager

// Lazy init
- (NSMutableArray *)notifications
{
    if (_notifications == nil) {
        _notifications = [[NSMutableArray alloc] init];
    }
    
    return _notifications;
}

#pragma mark Model Notifications

- (void)registerForModelUpdateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventAdded:)
                                                 name:@"EventAdded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventDeleted:)
                                                 name:@"EventDeleted"
                                               object:nil];
}

- (void)eventAdded:(NSNotification *)addedNotification
{
    if ([[addedNotification.userInfo allKeys][0] isEqual:@"added"]) {
        
        SKEvent *eventToAdd = [addedNotification.userInfo objectForKey:@"added"];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = eventToAdd.endDate;
        localNotification.alertBody = [NSString stringWithFormat:@"%@ is done", eventToAdd.name];
        localNotification.timeZone = [NSTimeZone systemTimeZone];
        localNotification.alertAction = NSLocalizedString(@"check", @"On lock screen under notification — 'slide to ...' ");
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.userInfo = @{@"event" : eventToAdd};
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [self.notifications addObject:localNotification];
        
        NSLog(@"Scheduled notification for %@ at %@ (now = %@)", eventToAdd.name, localNotification.fireDate, [NSDate date]);
    }
}

- (void)eventDeleted:(NSNotification *)deletedNotification
{
    if ([[deletedNotification.userInfo allKeys][0] isEqual:@"deleted"]) {
        
        SKEvent *eventToDelete = [deletedNotification.userInfo objectForKey:@"deleted"];

        UILocalNotification *notificationToCancel;
        [self.notifications enumerateObjectsUsingBlock:^(UILocalNotification obj, NSUInteger idx, BOOL *stop) {
            if ([[obj.userInfo objectForKey:@"event"] isEqual:eventToDelete]) {
                stop = YES;
            }
        }];
        
        [[UIApplication sharedApplication] cancelLocalNotification:<#(UILocalNotification *)#>]
    }
}

@end
