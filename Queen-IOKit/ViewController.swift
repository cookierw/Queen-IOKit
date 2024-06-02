//
//  ViewController.swift
//  Queen-IOKit
//
//  Created by Cookie on 5/31/24.
//

import Cocoa
import USBDeviceSwift

class ViewController: NSViewController {
    var connectedDevice: AppleDevice?
    var exploitConfig: Exploit? = nil

    @IBOutlet weak var deviceInfoLabel: NSTextField!
    
    @IBOutlet weak var runButton: NSButton!
    
    @IBOutlet weak var progressTextView: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: Notification.Name.USBDeviceConnected, object: nil)
        
        if let connectedDevice {
            deviceInfoLabel.stringValue = connectedDevice.deviceInfo.name
        } else {
            deviceInfoLabel.stringValue = "Connect device to continue"
        }
        
        runButton.isEnabled = exploitConfig != nil
        runButton.action = #selector(exploitConfig?.run)
        
        progressTextView.stringValue = "Configure and click \"Run\""
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func usbConnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }

        guard let deviceInfo:USBDevice = nobj["device"] as? USBDevice else {
            return
        }
        
        DispatchQueue.main.async {
            switch deviceInfo.productId {
                case DeviceMode.Dfu.rawValue:
                    self.connectedDevice = DfuDevice(with: deviceInfo)
                default:
                    self.connectedDevice = NormalDevice(with: deviceInfo)
            }
            
            self.deviceInfoLabel.stringValue = deviceInfo.name
        }
    }
}

