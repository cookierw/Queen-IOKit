//
//  AppDelegate.swift
//  Queen-IOKit
//
//  Created by Cookie on 5/31/24.
//

import Cocoa
import USBDeviceSwift

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let usbDeviceMonitor = USBDeviceMonitor([
        USBMonitorData(vendorId: APPLE_VID, productId: DeviceMode.Normal.rawValue),
        USBMonitorData(vendorId: APPLE_VID, productId: DeviceMode.Dfu.rawValue),
        USBMonitorData(vendorId: APPLE_VID, productId: DeviceMode.Pongo.rawValue)
    ])
    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let usbDeviceDaemon = Thread(target: self.usbDeviceMonitor, selector: #selector(self.usbDeviceMonitor.start), object: nil)
        usbDeviceDaemon.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

