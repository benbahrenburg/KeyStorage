//
//  KeyStorage - Simplifying securely saving key information
//  KeyStoreDefaultsProvider.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2019 bencoding.com. All rights reserved.
//

import Foundation


/**
 
 Storage Provider that saves/reads keys from the NSUserDefaults
 
 */
public final class KeyStoreDefaultsProvider: KeyStorage {
    private var defaults: UserDefaults
    private var crypter: KeyStorageCrypter?
    private var usingEncryption: Bool = false
    
    /// the suiteName set when the provider was initialized
    var suiteName: String?
    
    public init(cryptoProvider: KeyStorageCrypter? = nil) {
        self.defaults = UserDefaults()
        self.crypter = cryptoProvider
        self.usingEncryption = cryptoProvider != nil
    }
    
    public init(suiteName: String, cryptoProvider: KeyStorageCrypter? = nil) {
        self.suiteName = suiteName
        self.crypter = cryptoProvider
        self.defaults = UserDefaults(suiteName: suiteName)!
        self.usingEncryption = cryptoProvider != nil
    }

    /**
     Waits for any pending asynchronous updates to the defaults database and returns.  This method will always return true as the apple documents recommend not using synchronize
     
     - Returns: Bool is returned true if the data was saved successfully to disk, otherwise false.
     */
    public func synchronize() -> Bool {
        return true
    }
 
    /**
     Returns a Bool indicating if the value was stored for the provided key
     
     - Parameter forKey: The key to check if there is a stored value for.
     - Parameter value: Codable of type T to be saved
     - Returns: Bool is returned true if a stored value exists or false if there is no stored value.
     */
    @discardableResult public func setStruct<T: Codable>(forKey: String, value: T?) -> Bool {
        guard let data = try? JSONEncoder().encode(value) else {
            return removeKey(forKey: forKey)
        }
        return saveData(forKey: forKey, value: data)
    }
 
    public func getStruct<T>(forKey: String, forType: T.Type) -> T? where T : Decodable {
        if let data = load(forKey: forKey) {
           return try! JSONDecoder().decode(forType, from: data)
        }
        return nil
    }
    
    /**
     Returns a Bool indicating if the value was stored for the provided key
     
     - Parameter forKey: The key to check if there is a stored value for.
     - Parameter value: An Array of Codable of type T to be saved
     - Returns: Bool is returned true if a stored value exists or false if there is no stored value.
     */
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
    /**
     Returns a Bool indicating if a stored value exists for the provided key.
     
     - Parameter forKey: The key to check if there is a stored value for.
     - Returns: Bool is returned true if a stored value exists or false if there is no stored value.
     */
    public func exists(forKey: String) -> Bool {
        return defaults.object(forKey: forKey) != nil
    }

    /**
     Removes the stored value for the provided key.
     
     - Parameter forKey: The key that should have it's stored value removed
     - Returns: Bool is returned with the status of the removal operation. True for success, false for error.
     */
    @discardableResult public func removeKey(forKey: String) -> Bool {
        defaults.removeObject(forKey: forKey)
        return true
    }
    
    @discardableResult public func setString(forKey: String, value: String) -> Bool {
        if usingEncryption {
            if let data = value.data(using: .utf8) {
                return saveData(forKey: forKey, value: data)
            }
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    @discardableResult public func setInt(forKey: String, value: Int) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    @discardableResult public func setBool(forKey: String, value: Bool) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    @discardableResult public func setDouble(forKey: String, value: Double) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    @discardableResult public func setFloat(forKey: String, value: Float) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    @discardableResult public func setDate(forKey: String, value: Date) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value.timeIntervalSince1970))
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    @discardableResult public func setURL(forKey: String, value: URL) -> Bool {
        if usingEncryption {
            guard let data: Data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
                return false
            }
            return saveData(forKey: forKey, value: data)
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    @discardableResult public func setData(forKey: String, value: Data) -> Bool {
        return saveData(forKey: forKey, value: value)
    }

    /**
     Returns String? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: The String? (optional) for the provided key
     */
    public func getString(forKey: String) -> String? {
        if usingEncryption {
            if let data = load(forKey: forKey) {
               return String(data: data, encoding: String.Encoding.utf8)
            }
            return nil
        }
        return defaults.string(forKey: forKey)
    }

    /**
     Returns String for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: The String for the provided key
     */
    public func getString(forKey: String, defaultValue: String) -> String {
        guard exists(forKey: forKey) else { return defaultValue }
        
        if let results = getString(forKey: forKey) {
            return results
        }
        return defaultValue
    }
    
    public func getInt(forKey: String) -> Int {
        if usingEncryption {
            guard let result = getObject(forKey: forKey) as? NSNumber else {
                return 0
            }
            return result.intValue
        }
        return defaults.integer(forKey: forKey)
    }
    
    public func getInt(forKey: String, defaultValue: Int) -> Int {
        guard exists(forKey: forKey) else { return defaultValue }
        return getInt(forKey: forKey)
    }
    
    public func getDouble(forKey: String) -> Double {
        if usingEncryption {
            guard let result = getObject(forKey: forKey) as? NSNumber else {
                return 0
            }
            return result.doubleValue
        }
        return defaults.double(forKey: forKey)
    }
    
    public func getDouble(forKey: String, defaultValue: Double) -> Double {
        guard exists(forKey: forKey) else { return defaultValue }
        return getDouble(forKey: forKey)
    }
    
    public func getFloat(forKey: String) -> Float {
        if usingEncryption {
            guard let result = getObject(forKey: forKey) as? NSNumber else {
                return 0
            }
            return result.floatValue
        }
        return defaults.float(forKey: forKey)
    }
    
    public func getFloat(forKey: String, defaultValue: Float) -> Float {
        guard exists(forKey: forKey) else { return defaultValue }
        return getFloat(forKey: forKey)
    }
 
    @discardableResult public func setObject(forKey: String, value: NSCoding) -> Bool {
        guard let data: Data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
            return false
        }
        return saveData(forKey: forKey, value: data)
    }
    
