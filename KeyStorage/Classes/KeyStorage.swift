//
//  KeyStorage - Simplifying securely saving key information
//  KeyStorage.swift
//
//  Created by Ben Bahrenburg on 3/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//

import Foundation

/**
 
 Protocol used as the contract for all Storage Providers
 
 */
public protocol KeyStorage {
    
    /// Synchronizable is a flag used to determine if KeyStore values should be synchronized
    var synchronizable: Bool {get set}

    /**
        Returns Data? (optional) for a provided key. Nil is returned if no stored value is found.
    
        - Parameter forKey: The key used to return a stored value
        - Returns: The Data? (optional) for the provided key
    */
    func getData(forKey: String) -> Data?

    /**
     Returns String? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: The String? (optional) for the provided key
     */
    func getString(forKey: String) -> String?
    
    /**
     Returns String for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: The String for the provided key
     */
    func getString(forKey: String, defaultValue: String) -> String
    
    /**
     Returns Int for a provided key. If no stored value is available, zero is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: The Int for the provided key
     */
    func getInt(forKey: String) -> Int
    
    /**
     Returns Int for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: Int for the provided key
     */
    func getInt(forKey: String, defaultValue: Int) -> Int
    
    /**
     Returns Bool for a provided key. If no stored value is available, false is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: Bool for the provided key
     */
    func getBool(forKey: String) -> Bool
    
    /**
     Returns Bool for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: Bool for the provided key
     */
    func getBool(forKey: String, defaultValue: Bool) -> Bool

    /**
     Returns Date? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: Date? (optional) for the provided key
     */
    func getDate(forKey: String) -> Date?

    /**
     Returns Date for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: Date for the provided key
     */
    func getDate(forKey: String, defaultValue: Date) -> Date

    /**
     Returns Double for a provided key. If no stored value is available, zero is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: Double for the provided key
     */
    func getDouble(forKey: String) -> Double
    
    /**
     Returns Double for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: Double for the provided key
     */
    func getDouble(forKey: String, defaultValue: Double) -> Double

    /**
     Returns Float for a provided key. If no stored value is available, zero is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: Double for the provided key
     */
    func getFloat(forKey: String) -> Float
    
    /**
     Returns Float for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: Float for the provided key
     */
    func getFloat(forKey: String, defaultValue: Float) -> Float

    /**
     Returns URL? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: URL? (optional) for the provided key
     */
    func getURL(forKey: String) -> URL?

    /**
     Returns URL for a provided key. If no stored value is available, defaultValue is returned.
     
     - Parameter forKey: The key used to return a stored value
     - Parameter defaultValue: The value to be returned if no stored value is available
     - Returns: URL for the provided key
     */
    func getURL(forKey: String, defaultValue: URL) -> URL
  
    /**
     Returns NSArray? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: NSArray? (optional) for the provided key
     */
    func getArray(forKey: String) -> NSArray?
    
    /**
     Returns NSDictionary? (optional) for a provided key. Nil is returned if no stored value is found.
     
     - Parameter forKey: The key used to return a stored value
     - Returns: NSDictionary? (optional) for the provided key
     */
    func getDictionary(forKey: String) -> NSDictionary?
    
    @discardableResult func setURL(forKey: String, value: URL) -> Bool
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

    /**
     Removes the stored value for the provided key.
     
     - Parameter forKey: The key that should have it's stored value removed
     - Returns: Bool is returned with the status of the removal operation. True for success, false for error.
     */
    @discardableResult func removeKey(forKey: String) -> Bool
    
    /**
     Removes all of the keys stored with the provider
     
     - Returns: Bool is returned with the status of the removal operation. True for success, false for error.
     */
    @discardableResult func removeAllKeys() -> Bool

    /**
     Returns a Bool indicating if a stored value exists for the provided key.
     
     - Parameter forKey: The key to check if there is a stored value for.
     - Returns: Bool is returned true if a stored value exists or false if there is no stored value.
     */
    func exists(forKey: String) -> Bool
    
    /// synchronize updates the storage provider's synchronization status. This behavior is specific to each provider.
    func synchronize()
    
}
