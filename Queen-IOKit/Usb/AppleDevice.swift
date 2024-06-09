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
    
    // uint8_t bm_request_type, uint8_t b_request, uint16_t w_value,
    // uint16_t w_index, void *p_data, size_t w_len, transfer_ret_t *transfer_ret
    func sendCtrlRequest(
        bmRequestType: UInt8, bRequest: UInt8, wValue: UInt16, wIndex: UInt16,
        wLength: UInt16, data: UnsafeMutablePointer<UInt8>, timeout: UInt32
    ) throws -> UInt32 {
        guard let interface = self.deviceInfo.deviceInterfacePtrPtr?.pointee?.pointee else {
            throw AppleDeviceError.DeviceInterfaceNotFound
        }
        
        var kr: Int32 = 0
        var wLenDone: UInt32 = 0
        
        var request = IOUSBDevRequestTO(bmRequestType: bmRequestType,
                                        bRequest: bRequest,
                                        wValue: wValue,
                                        wIndex: wIndex,
                                        wLength: wLength,
                                        pData: data,
                                        wLenDone: wLenDone,
                                        noDataTimeout: timeout,
                                        completionTimeout: timeout)
        
        kr = interface.DeviceRequestTO(self.deviceInfo.deviceInterfacePtrPtr, &request)
        
        if (kr != kIOReturnSuccess) {
            throw AppleDeviceError.RequestError(desc: "Unable to read data:\n\(request)")
        }
        
        return wLenDone
    }
    
    let usbAsyncCallback: IOAsyncCallback1 = { refcon, result, arg0 in
        if let arg = arg0 {
            arg.storeBytes(of: 1, as: Int.self)
        }
        
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
    
    // uint8_t bm_request_type, uint8_t b_request, uint16_t w_value,
    // uint16_t w_index, void *p_data, size_t w_len, unsigned usb_abort_timeout, transfer_ret_t *transfer_ret
    func sendCtrlRequestAsync(
        bmRequestType: UInt8, bRequest: UInt8, wValue: UInt16, wIndex: UInt16,
        wLength: UInt16, data: UnsafeMutablePointer<UInt8>, timeout: UInt32
    ) throws -> Bool {
        guard let interface = self.deviceInfo.deviceInterfacePtrPtr?.pointee?.pointee else {
            throw AppleDeviceError.DeviceInterfaceNotFound
        }
        
        var kr: Int32 = 0
        var wLenDone: UInt32 = 0
        var cbData: Int = 0
        
        var request = IOUSBDevRequestTO(bmRequestType: bmRequestType,
                                        bRequest: bRequest,
                                        wValue: wValue,
                                        wIndex: wIndex,
                                        wLength: wLength,
                                        pData: data,
                                        wLenDone: wLenDone,
                                        noDataTimeout: timeout,
                                        completionTimeout: timeout)
        
        kr = interface.DeviceRequestAsyncTO(self.deviceInfo.deviceInterfacePtrPtr, &request, usbAsyncCallback, &cbData)
        
        if kr == kIOReturnSuccess {
            Thread.sleep(forTimeInterval: Double(timeout)/1000)
            kr = interface.USBDeviceAbortPipeZero(self.deviceInfo.deviceInterfacePtrPtr)
            
            if kr == kIOReturnSuccess {
                CFRunLoopRun()
                return true
            }
        }
        
        return false
    }
}

class NormalDevice: AppleDevice {
    override init(with deviceInfo: USBDevice) {
        super.init(with: deviceInfo)
    }
}
