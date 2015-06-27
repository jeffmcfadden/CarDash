//
//  FASettingsViewController.m
//  CarDash
//
//  Created by Jeff McFadden on 7/12/14.
//  Copyright (c) 2015 Jeff McFadden. All rights reserved.
//

#import "FASettingsViewController.h"

@interface FASettingsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@end

@implementation FASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.statusLabel.text = @"Waiting For Data";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pidDataDidUpdate:) name:kFAOBD2PIDDataUpdatedNotification object:nil];
}

- (void)pidDataDidUpdate:(NSNotification *)notification
{
    self.statusLabel.text = @"Receiving Data";
}

- (IBAction)start:(id)sender
{
    self.statusLabel.text = @"Starting";
    [[FAOBD2Communicator sharedInstance] startStreaming];
}

- (IBAction)stop:(id)sender
{
    [[FAOBD2Communicator sharedInstance] stop];
    self.statusLabel.text = @"Stopped";
}

- (IBAction)restart:(id)sender
{
    self.statusLabel.text = @"Restarting";
    [[FAOBD2Communicator sharedInstance] restart];
}

- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startDemo:(id)sender
{
    self.statusLabel.text = @"Starting Demo";
    [[FAOBD2Communicator sharedInstance] startDemo];
}

- (IBAction)stopDemo:(id)sender
{
    [[FAOBD2Communicator sharedInstance] stopDemo];
    self.statusLabel.text = @"Stopped Demo";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
