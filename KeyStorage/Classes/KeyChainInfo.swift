//
//  KeyStorage - Simplifying securely saving key information
//  KeyChainInfo.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//

import Foundation
import Security

/**
 
 Contains information related to the Keychain
 
 */
public struct KeyChainInfo {
    
    /**
     
     Struct returned from getAccessGroupInfo with information related to the Keychain Group.
     
     */
    public struct AccessGroupInfo {
        
        /// App ID Prefix
        public var prefix: String
        
        /// Keycahin Group
        public var keyChainGroup: String
        
        /// Raw kSecAttrAccessGroup value returned from Keychain
        public var rawValue: String
    }
    
    /**
     
     Enum to used determine error details
     
     */
    public enum errorDetail: Error {
        /// No password provided or available
        case noPassword
        /// Incorrect data provided as part of the password return
        case unexpectedPasswordData
        /// Incorrect data provided for a non password Keychain item
        case unexpectedItemData
        /// Unknown error returned by keychain
        case unhandledError(status: OSStatus)
    }
    
    /**
     
     Enum to used map the accessibility of keychain items.
     
     For example, if whenUnlockedThisDeviceOnly the item data can
     only be accessed once the device has been unlocked after a restart.
     
     */
    public enum accessibleOption: RawRepresentable {
        case whenUnlocked,
        afterFirstUnlock,
        always,
        whenUnlockedThisDeviceOnly,
        afterFirstUnlockThisDeviceOnly,
        alwaysThisDeviceOnly,
        whenPasscodeSetThisDeviceOnly
        
        public init?(rawValue: String) {
            switch rawValue {
                
                /**
                 Item data can only be accessed
                 while the device is unlocked. This is recommended for items that only
                 need be accesible while the application is in the foreground.  Items
                 with this attribute will migrate to a new device when using encrypted
                 backups.
                 */
            case String(kSecAttrAccessibleWhenUnlocked):
                self = .whenUnlocked
                
                /**
                Item data can only be
                accessed once the device has been unlocked after a restart.  This is
                recommended for items that need to be accesible by background
                applications. Items with this attribute will migrate to a new device
                when using encrypted backups.
                */
            case String(kSecAttrAccessibleAfterFirstUnlock):
                self = .afterFirstUnlock

                /**
                Item data can always be accessed
                regardless of the lock state of the device.  This is not recommended
                for anything except system use. Items with this attribute will migrate
                to a new device when using encrypted backups.
                 */
            case String(kSecAttrAccessibleAlways):
                self = .always
                
                /**
                 Item data can only
                 be accessed while the device is unlocked. This is recommended for items
                 that only need be accesible while the application is in the foreground.
                 Items with this attribute will never migrate to a new device, so after
                 a backup is restored to a new device, these items will be missing.
                 */
            case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
                self = .whenUnlockedThisDeviceOnly
                
                /**
                 Item data can
                 only be accessed once the device has been unlocked after a restart.
                 This is recommended for items that need to be accessible by background
                 applications. Items with this attribute will never migrate to a new
                 device, so after a backup is restored to a new device these items will
                 be missing.
                 */
            case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
                self = .afterFirstUnlockThisDeviceOnly
                
                /**
                 Item data can always
                 be accessed regardless of the lock state of the device.  This option
                 is not recommended for anything except system use. Items with this
                 attribute will never migrate to a new device, so after a backup is
                 restored to a new device, these items will be missing.
                 */
            case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
                self = .alwaysThisDeviceOnly
                
                /**
                 Item data can
                 only be accessed while the device is unlocked. This class is only
                 available if a passcode is set on the device. This is recommended for
                 items that only need to be accessible while the application is in the
                 foreground. Items with this attribute will never migrate to a new
                 device, so after a backup is restored to a new device, these items
                 will be missing. No items can be stored in this class on devices
                 without a passcode. Disabling the device passcode will cause all
                 items in this class to be deleted.
                 */
            case String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly):
                self = .whenPasscodeSetThisDeviceOnly
            
            default:
                self = .afterFirstUnlockThisDeviceOnly
            }
        }
        
        /// Convert Enum to String Const
        public var rawValue: String {
            switch self {
            case .whenUnlocked:
                return String(kSecAttrAccessibleWhenUnlocked)
            case .afterFirstUnlock:
                return String(kSecAttrAccessibleAfterFirstUnlock)
            case .always:
                return String(kSecAttrAccessibleAlways)
            case .whenPasscodeSetThisDeviceOnly:
                return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
            case .whenUnlockedThisDeviceOnly:
                return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
            case .afterFirstUnlockThisDeviceOnly:
                return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
            case .alwaysThisDeviceOnly:
                return String(kSecAttrAccessibleAlwaysThisDeviceOnly)
            }
        }
    }
}
