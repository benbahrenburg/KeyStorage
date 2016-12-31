//
//  KeyStorage - Simplifying securely saving key information
//  KeyStorageKeyChainProvider.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//

import Foundation
import Security

public struct KeyChainInfo {
    
    public enum errorDetail: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
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
            case String(kSecAttrAccessibleWhenUnlocked):
                self = .whenUnlocked
            case String(kSecAttrAccessibleAfterFirstUnlock):
                self = .afterFirstUnlock
            case String(kSecAttrAccessibleAlways):
                self = .always
            case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
                self = .whenUnlockedThisDeviceOnly
            case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
                self = .afterFirstUnlockThisDeviceOnly
            case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
                self = .alwaysThisDeviceOnly
            case String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly):
                self = .whenPasscodeSetThisDeviceOnly
            default:
                self = .whenUnlocked
            }
        }
        
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

public final class KeyStorageKeyChainProvider: KeyStorage {
    
    fileprivate var accessGroup: String?
    fileprivate var accessible = KeyChainInfo.accessibleOption.afterFirstUnlock
    fileprivate var serviceName = Bundle.main.bundleIdentifier ?? "KeyStorageKeyChainProvider"
    fileprivate var crypter: KeyStorageCrypter?
    
    public var synchronizable: Bool = true
    
    public init(serviceName: String? = nil, accessGroup: String? = nil, accessible: KeyChainInfo.accessibleOption = .afterFirstUnlock, cryptoProvider: KeyStorageCrypter? = nil) {
        self.accessGroup = accessGroup
        self.accessible = accessible
        self.serviceName = serviceName ?? self.serviceName
        self.crypter = cryptoProvider
    }
  
    public func synchronize() {
        synchronizable = true
    }
    
