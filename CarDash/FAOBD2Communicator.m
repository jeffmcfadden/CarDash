//
//  FAOBD2Communicator.m
//  CarDash
//
//  Created by Jeff McFadden on 7/12/14.
//  Copyright (c) 2015 Jeff McFadden. All rights reserved.
//

//https://en.wikipedia.org/wiki/OBD-II_PIDs
//http://www.windmill.co.uk/obdii.pdf :
//MPG = VSS * 7.718 / MAF

#import "FAOBD2Communicator.h"

NSString *const kFAOBD2PIDMassAirFlow              = @"10";
NSString *const kFAOBD2PIDFuelFlow = @"kFAOBD2PIDFuelFlow"; //Calculated
NSString *const kFAOBD2PIDVehicleSpeed             = @"0D";

NSString *const kFAOBD2PIDVehicleFuelLevel         = @"2F";
NSString *const kFAOBD2PIDAmbientAirTemperature    = @"46";
NSString *const kFAOBD2PIDEngineCoolantTemperature = @"67";
NSString *const kFAOBD2PIDAirIntakeTemperature     = @"68";
NSString *const kFAOBD2PIDControlModuleVoltage     = @"42";

NSString *const kFAOBD2PIDDataUpdatedNotification = @"kFAOBD2PIDDataUpdatedNotification";



@interface FAOBD2Communicator () <NSStreamDelegate>

@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;

@property (atomic, assign) BOOL readyToSend;

@property (nonatomic) NSArray *sensorPIDsToScan;

@property (assign) NSInteger currentPIDIndex;

@property (nonatomic) NSTimer *pidsTimer;

@end

@implementation FAOBD2Communicator

+ (id)sharedInstance
{
    static FAOBD2Communicator *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[FAOBD2Communicator alloc] init];
                  });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.readyToSend = YES;
        
        self.sensorPIDsToScan = @[kFAOBD2PIDMassAirFlow, kFAOBD2PIDVehicleSpeed, kFAOBD2PIDVehicleFuelLevel, kFAOBD2PIDEngineCoolantTemperature, kFAOBD2PIDAmbientAirTemperature, kFAOBD2PIDAirIntakeTemperature, kFAOBD2PIDControlModuleVoltage];
        self.currentPIDIndex =  0;
        
    }
    return self;
}

- (CGFloat)ctof:(CGFloat)c
{
    return (c * 1.8000 + 32.00 );
}

- (void)connect
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.0.10", 35000, &readStream, &writeStream);
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

- (void)restart
{
    [self stop];
    [self performSelector:@selector(startStreaming) withObject:nil afterDelay:2.0];
}

- (void)stop
{
    [self.pidsTimer invalidate];
    
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)startStreaming
{
    //lolz oh geez
    [self performSelector:@selector(connect) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(sendInitialATCommands1) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(sendInitialATCommands2) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(streamPIDs) withObject:nil afterDelay:4.0];
}

- (void)sendInitialATCommands1
{
    NSLog(@"sendInitialATCommands1");
    
    NSString *message  = [NSString stringWithFormat:@"ATZ\r"];
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes] maxLength:[data length]];
}

- (void)sendInitialATCommands2
{
    NSLog(@"sendInitialATCommands2");
    
    NSString *message  = [NSString stringWithFormat:@"ATP0\r"];
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes] maxLength:[data length]];
}

- (void)streamPIDs
{
    self.pidsTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(askForPIDs) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.pidsTimer forMode:NSDefaultRunLoopMode];
}

- (void)askForPIDs
{
    if (self.readyToSend) {
        self.readyToSend = NO;
        NSLog(@"askForPIDs");
        
        NSString *sensorPID = self.sensorPIDsToScan[self.currentPIDIndex];
        
        NSString *message  = [NSString stringWithFormat:@"01%@1\r", sensorPID];
        NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        self.currentPIDIndex += 1;
        
        if (self.currentPIDIndex >= self.sensorPIDsToScan.count) {
            self.currentPIDIndex = 0;
        }
        
        //    NSString *message2  = [NSString stringWithFormat:@"010D\r"];
        //    NSData *data2 = [[NSData alloc] initWithData:[message2 dataUsingEncoding:NSASCIIStringEncoding]];
        //    [self.outputStream write:[data2 bytes] maxLength:[data2 length]];
    }
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %lu", (unsigned long)streamEvent);
    
    switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            NSLog(@"NSStreamEventHasBytesAvailable");

            if (theStream == self.inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                            
                            [output enumerateLinesUsingBlock:^(NSString *line, BOOL *stop){
                                
                                //NSLog(@"Line: %@", line );
                                
                                [self parseResponse:line];
                                
                            }];
                            
                        }
                    }
                }
            }
            
            self.readyToSend = YES;

			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");

            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

			break;
            
		default:
			NSLog(@"Unknown event");
	}
}

