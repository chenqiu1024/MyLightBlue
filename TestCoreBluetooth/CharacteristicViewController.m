//
//  CharacteristicViewController.m
//  TestCoreBluetooth
//
//  Created by FutureBoy on 1/20/16.
//  Copyright © 2016 QiuDong. All rights reserved.
//

#import "CharacteristicViewController.h"

NSData* dataWithHexString(NSString* hexString) {
    const char* cstr = [hexString UTF8String];
    int length = (int) hexString.length;
    int dataLength = (length + 1) / 2;
    
    uint8_t* hexData = (uint8_t*) malloc(dataLength);
    memset(hexData, 0, dataLength);
    
    bool highHalfByte = false;
    uint8_t* pDst = hexData + dataLength - 1;
    for (int i=length-1; i>=0; i--)
    {
        char c = cstr[i];
        uint8_t halfByte = 0;
        if (c >= '0' && c <= '9')
            halfByte = c - '0';
        else if (c >= 'a' && c <= 'f')
            halfByte = c - 'a' + 10;
        else if (c >= 'A' && c <= 'F')
            halfByte = c - 'A' + 10;
        
        if (highHalfByte)
        {
            *pDst-- |= ((halfByte << 4) & 0xf0);
            highHalfByte = false;
        }
        else
        {
            *pDst |= (halfByte & 0x0f);
            highHalfByte = true;
        }
    }
    
    return [NSData dataWithBytes:hexData length:dataLength];
}


@implementation CharacteristicViewController

@synthesize characteristic;

- (IBAction)onReadButtonPressed:(id)sender {
    [self.characteristic.service.peripheral readValueForCharacteristic:self.characteristic];
}

- (IBAction)onWriteButtonPressed:(id)sender {
    NSData* data = dataWithHexString(self.txfWriteValue.text);//[self.txfWriteValue.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.characteristic.service.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (IBAction)onSetNotifiedButtonPressed:(id)sender {
    if (self.btnSetNotified.tag == 0)
    {
        [self.characteristic.service.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        [self.btnSetNotified setTitle:@"Unset Notified" forState:UIControlStateNormal];
        self.btnSetNotified.tag = 1;
    }
    else
    {
        [self.characteristic.service.peripheral setNotifyValue:NO forCharacteristic:self.characteristic];
        [self.btnSetNotified setTitle:@"Set Notified" forState:UIControlStateNormal];
        self.btnSetNotified.tag = 0;
    }
}

#pragma mark    CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)character error:(nullable NSError *)error {
    NSString* valueStr = [[NSString alloc] initWithData:character.value encoding:NSUTF8StringEncoding];
    NSLog(@"didUpdateValueForCharacteristic : Value of %@ is : %@", character.UUID, valueStr);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblReadValue.text = valueStr;
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)character error:(nullable NSError *)error {
    NSLog(@"didWriteValueForCharacteristic : %@", character);
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)character error:(nullable NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic : %@", character);
}

@end