    @discardableResult public func setURL(forKey: String, value: URL) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
    }
    
    public func getURL(forKey: String) -> URL? {
        guard let urlData = load(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: urlData) as? URL
    }
    
    public func getURL(forKey: String, defaultValue: URL) -> URL {
        guard let urlData = load(forKey: forKey) else {
            return defaultValue
        }
        
        return (NSKeyedUnarchiver.unarchiveObject(with: urlData) as? URL)!
    }
    
    @discardableResult public func setObject(forKey: String, value: NSCoding) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
    }
    
    @discardableResult public func setData(forKey: String, value: Data) -> Bool {
        return saveData(forKey: forKey, value: value)
    }
    
    @discardableResult public func setString(forKey: String, value: String) -> Bool {
        if let data = value.data(using: .utf8) {
            return saveData(forKey: forKey, value: data)
        }
        return false
    }
    
    @discardableResult public func setInt(forKey: String, value: Int) -> Bool {
        return saveObject(forKey: forKey, value: NSNumber(value: value))
    }
    
    @discardableResult public func setDouble(forKey: String, value: Double) -> Bool {
        return saveObject(forKey: forKey, value: NSNumber(value: value))
    }
    
    @discardableResult public func setFloat(forKey: String, value: Float) -> Bool {
        return saveObject(forKey: forKey, value: NSNumber(value: value))
    }
    
    @discardableResult public func setDate(forKey: String, value: Date) -> Bool {
        return saveObject(forKey: forKey, value: NSNumber(value: value.timeIntervalSince1970))
    }
    
    @discardableResult public func setBool(forKey: String, value: Bool) -> Bool {
        return saveObject(forKey: forKey, value: NSNumber(value: value))
    }
    
    @discardableResult public func removeKey(forKey: String) -> Bool {
        let query = buildQuery(forKey: forKey)
        let status = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else { return true }
        if status != errSecSuccess {
            let error = KeyChainInfo.errorDetail.unhandledError(status: status).localizedDescription
            print("Error Removing key \(forKey) from keychain. Error: \(error) ")
            return false
        }
        return true
    }
    
    public func exists(forKey: String) -> Bool {
        let results = load(forKey: forKey)
        return results != nil
    }
    
    public func getData(forKey: String) -> Data? {
        return load(forKey: forKey)
    }
    
    public func getString(forKey: String) -> String? {
        if let data = load(forKey: forKey) {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        
        return nil
    }
    
    public func getString(forKey: String, defaultValue: String) -> String {
        if let data = load(forKey: forKey) {
            return String(data: data, encoding: String.Encoding.utf8)!
        }
        
        return defaultValue
    }
    
    public func getInt(forKey: String) -> Int {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return 0
        }
        
        return result.intValue
    }
    
    public func getInt(forKey: String, defaultValue: Int) -> Int {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return defaultValue
        }
        
        return result.intValue
    }
    
    public func getDouble(forKey: String) -> Double {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return 0
        }
        
        return result.doubleValue
    }
    
    public func getDouble(forKey: String, defaultValue: Double) -> Double {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return defaultValue
        }
        
        return result.doubleValue
    }
    
    public func getFloat(forKey: String) -> Float {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return 0
        }
        
        return result.floatValue
    }
    
    public func getFloat(forKey: String, defaultValue: Float) -> Float {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return defaultValue
        }
        
        return result.floatValue
    }
    
    public func getBool(forKey: String) -> Bool {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return false
        }
        
        return result.boolValue
    }
    
    public func getBool(forKey: String, defaultValue: Bool) -> Bool {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return defaultValue
        }
        
        return result.boolValue
    }
    
    public func getDate(forKey: String) -> Date? {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(result))
    }
    
    public func getDate(forKey: String, defaultValue: Date) -> Date {
        guard let result = getObject(forKey: forKey) as? NSNumber else {
            return defaultValue
        }
        return Date(timeIntervalSince1970: TimeInterval(result))
    }
    
    @discardableResult public func removeAllKeys() -> Bool {
        var query: [String:Any] = [kSecClass as String: kSecClassGenericPassword]
        query[kSecAttrService as String] = serviceName
        
        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else { return true }
        
        if status != errSecSuccess {
            let error = KeyChainInfo.errorDetail.unhandledError(status: status).localizedDescription
            print("Error removing all keys from keychain. Error: \(error) ")
            return false
        }
        
        return true
    }
    
    public func getArray(forKey: String) -> NSArray? {
        guard let keychainData = load(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: keychainData) as? NSArray
    }
    
    @discardableResult public func setArray(forKey: String, value: NSArray) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
    }
    
    public func getDictionary(forKey: String) -> NSDictionary? {
        guard let keychainData = load(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: keychainData) as? NSDictionary
    }
    
    @discardableResult public func setDictionary(forKey: String, value: NSDictionary) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
    }
    
    private func getObject(forKey: String) -> NSCoding? {
        guard let keychainData = load(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: keychainData) as? NSCoding
    }
    
    private func saveObject(forKey: String, value: NSCoding) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
    }
    
    private func saveData(forKey: String, value: Data) -> Bool {
        var query = buildQuery(forKey: forKey)
        
        if let crypto = self.crypter {
            query[kSecValueData as String] = crypto.encrypt(data: value, forKey: forKey)
        } else {
            query[kSecValueData as String] = value
        }
    
        SecItemDelete(query as CFDictionary)
        
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            let error = KeyChainInfo.errorDetail.unhandledError(status: status).localizedDescription
            print("Error Saving key \(forKey) to keychain. Error: \(error) ")
            return false
        }
        return true
    }
    
    private func load(forKey: String) -> Data? {
        var query = buildQuery(forKey: forKey)
        // Setup parameters needed to return value from query
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        if status == errSecSuccess {
            if let data = dataTypeRef as! Data? {
                if let crypto = self.crypter {
                    return crypto.decrypt(data: data, forKey: forKey)
                }
                return data
            }
        }
        
        return nil
    }
    
    private func buildQuery(forKey: String) -> [String:Any] {
        // Setup default access as generic password (rather than a certificate, internet password, etc)
        var query: [String:Any] = [kSecClass as String: kSecClassGenericPassword]
        
        //Add Service Name
        query[kSecAttrService as String] = serviceName
        
        //There will always be a value here as we default to afterFirstUnlock
        query[kSecAttrAccessible as String] = accessible.rawValue
        
        //Check if access group has been defined
        if let accessGroup = self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        query[kSecAttrSynchronizable as String] = synchronizable
        query[kSecAttrGeneric as String] = forKey.data(using: String.Encoding.utf8)
        query[kSecAttrAccount as String] = forKey
        
        return query
    }
    
}
