//
//  ViewController.m
//  TestCoreBluetooth
//
//  Created by QiuDong on 15/12/29.
//  Copyright © 2015年 QiuDong. All rights reserved.
//

#import "ViewController.h"
#import "PeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString* const CellIdentifier = @"CellIdentifier";

@interface ViewController () <CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CBCentralManager* centralManager;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableDictionary<NSString*, id>* peripherals;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSDictionary*>* advertisementDatas;

@property (nonatomic, strong) NSArray* dataSource;

@end

@implementation ViewController

- (NSUUID*) myPeripheralUUID {
    static NSString* const MyPeripheralUUID = @"FA2E185C-FABF-41BE-91D7-146B21343294";
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:MyPeripheralUUID];
    return uuid;
}

- (CBUUID*) myServiceUUID {
    static NSString* const MyServiceUUID = @"B8E0EA0E-C1AF-4316-9327-6BAB246594E7";
    CBUUID* cbUUID = [CBUUID UUIDWithString:MyServiceUUID];
    return cbUUID;
}

- (void) refreshList {
    NSArray* sortedKeys = nil;
    @synchronized(self) {
        sortedKeys = [self.peripherals keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            CBPeripheral* p1 = obj1;
            CBPeripheral* p2 = obj2;
            return [p1.identifier.UUIDString compare:p2.identifier.UUIDString];
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataSource = [self.peripherals objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
        //        self.dataSource = [[self.peripherals objectEnumerator] allObjects];
        
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
    self.peripherals = [[NSMutableDictionary alloc] init];
    self.advertisementDatas = [[NSMutableDictionary alloc] init];
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:@{CBCentralManagerOptionShowPowerAlertKey:@(YES)}];
    
//    NSArray<CBPeripheral*>* knownPeripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[[self myPeripheralUUID]]];
//    if (!knownPeripherals)
//    {
//        NSArray<CBPeripheral*>* connectedPeripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:@[[self myServiceUUID]]];
//        if (connectedPeripherals)
//        {
//            [connectedPeripherals enumerateObjectsUsingBlock:^(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [self.peripherals setObject:obj forKey:obj.identifier.UUIDString];
//            }];
//        }
//    }
//    else
//    {
//        [knownPeripherals enumerateObjectsUsingBlock:^(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self.peripherals setObject:obj forKey:obj.identifier.UUIDString];
//        }];
//    }
    
//    if (self.dataSource.count == 0)
//    {
//        [self.centralManager scanForPeripheralsWithServices:nil/*@[[self myServiceUUID]]*/ options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];///!!!NO
//    }
//    else
    {
        [self refreshList];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark    CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"central : %@", central);
    switch (central.state)
    {
        case CBCentralManagerStateUnknown:
        {
            NSLog(@"central.state = CBCentralManagerStateUnknown");
        }
            break;
        case CBCentralManagerStateResetting:
        {
            NSLog(@"central.state = CBCentralManagerStateResetting");
        }
            break;
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"central.state = CBCentralManagerStateUnsupported");
        }
            break;
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"central.state = CBCentralManagerStateUnauthorized");
        }
            break;
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"central.state = CBCentralManagerStatePoweredOff");
        }
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"central.state = CBCentralManagerStatePoweredOn");
            
            NSArray<CBPeripheral*>* knownPeripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[[self myPeripheralUUID]]];
            if (!knownPeripherals)
            {
                NSArray<CBPeripheral*>* connectedPeripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:@[[self myServiceUUID]]];
                if (connectedPeripherals)
                {
                    [connectedPeripherals enumerateObjectsUsingBlock:^(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [self.peripherals setObject:obj forKey:obj.identifier.UUIDString];
                    }];
                }
            }
            else
            {
                [knownPeripherals enumerateObjectsUsingBlock:^(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.peripherals setObject:obj forKey:obj.identifier.UUIDString];
                }];
            }
            
            [self.centralManager scanForPeripheralsWithServices:nil/*@[[self myServiceUUID]]*/ options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];///!!!NO
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    NSLog(@"willRestoreState : %@", dict);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
//    NSLog(@"didDiscoverPeripheral : %@", peripheral);
    
    [self.peripherals setObject:peripheral forKey:peripheral.identifier.UUIDString];
    [self.advertisementDatas setObject:advertisementData forKey:peripheral.identifier.UUIDString];
    
    [self refreshList];
    
    if ([peripheral.name isEqualToString:@"Madv360 Camera"])
    {
//        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@(NO), CBConnectPeripheralOptionNotifyOnConnectionKey:@(NO), CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(NO)}];
//        [self.centralManager stopScan];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral : %@", peripheral);
//    peripheral.delegate = self;
//    [peripheral discoverServices:nil];//@[[self myServiceUUID]]];
    
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [wSelf showPeripheral:peripheral];
    });
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"didFailToConnectPeripheral : %@, error = %@", peripheral, error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"didDisconnectPeripheral : %@, error = %@", peripheral, error);
}

#pragma mark    UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    CBPeripheral* peripheral = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", peripheral.name, peripheral.identifier.UUIDString];
    
    return cell;
}

#pragma mark    UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.centralManager stopScan];
    
    CBPeripheral* peripheral = [self.dataSource objectAtIndex:indexPath.row];
    switch(peripheral.state)
    {
        case CBPeripheralStateDisconnected:
        {
            NSLog(@"Selected peripheral.state = CBPeripheralStateDisconnected");
            [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@(NO)}];
//            [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@(NO), CBConnectPeripheralOptionNotifyOnConnectionKey:@(NO), CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(NO)}];
        }
            break;
        case CBPeripheralStateDisconnecting:
        {
            NSLog(@"Selected peripheral.state = CBPeripheralStateDisconnecting");
        }
            break;
        case CBPeripheralStateConnected:
        {
            NSLog(@"Selected peripheral.state = CBPeripheralStateConnected");

            [self showPeripheral:peripheral];
        }
            break;
        case CBPeripheralStateConnecting:
        {
            NSLog(@"Selected peripheral.state = CBPeripheralStateConnecting");
        }
            break;
    }
    
}

#pragma mark    Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    CBPeripheral* peripheral = [self.dataSource objectAtIndex:indexPath.row];
    PeripheralViewController* destVC = segue.destinationViewController;
    destVC.peripheral = peripheral;
    destVC.advertisementData = self.advertisementDatas[peripheral.identifier.UUIDString];
}

- (void) showPeripheral:(CBPeripheral*)peripheral {
    [self performSegueWithIdentifier:@"fetchServices" sender:self];
}

@end
