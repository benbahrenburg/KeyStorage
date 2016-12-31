//
//  KeyStorage - Simplifying securely saving key information
//  KeyStorageCrypter.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//


import Foundation

/**
 
 Protocol used to enforce the contract for encrypting and decrypting storage values.
 
 You can provide your own encrypt/decrypt functionality to any of the Storage Providers as long as it conforms to this protocol.
 
 */
public protocol KeyStorageCrypter {
    /**
     Returns an encrypted Data type.
     
     - Parameter forKey: The key for the data element that should be encrypted.
     - Parameter data: The Data that should be encrypted
     - Returns: The Data in encrypted form. This will be persisted by the Storage Provider.
     */
    func encrypt(data: Data, forKey: String) -> Data
    
    /**
     Returns an unencrypted Data type
     
     - Parameter forKey: The key for the data element that should be decrypted.
     - Parameter data: The Data that should be decrypted
     - Returns: The Data in decrypted form. This will be converted to one of the supported types and returned to the caller.
     */
    func decrypt(data: Data, forKey: String) -> Data
}
