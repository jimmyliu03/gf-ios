//
//  GymFlowStore.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 4/15/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import "GymFlowStore.h"
#import "GymClass.h"
#import "Flurry.h"
#import "AFJSONRequestOperation.h"

#define   kDefaultGymIndex      0

@implementation GymFlowStore

- (id) init
{
    self = [super init];
    if (self) {
        gymList = [[NSMutableArray alloc] init];
        roomTrafficInfo = [[NSMutableArray alloc] init];
        gymMainInfo = [[NSMutableDictionary alloc] init];
        currentTraffic = [[NSMutableDictionary alloc] init];
        predictedTraffic = [[NSMutableDictionary alloc] init];
        historicalTraffic = [[NSMutableDictionary alloc] init];
        curSchedule = [[NSMutableArray alloc] init];
        facilityHour = [[NSMutableArray alloc] init];
        normalHours = [[NSMutableArray alloc] init];
        currentGymIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"current_gym_index"];
    }
    return self;
}

- (NSString *) getTodayKey
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd"];
    return [dateFormat  stringFromDate: [NSDate date]];
}

- (Boolean) roomTraficAvailable
{
    if ([[gymMainInfo objectForKey: @"room_traffic_available"] integerValue] == 0)
        return false;
    else
        return true;
}


- (void) setCurrentGymIndex: (NSInteger) gymIndex
{
    currentGymIndex = gymIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:gymIndex forKey:@"current_gym_index"];
}


- (NSInteger) currentGymIndex
{
    return currentGymIndex;
}

- (NSString *) currentGymName
{
    id gym_obj = nil;
    for (gym_obj in gymList) {
        if ([[gym_obj objectForKey:@"gym_id"] integerValue] == currentGymIndex) {
            return [gym_obj objectForKey:@"gym_name"];
        }
    }
    return @"Current Gym";
}


- (NSString *) getFacilityImgNameWithID: (NSString *) facilityIDString
{
    id facility_obj = nil;
    
    for (facility_obj in [gymMainInfo objectForKey: @"facility_info"]) {
        if ([ [facility_obj objectForKey:@"facility_id"] isEqualToString:facilityIDString]) {
            return [facility_obj objectForKey:@"facility_img_name"];
        }
    }
    return @"";
}

- (NSString *) getFacilityNameWithID: (NSString *) facilityIDString
{
    id facility_obj = nil;
    
    for (facility_obj in [gymMainInfo objectForKey: @"facility_info"]) {
        if ([ [facility_obj objectForKey:@"facility_id"] isEqualToString:facilityIDString]) {
            return [facility_obj objectForKey:@"facility_name"];
        }
    }
    return @"";
}

- (void) setGymMainInfo: (NSDictionary *) gymInfo
{
    @try {
        [gymMainInfo setDictionary: gymInfo];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_GYM_MAIN_INFO" message:@"ERR_LOAD_GYM_MAIN_INFO" exception:exception];
    }
}


- (void) setCurrentTraffic: (NSMutableDictionary *) curTraffic
{
    @try {
        [currentTraffic setDictionary: curTraffic];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_UPDATED_TRAFFIC" message:@"ERR_LOAD_UPDATED_TRAFFIC" exception:exception];
    }
}


- (void) setPredictedTraffic: (NSMutableDictionary *) predictTraffic
{
    @try {
        [predictedTraffic setDictionary: predictTraffic];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_PREDICTED_TRAFFIC" message:@"ERR_LOAD_PREDICTED_TRAFFIC" exception:exception];
    }
}


- (void) setHistoricalTraffic: (NSMutableDictionary *) historicTraffic
{
    @try {
        [historicalTraffic setDictionary: historicTraffic];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_HISTORICAL_TRAFFIC" message:@"ERR_LOAD_HISTORICAL_TRAFFIC" exception:exception];
    }
}


