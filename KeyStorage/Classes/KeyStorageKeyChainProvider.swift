//
//  KeyStorage - Simplifying securely saving key information
//  KeyStorageKeyChainProvider.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2019 bencoding.com. All rights reserved.
//

import Foundation
import Security

/**
 
 Storage Provider that saves/reads keys from the Keychain
 
 */
public final class KeyStorageKeyChainProvider: KeyStorage {
    private let lock = NSLock()
    private var accessGroup: String?
    private var accessible = KeyChainInfo.accessibleOption.afterFirstUnlock
    private var serviceName = Bundle.main.bundleIdentifier ?? "KeyStorageKeyChainProvider"
    private var crypter: KeyStorageCrypter?
    private var synchronizable: Bool = true
    
    public init(serviceName: String? = nil, accessGroup: String? = nil, accessible: KeyChainInfo.accessibleOption = .afterFirstUnlock, cryptoProvider: KeyStorageCrypter? = nil, synchronizable: Bool = true) {
        self.accessGroup = accessGroup
        self.accessible = accessible
        self.serviceName = serviceName ?? self.serviceName
        self.crypter = cryptoProvider
        self.synchronizable = synchronizable
    }
  
    @discardableResult public func setStruct<T: Codable>(forKey: String, value: T?) -> Bool {
        guard let data = try? JSONEncoder().encode(value) else {
            return removeKey(forKey: forKey)
        }
        return saveData(forKey: forKey, value: data)
    }
    
    public func getStruct<T>(forKey: String, forType: T.Type) -> T? where T : Decodable {
        if let data = loadData(forKey: forKey) {
           return try! JSONDecoder().decode(forType, from: data)
        }
        return nil
    }
    
    @discardableResult public func setStructArray<T: Codable>(forKey: String, value: [T]) -> Bool {
        let data = value.compactMap { try? JSONEncoder().encode($0) }
        if data.count == 0 {
            return removeKey(forKey: forKey)
        }
        return saveData(forKey: forKey, value: data)
    }
    
    public func getStructArray<T>(forKey: String, forType: T.Type) -> [T] where T : Decodable {
        if let data = loadArray(forKey: forKey) {
           return data.map { try! JSONDecoder().decode(forType, from: $0) }
        }
        return []
    }
    
    @discardableResult public func setURL(forKey: String, value: URL) -> Bool {
        let data = withUnsafeBytes(of: value) { Data($0) }
        return saveData(forKey: forKey, value: data)
    }
    
