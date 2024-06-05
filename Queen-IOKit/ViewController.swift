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
    var exploitConfig: ExploitConfig? = nil
    var exploitService: Exploit? = nil

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
        
//        runButton.isEnabled = exploitService != nil
        runButton.action = #selector(self.runExploit)
        
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
    
    @objc func runExploit() {
        guard var connectedDevice = self.connectedDevice as? DfuDevice else {
            DispatchQueue.main.async {
                self.progressTextView.stringValue = "No DFU device connected"
            }
            return
        }
        
        self.exploitService = Checkm8(dfu: &connectedDevice)
        
        guard let exploitService = self.exploitService else {
            print("could not unwrap exploitService")
            return
        }
        
        guard exploitService.configure() else {
            print("error in exploitService.configure()")
            return
        }
        
        guard exploitService.run() else {
            print("error in exploitService.run()")
            return
        }
    }
}

