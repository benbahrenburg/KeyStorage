//
//  ViewController.swift
//  KeyStorage
//
//  Created by Ben Bahrenburg on 12/14/2016.
//  Copyright (c) 2016 Ben Bahrenburg. All rights reserved.
//

import UIKit
import KeyStorage
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDefaultsExample() {
        
        // Create an instance of the NSDefaults Storage Provider
        // You can provide several options on creation. For this example we keep it simple
        let provider = KeyStoreDefaultsProvider()
        
        // This will return the default value as we haven't set anything yet
        let demoString = provider.getString(forKey: "my-string", defaultValue: "Hello I'm a default value")
        print("Demo default value \(demoString)")
        
        // Now let's set the value
        provider.setString(forKey: "my-string", value: "Hello World")

        // Saving an Int Value
        provider.setInt(forKey: "my-int", value: 42)
        let demoInt = provider.getInt(forKey: "my-int")
        print("Demo Int value \(demoInt)")
        
        // The same format applies, for Date, Float, Doouble, URL, etc, etc
    }

    
    func showKeychainExample() {
        
        // Create an instance of the Keychain Storage Provider
        // You can provide several options on creation. 
        //For this example we provide a serviceName and accessible level
        let provider = KeyStorageKeyChainProvider(serviceName: "my-app", accessible: .afterFirstUnlockThisDeviceOnly)

        // This will return the default value as we haven't set anything yet
        let doubleDemo = provider.getDouble(forKey: "my-double", defaultValue: 123.45)
        print("Demo default value \(doubleDemo)")
        
        // Now let's set the value
        provider.setDouble(forKey: "my-double", value: 99.99)
        
        // Saving an Date Value
        provider.setDate(forKey: "my-date", value: Date())
        let demoDate = provider.getDate(forKey: "my-date")!
        print(" demo Date value \(demoDate)")
        
        // The same format applies, for String, Float, Array, URL, etc, etc
    }
    
}