    public func getURL(forKey: String) -> URL? {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: URL.self)
            }
            return value
        }
        return nil
    }
    
    public func getURL(forKey: String, defaultValue: URL) -> URL {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: URL.self)
            }
            return value
        }
        return defaultValue
    }
    
    @discardableResult public func setObject(forKey: String, value: NSCoding) -> Bool {
        guard let data = archiveData(withRootObject: value) else {
            return false
        }
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
        let data = withUnsafeBytes(of: value) { Data($0) }
        return saveData(forKey: forKey, value: data)
    }
    
    @discardableResult public func setDouble(forKey: String, value: Double) -> Bool {
        let data = withUnsafeBytes(of: value) { Data($0) }
        return saveData(forKey: forKey, value: data)
    }
    
    @discardableResult public func setFloat(forKey: String, value: Float) -> Bool {
        let data = withUnsafeBytes(of: value) { Data($0) }
        return saveData(forKey: forKey, value: data)
    }
    
    @discardableResult public func setDate(forKey: String, value: Date) -> Bool {
        let data = withUnsafeBytes(of: value) { Data($0) }
        return saveData(forKey: forKey, value: data)
    }
    
    @discardableResult public func setBool(forKey: String, value: Bool) -> Bool {
        let bytes: [UInt8] = value ? [1] : [0]
        let data = Data(bytes)
        return saveData(forKey: forKey, value: data)
    }

    /**
     Removes the stored value for the provided key.
     
     - Parameter forKey: The key that should have it's stored value removed
     - Returns: Bool is returned with the status of the removal operation. True for success, false for error.
     */
    @discardableResult public func removeKey(forKey: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let query = buildQuery(forKey)
        let status = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else { return true }
        if status != errSecSuccess {
            if let error = SecCopyErrorMessageString(status, nil) {
                print("Error Removing key \(forKey) from keychain. Error: \(error) ")
            }
            return false
        }
        return true
    }
 
    /**
     Returns a Bool indicating if a stored value exists for the provided key.
     
     - Parameter forKey: The key to check if there is a stored value for.
     - Returns: Bool is returned true if a stored value exists or false if there is no stored value.
     */
    public func exists(forKey: String) -> Bool {
        let results = loadData(forKey: forKey)
        return results != nil
    }

    /**
     Returns Data? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: The Data? (optional) for the provided key
     */
    public func getData(forKey: String) -> Data? {
        return loadData(forKey: forKey)
    }

    /**
     Returns String? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: The String? (optional) for the provided key
     */
    public func getString(forKey: String) -> String? {
        if let data = loadData(forKey: forKey) {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        return nil
    }

    /**
     Returns String for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: The String for the provided key
     */
    public func getString(forKey: String, defaultValue: String) -> String {
        if let data = loadData(forKey: forKey) {
            return String(data: data, encoding: String.Encoding.utf8)!
        }
        
        return defaultValue
    }
    
    public func getInt(forKey: String) -> Int {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Int.self)
            }
            return value
        }
        return 0
    }
    
    public func getInt(forKey: String, defaultValue: Int) -> Int {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Int.self)
            }
            return value
        }
        return defaultValue
    }
    
    public func getDouble(forKey: String) -> Double {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Double.self)
            }
            return value
        }
        return 0.0
    }
    
    public func getDouble(forKey: String, defaultValue: Double) -> Double {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Double.self)
            }
            return value
        }
        return defaultValue
    }
    
    public func getFloat(forKey: String) -> Float {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Float.self)
            }
            return value
        }
        return 0
    }
    
    public func getFloat(forKey: String, defaultValue: Float) -> Float {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Float.self)
            }
            return value
        }
        return defaultValue
    }
    
    public func getBool(forKey: String) -> Bool {
        guard let data = getData(forKey: forKey) else {
            return false;
        }
        guard let first = data.first else { return false }
        return first == 1
    }
    
    public func getBool(forKey: String, defaultValue: Bool) -> Bool {
        guard let data = getData(forKey: forKey) else {
            return defaultValue;
        }
        guard let first = data.first else { return defaultValue }
        return first == 1
    }
    
    public func getDate(forKey: String) -> Date? {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Date.self)
            }
            return value
        }
        return nil
    }
    
    public func getDate(forKey: String, defaultValue: Date) -> Date {
        if let data = loadData(forKey: forKey) {
            let value = data.withUnsafeBytes {
                $0.load(as: Date.self)
            }
            return value
        }
        return defaultValue
    }

    /**
     Removes all of the keys stored with the provider
     
     - Returns: Bool is returned with the status of the removal operation. True for success, false for error.
     */
    @discardableResult public func removeAllKeys() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        var query: [String:Any] = [kSecClass as String: kSecClassGenericPassword]
        query[kSecAttrService as String] = serviceName
        
        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else { return true }
        
        if status != errSecSuccess {
            if let error = SecCopyErrorMessageString(status, nil) {
                print("Error removing all keys from keychain. Error: \(error) ")
            }
            return false
        }
        
        return true
    }
    
    public func getArray(forKey: String) -> NSArray? {
        guard let data = loadData(forKey: forKey) else {
            return nil
        }
        
        if let result = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSArray {
             return result
        }
        
        return nil
    }

    /**
     Saves an NSArray to the keychain.
     
     - Parameter forKey: The key to be used when saving the provided value
     - Parameter value: The value to be saved
     - Returns: True if saved successfully, false if the provider was not able to save successfully
     */
    @discardableResult public func setArray(forKey: String, value: NSArray) -> Bool {
        guard let data = archiveData(withRootObject: value) else {
            return false
        }
        return saveData(forKey: forKey, value: data)
    }
    
    public func getDictionary(forKey: String) -> NSDictionary? {
        guard let data = loadData(forKey: forKey) else {
            return nil
        }
        
        if let result = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSDictionary {
             return result
        }
        
        return nil
    }

    /**
     Saves a NSDictionary to the keychain.
     
     - Parameter forKey: The key to be used when saving the provided value
     - Parameter value: The value to be saved
     - Returns: True if saved successfully, false if the provider was not able to save successfully
     */
    @discardableResult public func setDictionary(forKey: String, value: NSDictionary) -> Bool {
        guard let data = archiveData(withRootObject: value) else {
            return false
        }
        return saveData(forKey: forKey, value: data)
    }
    
    private func archiveData(withRootObject object: Any) -> Data? {
        guard let data: Data = try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true) else {
            return nil
        }
        return data
    }
    
    private func getObject(forKey: String) -> NSCoding? {
        guard let data = loadData(forKey: forKey) else {
            return nil
        }
        if let result = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSCoding {
             return result
        }
        
        return nil
    }
    
    private func saveObject(forKey: String, value: NSCoding) -> Bool {
        guard let data = archiveData(withRootObject: value) else {
            return false
        }
        return saveData(forKey: forKey, value: data)
    }
    
    private func handleResultStatus(forKey: String, status: OSStatus) -> Bool {
        if status != errSecSuccess {
            if let error = SecCopyErrorMessageString(status, nil) {
                print("Error Saving key \(forKey) to keychain. Error: \(error) ")
            }
            return false
        }
        return true
    }
 
    private func saveData(forKey: String, value: [Data]) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        let query = buildQuery(forKey)
        
        if let crypto = self.crypter {
            query[kSecValueData as String] = crypto.encrypt(data: value, forKey: forKey)
        } else {
            query[kSecValueData as String] = value
        }
    
        if SecItemCopyMatching(query, nil) == noErr {
            let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: value]))
            return handleResultStatus(forKey: forKey, status: status)
        }
        
        let status = SecItemAdd(query, nil)
        return handleResultStatus(forKey: forKey, status: status)

    }
    
    private func saveData(forKey: String, value: Data) -> Bool {
        
        lock.lock()
        defer { lock.unlock() }
        
        let query = buildQuery(forKey)
        
        if let crypto = self.crypter {
            query[kSecValueData as String] = crypto.encrypt(data: value, forKey: forKey)
        } else {
            query[kSecValueData as String] = value
        }
    
        if SecItemCopyMatching(query, nil) == noErr {
            let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: value]))
            return handleResultStatus(forKey: forKey, status: status)
        }
        
        let status = SecItemAdd(query, nil)
        return handleResultStatus(forKey: forKey, status: status)

    }
    
    private func loadData(forKey: String) -> Data? {
        let query = buildQuery(forKey)
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

    private func loadArray(forKey: String) -> [Data]? {
        let query = buildQuery(forKey)
        // Setup parameters needed to return value from query
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        if status == errSecSuccess {
            if let data = dataTypeRef as! [Data]? {
                if let crypto = self.crypter {
                    return crypto.decrypt(data: data, forKey: forKey)
                }
                return data
            }
        }
        
        return nil
    }
    
    private func buildQuery(_ forKey: String) -> NSMutableDictionary {
        // Setup default access as generic password (rather than a certificate, internet password, etc)
        let query = NSMutableDictionary()
        query.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        
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
