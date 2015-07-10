//
//  GymFlowStore.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 4/15/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GymFlowStore : NSObject
{
    NSMutableArray *gymList;
    NSMutableArray *roomTrafficInfo;
    NSMutableDictionary *gymMainInfo;
    NSMutableDictionary *currentTraffic;
    NSMutableDictionary *predictedTraffic;
    NSMutableDictionary *historicalTraffic;
    NSMutableArray *curSchedule;
    NSMutableArray *facilityHour;
    NSMutableArray *normalHours;
    NSString *normalHourName;
    NSInteger currentGymIndex;
}

+ (GymFlowStore *) sharedStore;

- (NSMutableArray *) gymList;
- (NSMutableArray *) roomTrafficInfo;
- (NSMutableDictionary *) gymMainInfo;
- (NSMutableDictionary *) currentTraffic;
- (NSMutableDictionary *) predictedTraffic;
- (NSMutableDictionary *) historicalTraffic;
- (NSMutableArray *) curSchedule;
- (NSMutableArray *) facilityHour;
- (NSMutableArray *) normalHours;
- (NSString *) normalHoursName;
- (Boolean) roomTraficAvailable;
- (NSInteger) currentGymIndex;
- (NSString *) currentGymName;
- (NSString *) getFacilityImgNameWithID: (NSString *) facilityIDString;
- (NSString *) getFacilityNameWithID: (NSString *) facilityIDString;

- (void) setRoomTrafficInfo: (NSArray *) roomInfo;
- (void) setGymList: (NSArray *) listOfGyms;
- (void) setCurrentTraffic: (NSMutableDictionary *) curTraffic;
- (void) setPredictedTraffic: (NSMutableDictionary *) predictedTraffic;
- (void) setHistoricalTraffic: (NSMutableDictionary *) historicTraffic;
- (void) setFacilityHours: (NSArray *) todayHours;
- (void) setNormalHours: (NSDictionary *) normHours;
- (void) setTodayClassSchedule: (NSArray *) classScheduleData;
- (void) updateTodayPredictedTraffic: (NSDictionary *) predictTodayData;
- (void) setGymMainInfo: (NSDictionary *) gymInfo;
- (void) setCurrentGymIndex: (NSInteger) gymIndex;

@end
