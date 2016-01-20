//
//  CharacteristicViewController.h
//  TestCoreBluetooth
//
//  Created by FutureBoy on 1/20/16.
//  Copyright © 2016 QiuDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CharacteristicViewController : UIViewController <CBPeripheralDelegate>

@property (nonatomic, strong) CBCharacteristic* characteristic;

@property (nonatomic, strong) IBOutlet UITextField* txfWriteValue;
@property (nonatomic, strong) IBOutlet UIButton* btnSetNotified;
@property (nonatomic, strong) IBOutlet UILabel* lblReadValue;

- (IBAction)onWriteButtonPressed:(id)sender;
- (IBAction)onReadButtonPressed:(id)sender;
- (IBAction)onSetNotifiedButtonPressed:(id)sender;

@end