- (void) setFacilityHours: (NSArray *) todayHours
{
    @try {
        [facilityHour setArray:todayHours];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_TODAY_HOURS" message:@"ERR_LOAD_TODAY_HOURS" exception:exception];
    }
}


- (void) setNormalHours: (NSDictionary *) normHours
{
    @try {
        [normalHours setArray:[normHours objectForKey:@"hours"]];
        normalHourName = [normHours objectForKey:@"hours_name"];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_NORMAL_HOURS" message:@"ERR_LOAD_NORMAL_HOURS" exception:exception];
    }    
}


- (void) updateTodayPredictedTraffic: (NSDictionary *) predictTodayData
{
    @try {
        NSString *dateKey = [self getTodayKey];
        [predictedTraffic setObject:predictTodayData forKey: dateKey];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_PREDICTED_TRAFFIC" message:@"ERR_LOAD_TODAY_PREDICT_TRAFFIC" exception:exception];
    }
}


- (void) setGymList: (NSArray *) listOfGyms
{
    @try {
        [gymList setArray:listOfGyms];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_GYM_LIST" message:@"ERR_LOAD_GYM_LIST" exception:exception];
    }
}

- (void) setRoomTrafficInfo: (NSArray *) roomInfo {
    @try {
        [roomTrafficInfo removeAllObjects];
        [roomTrafficInfo setArray:roomInfo];
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_ROOM_INFO" message:@"ERR_LOAD_ROOM_INFO" exception:exception];
    }
}


- (void) setTodayClassSchedule: (NSArray *) classScheduleData
{
    @try {
        [curSchedule removeAllObjects];
        for (int k = 0; k < [classScheduleData count]; k++)
        {
            id gymClass = classScheduleData[k];
            GymClass *newClass = [[GymClass alloc] init];
            newClass.className = [gymClass objectForKey: @"class_name"];
            newClass.classRoom = [gymClass objectForKey: @"room"];
            newClass.weekday = [gymClass objectForKey: @"weekday"];
            newClass.description = [gymClass objectForKey: @"description"];
            newClass.imageName = [gymClass objectForKey:@"img_name"];
            newClass.startTime = [[NSDateComponents alloc] init];
            newClass.endTime = [[NSDateComponents alloc] init];
            
            NSString *startString = [gymClass objectForKey:@"start_time"];
            NSString *endString = [gymClass objectForKey:@"end_time"];
            
            [newClass.startTime setHour:[[startString substringWithRange:NSMakeRange(0, 2)] integerValue]];
            [newClass.startTime setMinute:[[startString substringWithRange:NSMakeRange(3, 2)] integerValue]];
            [newClass.endTime setHour:[[endString substringWithRange:NSMakeRange(0, 2)] integerValue]];
            [newClass.endTime setMinute:[[endString substringWithRange:NSMakeRange(3, 2)] integerValue]];
            
            [curSchedule addObject:newClass];
        }
    }
    @catch (NSException *exception) {
        [Flurry logError:@"ERR_LOAD_TODAY_SCHEDULE" message:@"ERR_LOAD_TODAY_SCHEDULE" exception:exception];
    }    
}


- (NSMutableDictionary *) gymMainInfo
{
    return gymMainInfo;
}


- (NSMutableDictionary *) currentTraffic
{
    return currentTraffic;
}


- (NSMutableDictionary *) predictedTraffic
{
    return predictedTraffic;
}


- (NSMutableDictionary *) historicalTraffic
{
    return historicalTraffic;
}


- (NSMutableArray *) curSchedule
{
    return curSchedule;
}


- (NSMutableArray *) facilityHour
{
    return facilityHour;
}


- (NSMutableArray *) normalHours
{
    return normalHours;
}


- (NSString *) normalHoursName
{
    return normalHourName;
}


- (NSMutableArray *) gymList
{
    return gymList;
}

- (NSMutableArray *) roomTrafficInfo
{
    return roomTrafficInfo;
}

+ (GymFlowStore *) sharedStore
{
    static GymFlowStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}


+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

@end
