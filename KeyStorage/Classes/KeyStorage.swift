//
//  KeyStorage.swift
//  Journey
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 pwc.com. All rights reserved.
//

import Foundation

public protocol KeyStorage {
    
    func getData(forKey: String) -> Data?
    
    func getString(forKey: String) -> String?
    func getString(forKey: String, defaultValue: String) -> String
    
    func getInt(forKey: String) -> Int
    func getInt(forKey: String, defaultValue: Int) -> Int
    
    func getBool(forKey: String) -> Bool
    func getBool(forKey: String, defaultValue: Bool) -> Bool
    
    func getDate(forKey: String) -> Date?
    func getDate(forKey: String, defaultValue: Date) -> Date
    
    func getDouble(forKey: String) -> Double
    func getDouble(forKey: String, defaultValue: Double) -> Double
    
    func getFloat(forKey: String) -> Float
    func getFloat(forKey: String, defaultValue: Float) -> Float
    
    func getArray(forKey: String) -> NSArray?
    func getDictionary(forKey: String) -> NSDictionary?
    
    @discardableResult func setFloat(forKey: String, value: Float) -> Bool
    @discardableResult func setDouble(forKey: String, value: Double) -> Bool
    @discardableResult func setObject(forKey: String, value: NSCoding) -> Bool
    @discardableResult func setData(forKey: String, value: Data) -> Bool
    @discardableResult func setString(forKey: String, value: String) -> Bool
    @discardableResult func setInt(forKey: String, value: Int) -> Bool
    @discardableResult func setBool(forKey: String, value: Bool) -> Bool
    @discardableResult func setDate(forKey: String, value: Date) -> Bool
    @discardableResult func setArray(forKey: String, value: NSArray) -> Bool
    @discardableResult func setDictionary(forKey: String, value: NSDictionary) -> Bool
    
    @discardableResult func removeKey(forKey: String) -> Bool
    func exists(forKey: String) -> Bool
    
    @discardableResult func removeAllKeys() -> Bool
}
