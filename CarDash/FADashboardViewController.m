//
//  FAMPGViewController.m
//  CarDash
//
//  Created by Jeff McFadden on 7/12/14.
//  Copyright (c) 2014 ForgeApps. All rights reserved.
//

#import "FADashboardViewController.h"

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

@property (nonatomic) NSMutableArray *mpgHistory;
@property (nonatomic) NSMutableArray *mpgLongHistory;

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
    self.gph = 0;
    
    self.mpgHistory = [@[] mutableCopy];
    self.mpgLongHistory = [@[] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pidDataDidUpdate:) name:kFAOBD2PIDDataUpdatedNotification object:nil];
}

- (void)pidDataDidUpdate:(NSNotification *)notification
{
    NSLog( @"%@", notification );
    NSLog( @"%@", notification.object );
    
    if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDFuelFlow]) {
        self.gph = [notification.object[@"value"] doubleValue];
    }else if ([notification.object[@"sensor"] isEqualToString:kFAOBD2PIDVehicleSpeed]){
        self.mph = [notification.object[@"value"] doubleValue];
    }
    
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

    
    [self updateLabels];
}

- (void)updateLabels
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.gphLabel.text = [NSString stringWithFormat:@"%0.2f", self.gph];
        self.mphLabel.text = [NSString stringWithFormat:@"%0.2f", self.mph];
        self.mpgLabel.text = [NSString stringWithFormat:@"%.0f", self.mpgLongAvg];
        self.mpgShortLabel.text = [NSString stringWithFormat:@"%.0f", self.mpgAvg];
        
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
