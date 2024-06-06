//
//  StringProtocol+Queen.swift
//  Queen-IOKit
//
//  Created by Cookie on 6/2/24.
//  adapted from https://gist.github.com/suguru/19f3117a763f176ae39d

import Foundation


extension StringProtocol {
    func asHexBytes() -> [UInt8] {
        var startIndex = self.startIndex
        
        if count % 2 != 0 {
            // length should be divided by 2
            // TODO: should throw?
            return []
        }
        
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
