//
//  KeyStorage - Simplifying securely saving key information
//  KeyChainAccessGroupHelper.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//

import Foundation
import Security

/**
 
 Keychain utilities
 
 */
open class KeychainHelpers {

    /**
     Used to programmatically determine information related to Keychain Groups.
     
     - Returns: AccessGroupInfo? (optional) containing information related to the Keychain Group
     */
    public class func getAccessGroupInfo() -> KeyChainInfo.AccessGroupInfo? {
        let query: [String:Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : "detectAppIdentifierForKeyChainGroupIdUsage",
            kSecAttrAccessible as String: kSecAttrAccessibleAlwaysThisDeviceOnly,
            kSecReturnAttributes as String : kCFBooleanTrue
        ]
        
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        if status == errSecItemNotFound {
            let createStatus = SecItemAdd(query as CFDictionary, nil)
            guard createStatus == errSecSuccess else { return nil }
            status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        }
        
        guard status == errSecSuccess else { return nil }
        
        let accessGroup = ((dataTypeRef as! [AnyHashable: Any])[(kSecAttrAccessGroup as String)] as! String)
        
        if accessGroup.components(separatedBy: ".").count > 0 {
            let components = accessGroup.components(separatedBy: ".")
            let prefix = components.first!
            let elements = components.filter() { $0 != prefix }
            let keyChainGroup = elements.joined(separator: ".")
            
            return KeyChainInfo.AccessGroupInfo(prefix: prefix, keyChainGroup: keyChainGroup, rawValue: accessGroup)
        }
        
        return nil
    }
}
