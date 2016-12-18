//
//  KeyStorage - Simplifying securely saving key information
//  KeyStorageCrypter.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//


import Foundation

public protocol KeyStorageCrypter {
    func encrypt(data: Data, forKey: String) -> Data
    func decrypt(data: Data, forKey: String) -> Data
}
