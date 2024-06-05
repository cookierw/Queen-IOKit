//
//  Queen_IOKitTests.swift
//  Queen-IOKitTests
//
//  Created by Cookie on 6/4/24.
//

import XCTest
@testable import Queen_IOKit
import USBDeviceSwift

// Arrange, Act, Assert
final class Queen_IOKitTests: XCTestCase {
    var usbDevice: USBDevice {
        return USBDevice(
            id: 0x1,
            vendorId: 0xbeef,
            productId: 0xcafe,
            name: "test",
            deviceInterfacePtrPtr: nil,
            plugInInterfacePtrPtr: nil
        )
    }
    
    static let expectedBranchBytes: [UInt8] = [
        // branch(0x10, 0x0):
        // b'\xfc\xff\xff\x17'
        0xFC, 0xFF, 0xFF, 0x17
    ]
    
    static let expectedTrampBytes: [UInt8] = [
        // tramp(0x18000C000):
        // b'\x47\x00\x00X\xe0\x00\x1f\xd6\x00\xc0\x00\x80\x01\x00\x00\x00'
        0x47, 0x00, 0x00, 0x58, 0xE0, 0x00, 0x1F, 0xD6, 0x00, 0xC0, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
    ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func textExploitConfig() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//        var dfuDevice = DfuDevice(with: usbDevice)
        let config = try ExploitConfig(withCpid: 0x8015)
        
        let branch = try config.asmArm64Branch(source: 0x10, destination: 0x0)
        let tramp = try config.asmArm64X7Trampoline(address: 0x18000C000)
        
        assert(branch == Queen_IOKitTests.expectedBranchBytes)
        assert(tramp == Queen_IOKitTests.expectedTrampBytes)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

