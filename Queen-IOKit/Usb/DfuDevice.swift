//
//  DfuDevice.swift
//  Queen-IOKit
//
//  Created by Cookie on 6/1/24.
//

import Foundation
import USBDeviceSwift

class DfuDevice: AppleDevice {
    override init(with deviceInfo: USBDevice) {
        super.init(with: deviceInfo)
    }
    
    func write(data: [UInt8]) -> Bool {
        
        
        return true
    }
    
    
}