- (void)parseResponse:(NSString *)response
{
    if (response.length < 5) {
        //NSLog( @"Too short of a response line to care." );
        return;
    }
    
    if ([[response substringToIndex:2] isEqualToString:@"41"]) {
        NSLog( @"We have a response we can parse: %@", response );
        
        NSString *responseSensorID = [response substringWithRange:NSMakeRange(3, 2)];
        NSString *responseData     = [response substringFromIndex:6];
        
        NSMutableArray *byteValues = [NSMutableArray new];
        
        
        NSArray *responseBytes = [responseData componentsSeparatedByString:@" "];
        
        for (NSString *byte in responseBytes){
            NSScanner *scanner = [NSScanner scannerWithString:byte];
            unsigned int dataValue;
            [scanner scanHexInt:&dataValue];
            
            //NSLog( @"Converted data (%@) to int is: %d", byte, dataValue );
            
            [byteValues addObject:[NSNumber numberWithInt:dataValue]];
        }
        
        if ([responseSensorID isEqualToString:kFAOBD2PIDMassAirFlow]) {
            CGFloat maf = (([byteValues[0] intValue] * 256.0 ) + [byteValues[1] intValue]) / 100.0;
            CGFloat gph = maf * 0.0805;
            
            NSLog( @"MAF: %0.1f grams/sec", maf );
            NSLog( @"GPH: %0.1f", gph );
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDMassAirFlow, @"value":[NSNumber numberWithDouble:maf]}];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDFuelFlow, @"value":[NSNumber numberWithDouble:gph]}];
        }else if ([responseSensorID isEqualToString:kFAOBD2PIDVehicleSpeed] ) {
            CGFloat mph = ([byteValues[0] intValue] * 0.621371 );
            
            NSLog( @"MPH: %0.1f ", mph );
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDVehicleSpeed, @"value":[NSNumber numberWithDouble:mph]}];
        }else if ([responseSensorID isEqualToString:kFAOBD2PIDEngineCoolantTemperature] ) {
            CGFloat c = ([byteValues[0] intValue] - 40 );
            CGFloat f = [self ctof:c];
            
            NSLog( @"Coolant Temp (F): %0.1f ", f );
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDEngineCoolantTemperature, @"value":[NSNumber numberWithDouble:f]}];
        }else if ([responseSensorID isEqualToString:kFAOBD2PIDAmbientAirTemperature] ) {
            CGFloat c = ([byteValues[0] intValue] - 40 );
            CGFloat f = [self ctof:c];
            
            NSLog( @"Ambient Temp (F): %0.1f ", f );
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDAmbientAirTemperature, @"value":[NSNumber numberWithDouble:f]}];
        }else if ([responseSensorID isEqualToString:kFAOBD2PIDAirIntakeTemperature] ) {
            CGFloat c = ([byteValues[0] intValue] - 40 );
            CGFloat f = [self ctof:c];
            
            NSLog( @"Intake Temp (F): %0.1f ", f );
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDAirIntakeTemperature, @"value":[NSNumber numberWithDouble:f]}];
        }else if ([responseSensorID isEqualToString:kFAOBD2PIDControlModuleVoltage] ) {
            CGFloat v = (([byteValues[0] intValue] * 256.0 ) + [byteValues[1] intValue]) / 1000.0;
            
            NSLog( @"Control Module Voltage: %0.1v ", v );
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDControlModuleVoltage, @"value":[NSNumber numberWithDouble:v]}];
        }else if ([responseSensorID isEqualToString:kFAOBD2PIDVehicleFuelLevel] ) {
            CGFloat fl = (([byteValues[0] intValue] * 100.0)/255.0);
            
            NSLog( @"Fuel Level: %0.1f", fl );
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFAOBD2PIDDataUpdatedNotification object:@{@"sensor":kFAOBD2PIDVehicleFuelLevel, @"value":[NSNumber numberWithDouble:fl]}];
        }
        
        NSLog( @"Response Sensor ID: %@", responseSensorID );
        NSLog( @"Response Sensor Data: %@", responseData );
        
    }else{
        //NSLog( @"This looks like something I don't know how to parse right now: %@", response );
    }
}

@end