    public func getArray(forKey: String) -> NSArray? {
        guard exists(forKey: forKey) else { return nil }
        guard let data = getObject(forKey: forKey) else {
            return nil
        }
        
        if let obj = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as! Data) as? NSArray {
            return obj
        }
        return nil
    }
 
    /**
     Saves an NSArray to NSUserDefaults.
     
     - Parameter forKey: The key to be used when saving the provided value
     - Parameter value: The value to be saved
     - Returns: True if saved successfully, false if the provider was not able to save successfully
     */
    @discardableResult public func setArray(forKey: String, value: NSArray) -> Bool {
        guard let data: Data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
            return false
        }
        return saveData(forKey: forKey, value: data)
    }
    
    public func getDictionary(forKey: String) -> NSDictionary? {
        guard exists(forKey: forKey) else { return nil }
        guard let data = getObject(forKey: forKey) else {
            return nil
        }
        if let obj = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as! Data) as? NSDictionary {
            return obj
        }
        return nil
    }

    /**
     Saves a NSDictionary to NSUserDefaults.
     
     - Parameter forKey: The key to be used when saving the provided value
     - Parameter value: The value to be saved
     - Returns: True if saved successfully, false if the provider was not able to save successfully
     */
    @discardableResult public func setDictionary(forKey: String, value: NSDictionary) -> Bool {
        guard let data: Data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
            return false
        }
        return saveData(forKey: forKey, value: data)
    }
    
    public func getBool(forKey: String) -> Bool {
        guard exists(forKey: forKey) else { return false }
        
        if usingEncryption {
            guard let result = getObject(forKey: forKey) as? Bool else {
                return false
            }
            return result
        }
        return defaults.bool(forKey: forKey)
    }
    
    public func getBool(forKey: String, defaultValue: Bool) -> Bool {
        guard exists(forKey: forKey) else { return defaultValue }
        return getBool(forKey: forKey)
    }
    
    public func getDate(forKey: String) -> Date? {
        guard exists(forKey: forKey) else { return nil }
        
        if let stored = getObject(forKey: forKey) {
            return stored as? Date
        }
        return nil
    }
    
    public func getDate(forKey: String, defaultValue: Date) -> Date {
        guard exists(forKey: forKey) else { return defaultValue }
        
        if let stored = getObject(forKey: forKey) {
            return stored as! Date
        }
        return defaultValue
    }
    
    public func getURL(forKey: String) -> URL? {
        guard exists(forKey: forKey) else { return nil }
        
        if usingEncryption {
            guard let result = getObject(forKey: forKey) as? URL else {
                return nil
            }
            return result
        }
        return defaults.url(forKey: forKey)
    }
    
    public func getURL(forKey: String, defaultValue: URL) -> URL {
        if let url = getURL(forKey: forKey) {
            return url
        }
        return defaultValue
    }

    /**
     Returns Data? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: The Data? (optional) for the provided key
     */
    public func getData(forKey: String) -> Data? {
        return load(forKey: forKey)
    }
    
    public func getData(forKey: String, defaultValue: Data) -> Data? {
        if let stored = getData(forKey: forKey) {
            return stored
        }
        return defaultValue
    }
 
    /**
     Removes all of the keys stored with the provider
     
     - Returns: Bool is returned with the status of the removal operation. True for success, false for error.
     */
    @discardableResult public func removeAllKeys() -> Bool {
        if let suiteName = suiteName {
            defaults.removeSuite(named: suiteName)
        } else {
            for key in Array(defaults.dictionaryRepresentation().keys) {
                defaults.removeObject(forKey: key)
            }
        }
        return true
    }

    private func getObject(forKey: String) -> NSCoding? {
        guard let data = load(forKey: forKey) else {
            return nil
        }
        if let obj = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSCoding {
            return obj
        }
        return nil
    }
    
    private func saveObject(forKey: String, value: NSCoding) -> Bool {
        guard let data: Data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
            return false
        }
        return saveData(forKey: forKey, value: data)
    }

    private func loadArray(forKey: String) -> [Data]? {
        let raw = defaults.array(forKey: forKey)
        guard let data = raw as? [Data] else { return nil }
        if let crypto = self.crypter {
            return crypto.decrypt(data: data, forKey: forKey)
        }
        return data
    }
    
    private func load(forKey: String) -> Data? {
        let data = defaults.data(forKey: forKey)
        guard data != nil else { return nil }
        if let crypto = self.crypter {
            return crypto.decrypt(data: data!, forKey: forKey)
        }
        return data
    }
    
    private func saveData(forKey: String, value: Data) -> Bool {
        if let crypto = self.crypter {
            defaults.set(crypto.encrypt(data: value, forKey: forKey), forKey: forKey)
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
    
    private func saveData(forKey: String, value: [Data]) -> Bool {
        if let crypto = self.crypter {
            defaults.set(crypto.encrypt(data: value, forKey: forKey), forKey: forKey)
        } else {
            defaults.set(value, forKey: forKey)
        }
        return true
    }
}
