//
//  AppleDevice.swift
//  Queen-IOKit
//
//  Created by Cookie on 6/1/24.
//

import Foundation
import USBDeviceSwift

// Apple-specific VID
let APPLE_VID: UInt16 = 0x5ac

// PIDs for various device state
enum DeviceMode: UInt16 {
    case Dfu    = 0x1227
    case Normal = 0x12a8
    case Pongo  = 0x4141
}

// bmRequestType
enum RequestType: UInt8 {
    case DeviceToHost = 0x80
    case HostToDevice = 0x21
}

// bRequest
enum RequestCode: UInt8 {
    case GET_STATUS         = 0x00
    case CLEAR_FEATURE      = 0x01
    case SET_FEATURE        = 0x03
    case SET_ADDRESS        = 0x05
    case GET_DESCRIPTOR     = 0x06
    case SET_DESCRIPTOR     = 0x07
    case GET_CONFIGURATION  = 0x08
    case SET_CONFIGURATION  = 0x09
}

enum AppleDeviceError: Error {
    case DeviceInterfaceNotFound
    case InvalidData(desc:String)
    case RequestError(desc:String)
}

class AppleDevice {
    let deviceInfo: USBDevice
    
    init(with deviceInfo: USBDevice) {
        self.deviceInfo = deviceInfo
    }
    
    func getStatus() throws -> [UInt8] {
        guard let interface = self.deviceInfo.deviceInterfacePtrPtr?.pointee?.pointee else {
            throw AppleDeviceError.DeviceInterfaceNotFound
        }
        
        var kr: Int32 = 0
        var length: Int = 6
        var requestPtr = [UInt8](repeating: 0, count: length)
        var request = IOUSBDevRequest(bmRequestType: RequestType.DeviceToHost.rawValue,
                                      bRequest: 0,
                                      wValue: 0,
                                      wIndex: 0,
                                      wLength: UInt16(length),
                                      pData: &requestPtr,
                                      wLenDone: 255)
        
        kr = interface.DeviceRequest(self.deviceInfo.deviceInterfacePtrPtr, &request)
        
        if (kr != kIOReturnSuccess) {
            throw AppleDeviceError.RequestError(desc: "Unable to read data:\n\(request)")
        }
        
        return requestPtr
    }
}

class NormalDevice: AppleDevice {
    override init(with deviceInfo: USBDevice) {
        super.init(with: deviceInfo)
    }
}
