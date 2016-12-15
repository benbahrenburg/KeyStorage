//
//  UserProperties.swift
//  UserProperties
//
//  Created by Ben Bahrenburg on 1/1/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//

import Foundation

public final class KeyStoreDefaultsProvider: KeyStorage {
    fileprivate var defaults: UserDefaults
    var suiteName: String?
    
    public init() {
        defaults = UserDefaults()
    }
    
    public init(suiteName: String) {
        self.suiteName = suiteName
        defaults = UserDefaults(suiteName: suiteName)!
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
    
    @discardableResult public func setObject(forKey: String, value: NSCoding) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        defaults.set(data, forKey: forKey)
        return true
    }
    
    @discardableResult public func setString(forKey: String, value: String) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setInt(forKey: String, value: Int) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setBool(forKey: String, value: Bool) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setDouble(forKey: String, value: Double) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setFloat(forKey: String, value: Float) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setObject(forKey: String, value: AnyObject) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setDate(forKey: String, value: Date) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setURL(forKey: String, value: URL) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    @discardableResult public func setData(forKey: String, value: Data) -> Bool {
        defaults.set(value, forKey: forKey)
        return true
    }
    
    public func getString(forKey: String) -> String? {
        return defaults.string(forKey: forKey)
    }
    
    public func getString(forKey: String, defaultValue: String) -> String {
        if let results = getString(forKey: forKey) {
            return results
        }
        return defaultValue
    }
    
    public func getInt(forKey: String) -> Int {
        return defaults.integer(forKey: forKey)
    }
    
    public func getInt(forKey: String, defaultValue: Int) -> Int {
        if exists(forKey: forKey) {
            return defaults.integer(forKey: forKey)
        }
        return defaultValue
    }
    
    public func getDouble(forKey: String) -> Double {
        return defaults.double(forKey: forKey)
    }
    
    public func getDouble(forKey: String, defaultValue: Double) -> Double {
        if exists(forKey: forKey) {
            return getDouble(forKey: forKey)
        }
        return defaultValue
    }
    
    public func getFloat(forKey: String) -> Float {
        return defaults.float(forKey: forKey)
    }
    
    public func getFloat(forKey: String, defaultValue: Float) -> Float {
        if exists(forKey: forKey) {
            return getFloat(forKey: forKey)
        }
        return defaultValue
    }
    
    public func getObject(forKey: String) -> AnyObject? {
        return defaults.object(forKey: forKey) as AnyObject?
    }
    
    public func getArray(forKey: String) -> NSArray? {
        guard let data = getObject(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? NSArray
    }
    
    @discardableResult public func setArray(forKey: String, value: NSArray) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return setData(forKey: forKey, value: data)
    }
    
    public func getDictionary(forKey: String) -> NSDictionary? {
        guard let data = getObject(forKey: forKey) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? NSDictionary
    }
    
    @discardableResult public func setDictionary(forKey: String, value: NSDictionary) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return setData(forKey: forKey, value: data)
    }
    
    public func getBool(forKey: String) -> Bool {
        return defaults.bool(forKey: forKey)
    }
    
    public func getBool(forKey: String, defaultValue: Bool) -> Bool {
        if exists(forKey: forKey) {
            return getBool(forKey: forKey)
        }
        return defaultValue
    }
    
    public func getDate(forKey: String) -> Date? {
        if exists(forKey: forKey) {
            if let stored = getObject(forKey: forKey) {
                return stored as? Date
            }
        }
        return nil
    }
    
    public func getDate(forKey: String, defaultValue: Date) -> Date {
        if exists(forKey: forKey) {
            if let stored = getObject(forKey: forKey) {
                return stored as! Date
            }
        }
        return defaultValue
    }
    
    public func getURL(forKey: String) -> URL? {
        return defaults.url(forKey: forKey)
    }
    
    public func getURL(forKey: String, defaultValue: URL) -> URL? {
        if let stored = defaults.url(forKey: forKey) {
            return stored
        }
        return defaultValue
    }
    
    public func getData(forKey: String) -> Data? {
        return defaults.data(forKey: forKey)
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
    
}
