//
//  KeyStorage - Simplifying securely saving key information
//  KeyStoreDefaultsProvider.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//

import Foundation

public final class KeyStoreDefaultsProvider: KeyStorage {
    fileprivate var defaults: UserDefaults
    fileprivate var crypter: KeyStorageCrypter?
    fileprivate var usingEncryption: Bool = false
    
    var suiteName: String?
    public var synchronizable: Bool = true
    
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
    
    public func synchronize() {
        defaults.synchronize()
    }
    
    public func exists(forKey: String) -> Bool {
        defaults.synchronize()
        if let _ = defaults.object(forKey: forKey) {
            return true
        }
        return false
    }
    
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
            trySync()
        }
        return true
    }
    
    @discardableResult public func setInt(forKey: String, value: Int) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
            trySync()
        }
        return true
    }
    
    @discardableResult public func setBool(forKey: String, value: Bool) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
            trySync()
        }
        return true
    }
    
    @discardableResult public func setDouble(forKey: String, value: Double) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
            trySync()
        }
        return true
    }
    
    @discardableResult public func setFloat(forKey: String, value: Float) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value))
        } else {
            defaults.set(value, forKey: forKey)
            trySync()
        }
        return true
    }
    
    @discardableResult public func setDate(forKey: String, value: Date) -> Bool {
        if usingEncryption {
            return saveObject(forKey: forKey, value: NSNumber(value: value.timeIntervalSince1970))
        } else {
            defaults.set(value, forKey: forKey)
            trySync()
        }
        return true
    }
    
    @discardableResult public func setURL(forKey: String, value: URL) -> Bool {
        if usingEncryption {
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            return saveData(forKey: forKey, value: data)
        } else {
            defaults.set(value, forKey: forKey)
            trySync()
        }
        return true
    }
    
    @discardableResult public func setData(forKey: String, value: Data) -> Bool {
        return saveData(forKey: forKey, value: value)
    }
    
    public func getString(forKey: String) -> String? {
        if usingEncryption {
            if let data = load(forKey: forKey) {
               return String(data: data, encoding: String.Encoding.utf8)
            }
            return nil
        }
        return defaults.string(forKey: forKey)
    }
    
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
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
    }
    
    public func getArray(forKey: String) -> NSArray? {
        guard exists(forKey: forKey) else { return nil }
        guard let data = getObject(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? NSArray
    }
    
    @discardableResult public func setArray(forKey: String, value: NSArray) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
    }
    
    public func getDictionary(forKey: String) -> NSDictionary? {
        guard exists(forKey: forKey) else { return nil }
        guard let data = getObject(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? NSDictionary
    }
    
    @discardableResult public func setDictionary(forKey: String, value: NSDictionary) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
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
    
    public func getData(forKey: String) -> Data? {
        return load(forKey: forKey)
    }
    
    public func getData(forKey: String, defaultValue: Data) -> Data? {
        if let stored = getData(forKey: forKey) {
            return stored
        }
        return defaultValue
    }
    
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
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSCoding
    }
    
    private func saveObject(forKey: String, value: NSCoding) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return saveData(forKey: forKey, value: data)
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
        trySync()
        return true
    }
    
    private func trySync() {
        if self.synchronizable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.synchronize()
            }
        }
    }
    
}
