//
//  PeripheralViewController.h
//  TestCoreBluetooth
//
//  Created by FutureBoy on 1/19/16.
//  Copyright © 2016 QiuDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralViewController : UITableViewController

@property (nonatomic, strong) CBPeripheral* peripheral;
@property (nonatomic, strong) NSDictionary<NSString *, id>* advertisementData;

- (IBAction)onBackPressed:(id)sender;

@end
