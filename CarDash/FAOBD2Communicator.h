//
//  FAOBD2Communicator.h
//  CarDash
//
//  Created by Jeff McFadden on 7/12/14.
//  Copyright (c) 2015 Jeff McFadden. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kFAOBD2PIDMassAirFlow;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDFuelFlow;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDVehicleSpeed;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDDataUpdatedNotification;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDVehicleFuelLevel;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDAmbientAirTemperature;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDEngineCoolantTemperature;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDAirIntakeTemperature;
FOUNDATION_EXPORT NSString *const kFAOBD2PIDControlModuleVoltage;

@interface FAOBD2Communicator : NSObject

+ (id)sharedInstance;

- (void)connect;
- (void)sendInitialATCommands1;
- (void)sendInitialATCommands2;
- (void)askForPIDs;
- (void)streamPIDs;

- (void)startStreaming;
- (void)restart;
- (void)stop;

@end
