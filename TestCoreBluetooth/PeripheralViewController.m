//
//  PeripheralViewController.m
//  TestCoreBluetooth
//
//  Created by FutureBoy on 1/19/16.
//  Copyright © 2016 QiuDong. All rights reserved.
//

#import "PeripheralViewController.h"
#import "CharacteristicViewController.h"

#pragma mark    Cell Content Views

@interface SummaryCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@property (nonatomic, strong) IBOutlet UILabel* uuidLabel;

@property (nonatomic, strong) IBOutlet UILabel* statusLabel;

@end

@implementation SummaryCell

@end

@interface PeripheralViewController () <CBPeripheralDelegate>
{
    NSDictionary<NSString *, id>* _advertisementData;
    NSArray<NSString*>* _advertisementDataKeys;
}
@end

@implementation PeripheralViewController

- (void) setAdvertisementData:(NSDictionary<NSString *,id> *)advertisementData {
    _advertisementData = advertisementData;
    NSEnumerator<NSString*>* enumerator = [_advertisementData keyEnumerator];
    _advertisementDataKeys = [enumerator allObjects];
}

#pragma mark    CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    NSLog(@"didDiscoverServices : %@, \nservices = %@, \nerror = %@", peripheral, peripheral.services, error);
    [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [peripheral discoverCharacteristics:nil forService:obj];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}
/*
 2015-12-29 18:57:48.738 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "System ID"
 2015-12-29 18:57:48.738 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "Model Number String"
 2015-12-29 18:57:48.739 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "Serial Number String"
 2015-12-29 18:57:48.740 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "Firmware Revision String"
 2015-12-29 18:57:48.740 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "Hardware Revision String"
 2015-12-29 18:57:48.740 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "Software Revision String"
 2015-12-29 18:57:48.743 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "Manufacturer Name String"
 2015-12-29 18:57:48.744 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "IEEE Regulatory Certification"
 2015-12-29 18:57:48.750 TestCoreBluetooth[10001:3264004] CBCharacteristic.UUID = "PnP ID"
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    NSLog(@"didDiscoverCharacteristicsForService : %@,\nservice = %@,\ncharacteristics = %@,\nerror = %@", peripheral,service,service.characteristics,error);
    [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"CBCharacteristic.UUID = \"%@\"", obj.UUID);
        //        if ([obj.UUID.description isEqualToString:@"System ID"])
        {
            if (obj.properties & CBCharacteristicPropertyRead)
            {
                [peripheral readValueForCharacteristic:obj];
            }
            
            if (obj.properties & CBCharacteristicPropertyNotify)
            {
                [peripheral setNotifyValue:YES forCharacteristic:obj];
            }
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    //    if ([characteristic.UUID.description isEqualToString:@"Hardware Revision String"])
    {
        NSString* valueStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Value of %@ is : %@", characteristic.UUID, valueStr);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

#pragma mark    UIEvents

- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidLoad {
    [super viewDidLoad];
//    self.peripheral.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:nil];
}

#pragma mark    UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.peripheral.services.count + 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 84;
    else
    {
        CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
        return height;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return self.advertisementData.count;
    }
    else
    {
        CBService* service = [self.peripheral.services objectAtIndex:section-2];
        return service.characteristics.count;
    }
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1)
    {
        UITableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
        headerCell.textLabel.text = @"Advertisement Datas";
        headerCell.detailTextLabel.text = @"Show";
        return headerCell;
    }
    else if (section > 1)
    {
        UITableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
        CBService* service = [self.peripheral.services objectAtIndex:section - 2];
        headerCell.textLabel.text = [service.UUID description];
        return headerCell;
    }
    else
        return nil;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            SummaryCell* summaryCell = [tableView dequeueReusableCellWithIdentifier:@"Summary"];
            cell = summaryCell;
            
            summaryCell.nameLabel.text = self.peripheral.name;
            switch (self.peripheral.state) {
                case CBPeripheralStateConnected:
                    summaryCell.statusLabel.text = @"Connected";
                    break;
                case CBPeripheralStateDisconnected:
                    summaryCell.statusLabel.text = @"Disconnected";
                    break;
                case CBPeripheralStateConnecting:
                    summaryCell.statusLabel.text = @"Connecting";
                    break;
                case CBPeripheralStateDisconnecting:
                    summaryCell.statusLabel.text = @"Disconnecting";
                    break;
                    
                default:
                    break;
            }
            
            CBUUID* cbUUID = [CBUUID UUIDWithNSUUID:self.peripheral.identifier];
            summaryCell.uuidLabel.text = [cbUUID description];
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Item"];
            NSString* key = [_advertisementDataKeys objectAtIndex:indexPath.row];
            id data = [self.advertisementData objectForKey:key];
            cell.detailTextLabel.text = key;
            if ([data isKindOfClass:NSArray.class])
            {
                cell.textLabel.text = [data[0] description];;
            }
            else if ([data isKindOfClass:NSData.class])
            {
                NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                cell.textLabel.text = str;
            }
            else
            {
                cell.textLabel.text = [data description];
            }
        }
            break;
        default:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Item"];
            CBService* service = [self.peripheral.services objectAtIndex:indexPath.section - 2];
            CBCharacteristic* character = [service.characteristics objectAtIndex:indexPath.row];
            
            NSMutableString* propertyStr = [[NSMutableString alloc] init];
            if (character.properties & CBCharacteristicPropertyRead)
                [propertyStr appendString:@"Read "];
            if (character.properties & CBCharacteristicPropertyWrite)
                [propertyStr appendString:@"Write "];
            if (character.properties & CBCharacteristicPropertyNotify)
                [propertyStr appendString:@"Notify "];
            if (character.properties & CBCharacteristicPropertyBroadcast)
                [propertyStr appendString:@"Broadcast "];
            cell.detailTextLabel.text = propertyStr;
        }
            break;
    }
    return cell;
}

#pragma mark    UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 1)
    {
        [self performSegueWithIdentifier:@"gotoCharacteristic" sender:self];
    }
}

#pragma mark    Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    CBService* service = [self.peripheral.services objectAtIndex:indexPath.section - 2];
    CBCharacteristic* character = [service.characteristics objectAtIndex:indexPath.row];
    
    CharacteristicViewController* destVC = segue.destinationViewController;
    destVC.characteristic = character;
    self.peripheral.delegate = destVC;
}

@end
