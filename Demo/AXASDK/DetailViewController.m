//
//  DetailViewController.m
//  AXASDK
//
//  Created by AXAET_APPLE on 15/7/15.
//  Copyright (c) 2015年 axaet. All rights reserved.
//

#import "DetailViewController.h"
/**
 *  import the CoreBluetooth
 */
#import <CoreBluetooth/CoreBluetooth.h>

/**
 *  add the code Comply wtih the CBPeripheralDelegate protocol
 */
@interface DetailViewController () <AXATagManagerDelegate, UITextFieldDelegate, UIAlertViewDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) UITextField *uuidTextField;
@property (nonatomic, strong) UITextField *majorTextField;
@property (nonatomic, strong) UITextField *minorTextField;
@property (nonatomic, strong) UITextField *powerTextField;
@property (nonatomic, strong) UITextField *advInteralTextField;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *pswTextField;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UIButton *modifyBtn;

/**
 *  retain the connected peripheral
 */
@property (nonatomic, strong) CBPeripheral *activePeripheral;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"connecting";
    [AXABeaconManager sharedManager].tagDelegate = self;
    [[AXABeaconManager sharedManager] connectBleDevice:self.beacon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detail"];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
    
    
    
    switch (indexPath.section) {
        case 0:
            [cell.contentView addSubview:textField];
            textField.text = self.beacon.proximityUUID;
            self.uuidTextField = textField;
            self.uuidTextField.delegate = self;
            
            break;
        case 1:
            [cell.contentView addSubview:textField];
            textField.text = self.beacon.major;
            self.majorTextField = textField;
            self.majorTextField.delegate = self;
            
            break;
        case 2:
            [cell.contentView addSubview:textField];
            textField.text = self.beacon.minor;
            self.minorTextField = textField;
            self.minorTextField.delegate = self;
            
            break;
        case 3:
            [cell.contentView addSubview:textField];
            textField.text = self.beacon.power;
            self.powerTextField = textField;
            self.powerTextField.delegate = self;
            
            break;
        case 4:
            [cell.contentView addSubview:textField];
            textField.text = self.beacon.advInterval;
            self.advInteralTextField = textField;
            self.advInteralTextField.delegate = self;
            
            break;
        case 5:
            [cell.contentView addSubview:textField];
            textField.text = self.beacon.name;
            self.nameTextField = textField;
            self.nameTextField.delegate = self;
            
            break;
        case 6:
            [cell.contentView addSubview:textField];
            self.pswTextField = textField;
            self.pswTextField.delegate = self;
            
            break;
        case 7:
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
            button.tag = 0;
            [button addTarget:self action:@selector(handleWriteAndReset:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor blueColor];
            [button setTitle:@"reset device" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:button];
            self.resetBtn = button;
        }
            
            break;
        case 8:
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(cell.contentView.frame) - 40, CGRectGetHeight(cell.contentView.frame))];
            button.tag = 1;
            [button addTarget:self action:@selector(handleWriteAndReset:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor blueColor];
            [button setTitle:@"modify password" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:button];
            self.modifyBtn = button;
        }
            
            break;
            
        default:
            break;
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"proximityUUID";
            break;
        case 1:
            return @"major (0 ~ 65565)";
            break;
        case 2:
            return @"minor (0 ~ 65565)";
            break;
        case 3:
            return @"power (can be 0(0dbm) 1(-6dbm) 2(-23dbm))";
            break;
        case 4:
            return @"advInterval (100 ~ 10000)";
            break;
        case 5:
            return @"name";
            break;
        case 6:
            return @"password(pBeacon_n must add password, ibeacon not need)";
            break;
        case 7:
            return @"write value and reset";
            break;
        case 8:
            return @"modify password 123456 to 456789";
            break;
            
            
        default:
            return @"write value and reset";
            break;
    }
    return nil;
}



#pragma mark - tag delegate

/**
 * did connected beacon
 */
- (void)didConnectBeacon:(AXABeacon *)beacon {
    NSLog(@"%@", beacon.name);
    self.navigationItem.title = @"connected";


    /**
     *  get the connected peripheral and set the delegate to current viewController
     */
    self.activePeripheral = beacon.peripheral;
    self.activePeripheral.delegate = self;
    /**
     * make a timer to scheduled timer with a time interval to read RSSI
     * @see twoSecondRead
     * you can change the value of Time Interval what you want.
     */
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(twoSecondRead) userInfo:nil repeats:YES];
}

- (void)didDiscoverBeacon:(AXABeacon *)beacon {
    
    if ([beacon.peripheral isEqual:self.activePeripheral]) {
        NSLog(@"beacon.rssi == %@", beacon.rssi);
    }
}

- (void)didDisconnectBeacon:(AXABeacon *)beacon {
    NSLog(@"%@", beacon.name);
    self.navigationItem.title = @"connected";
}

- (void)didGetProximityUUIDForBeacon:(AXABeacon *)beacon {
    NSLog(@"uuid: %@", beacon.proximityUUID);
    self.beacon.proximityUUID = beacon.proximityUUID;
    [self.tableView reloadData];
}

- (void)didGetMajorMinorPowerAdvInterval:(AXABeacon *)beacon {
    NSLog(@"major: %@ minor: %@ power: %@ advInterval: %@", beacon.major, beacon.minor, beacon.power, beacon.advInterval);
    self.beacon.major = beacon.major;
    self.beacon.minor = beacon.minor;
    self.beacon.power = beacon.power;
    self.beacon.advInterval = beacon.advInterval;
    [self.tableView reloadData];
}

- (void)didWritePassword:(BOOL)correct {
    NSLog(@"%d", correct);
    if (correct) {
        [[AXABeaconManager sharedManager] writeProximityUUID:self.uuidTextField.text];
        [[AXABeaconManager sharedManager] writeMajor:self.majorTextField.text withMinor:self.minorTextField.text withPower:self.powerTextField.text withAdvInterval:self.advInteralTextField.text];
        [[AXABeaconManager sharedManager] resetDevice];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"password is wrong" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [[AXABeaconManager sharedManager] disconnectBleDevice:self.beacon];
    }
}

- (void)didModifyPasswordRight {
    [[AXABeaconManager sharedManager] resetDevice];
}

#pragma mark - private

- (void)handleWriteAndReset:(UIButton *)sender {
    if (sender.tag) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"modify password" message:@"password will change password 123456 to 456789" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        if ([self.resetBtn.backgroundColor isEqual:[UIColor blueColor]]) {
            self.resetBtn.backgroundColor = [UIColor greenColor];
        } else {
            self.resetBtn.backgroundColor = [UIColor blueColor];
        }
        
        [[AXABeaconManager sharedManager] writePassword:self.pswTextField.text];
    }
    
}

#pragma mark - textField delegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[AXABeaconManager sharedManager] writeModifyPassword:@"123456" newPSW:@"456789"];
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


/**
 *  read RSSI
 */
-(void)twoSecondRead {
    if (self.activePeripheral == nil) {
        return;
    }
    if (self.activePeripheral.state == CBPeripheralStateConnected) {
        [self.activePeripheral readRSSI];
    }
}

/*!
 *  @method peripheral:didReadRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *  @param RSSI			The current RSSI of the link.
 *  @param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"%s", __func__);
    NSLog(@"RSSI --- %@", RSSI);

}

@end
