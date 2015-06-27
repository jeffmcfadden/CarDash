//
//  FAMPGViewController.m
//  CarDash
//
//  Created by Jeff McFadden on 7/12/14.
//  Copyright (c) 2015 Jeff McFadden. All rights reserved.
//

#import "FADashboardViewController.h"
#import "FAHorizontalMeterView.h"

@interface FADashboardViewController ()

@property (nonatomic) IBOutlet UILabel *gphLabel;
@property (nonatomic) IBOutlet UILabel *mphLabel;
@property (nonatomic) IBOutlet UILabel *mpgLabel;
@property (nonatomic) IBOutlet UILabel *mpgShortLabel;

@property (nonatomic) IBOutlet UITextView *debugOutputTextView;

@property (nonatomic) NSTimer *pidTimer;

@property (assign) CGFloat mph;
@property (assign) CGFloat gph;
@property (assign) CGFloat mpgAvg;
@property (assign) CGFloat mpgLongAvg;
@property (assign) CGFloat fuelLevel;

@property (nonatomic) NSMutableArray *mpgHistory;
@property (nonatomic) NSMutableArray *mpgLongHistory;

@property (nonatomic) NSMutableArray *fuelLevelHistory;

@property (nonatomic) IBOutlet FAHorizontalMeterView *coolantTemperatureMeterView;
@property (nonatomic) IBOutlet FAHorizontalMeterView *intakeTemperatureMeterView;
@property (nonatomic) IBOutlet FAHorizontalMeterView *fuelLevelMeterView;
@property (nonatomic) IBOutlet FAHorizontalMeterView *rangeMeterView;
@property (nonatomic) IBOutlet FAHorizontalMeterView *instantMPGMeterView;
@property (nonatomic) IBOutlet FAHorizontalMeterView *mpgMeterView;
@property (nonatomic) IBOutlet FAHorizontalMeterView *voltageMeterView;

@end

@implementation FADashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mph = 0;
    self.gph = 2.01;
    
    self.mpgHistory = [@[] mutableCopy];
    self.mpgLongHistory = [@[] mutableCopy];
    self.fuelLevelHistory = [@[] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pidDataDidUpdate:) name:kFAOBD2PIDDataUpdatedNotification object:nil];
}

- (void)pidDataDidUpdate:(NSNotification *)notification
{
    //DLog( @"%@", notification );
    //DLog( @"%@", notification.object );
    
    if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDFuelFlow]) {
        self.gph = [notification.object[@"value"] doubleValue];
        [self updateMPGValues];
    }else if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDVehicleSpeed]){
        self.mph = [notification.object[@"value"] doubleValue];
        [self updateMPGValues];
    }else if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDEngineCoolantTemperature]){
        self.coolantTemperatureMeterView.currentValue = [notification.object[@"value"] doubleValue];
    }else if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDAirIntakeTemperature]){
        self.intakeTemperatureMeterView.currentValue = [notification.object[@"value"] doubleValue];
    }else if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDVehicleFuelLevel]){
        self.fuelLevel = [notification.object[@"value"] doubleValue];
        [self updateFuelLevelAndRange];
    }else if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDControlModuleVoltage]){
        self.voltageMeterView.currentValue = [notification.object[@"value"] doubleValue];
    }
    
    [self updateLabels];
}

- (void)updateMPGValues
{
    CGFloat mpg;
    if (self.mph == 0) {
        mpg = 0;
    }else{
        mpg = self.mph/self.gph;
    }
    
    [self.mpgHistory addObject:[NSNumber numberWithDouble:mpg]];
    [self.mpgLongHistory addObject:[NSNumber numberWithDouble:mpg]];
    
    if (self.mpgHistory.count > 20) {
        [self.mpgHistory removeObjectAtIndex:0];
    }
    
    if (self.mpgLongHistory.count > 120) {
        [self.mpgLongHistory removeObjectAtIndex:0];
    }
    
    CGFloat total = 0.0;
    for (int i = 0; i < self.mpgHistory.count; i++) {
        total += [self.mpgHistory[i] doubleValue];
    }
    
    self.mpgAvg = total / self.mpgHistory.count;
    
    CGFloat longTotal = 0.0;
    for (int i = 0; i < self.mpgLongHistory.count; i++) {
        longTotal += [self.mpgLongHistory[i] doubleValue];
    }
    
    self.mpgLongAvg = longTotal / self.mpgLongHistory.count;
}

- (void)updateFuelLevelAndRange
{
    [self.fuelLevelHistory addObject:[NSNumber numberWithDouble:self.fuelLevel]];
    
    if (self.fuelLevelHistory.count > 60) {
        [self.fuelLevelHistory removeObjectAtIndex:0];
    }
    
    CGFloat longTotal = 0.0;
    for (int i = 0; i < self.fuelLevelHistory.count; i++) {
        longTotal += [self.fuelLevelHistory[i] doubleValue];
    }
    
    NSInteger averageFuelLevel = longTotal / self.fuelLevelHistory.count;
    
    NSInteger fuelTakeCapacity = 21.0;
    
    NSInteger range = ( fuelTakeCapacity * ( averageFuelLevel / 100.0 ) ) * self.mpgLongAvg;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fuelLevelMeterView.currentValue = averageFuelLevel;
        self.rangeMeterView.currentValue = range;
    });
}

- (void)updateLabels
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.gphLabel.text = [NSString stringWithFormat:@"%0.2f", self.gph];
        self.mphLabel.text = [NSString stringWithFormat:@"%0.0f", self.mph];
        self.mpgLabel.text = [NSString stringWithFormat:@"%.0f", self.mpgLongAvg];
        self.mpgShortLabel.text = [NSString stringWithFormat:@"%.0f", self.mpgAvg];
        
        self.mpgMeterView.currentValue = self.mpgLongAvg;
        self.instantMPGMeterView.currentValue = self.mpgAvg;
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)atz:(id)sender
{
    [[FAOBD2Communicator sharedInstance] sendInitialATCommands1];
}

- (IBAction)atp0:(id)sender
{
    [[FAOBD2Communicator sharedInstance] sendInitialATCommands1];
}

- (IBAction)pids:(id)sender
{
    [[FAOBD2Communicator sharedInstance] askForPIDs];
}

- (IBAction)streamPIDs:(id)sender
{

}

- (IBAction)showSettings:(id)sender
{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainInterface" bundle:nil] instantiateViewControllerWithIdentifier:@"settingsViewController"];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.coolantTemperatureMeterView.currentValue = 202;
    self.intakeTemperatureMeterView.currentValue  = 101;
    self.fuelLevelMeterView.currentValue          = 73;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.coolantTemperatureMeterView setNeedsDisplay];
    [self.intakeTemperatureMeterView setNeedsDisplay];
    [self.fuelLevelMeterView setNeedsDisplay];
    [self.mpgMeterView setNeedsDisplay];
    [self.instantMPGMeterView setNeedsDisplay];
    [self.voltageMeterView setNeedsDisplay];
    [self.rangeMeterView setNeedsDisplay];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
