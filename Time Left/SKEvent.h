//
//  SKEvent.h
//  Time Left
//
//  Created by Salavat Khanov on 7/22/13.
//  Copyright (c) 2013 Salavat Khanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKEvent : NSObject

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *name;

- (id)initWithName:(NSString *)name startDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
- (CGFloat)progress;

@end
