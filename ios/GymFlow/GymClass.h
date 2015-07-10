//
//  GymClass.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/9/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GymClass : NSObject

@property (nonatomic) NSInteger classID;
@property (nonatomic, copy) NSString* className;
@property (nonatomic, copy) NSString* classRoom;
@property (nonatomic, copy) NSString* weekday;
@property (nonatomic, copy) NSString* imageName;

@property (nonatomic, retain) NSDateComponents *startTime;
@property (nonatomic, retain) NSDateComponents *endTime;
@property (nonatomic, copy) NSString *description;

@end
