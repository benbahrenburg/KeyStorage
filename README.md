# KeyStorage

KeyStorage is a simple secure key persistance library written in Swift.  Persist passwords, preferences, and other key information quickly, easily and securely using the Keychain, NSUserDefaults or NSUbiquitousKeyValueStore.

## Features

* Strongly typed persistance to either Keychain, NSUserDefaults or NSUbiquitousKeyValueStore
* Built-in AES 256 encryption [feature in process]
* Extensible - add new storage or encrytion providers
* Keychain helpers for finding AccessGroup information

## Requirements

* Xcode 10.3 or newer
* Swift 5.0
* iOS 11 or greater

## Installation

KeyStorage is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:


```ruby
pod "KeyStorage"
```

__Carthage__

```
github "benbahrenburg/KeyStorage"
```

__Manually__

Copy all `*.swift` files contained in `KeyStorage/Classes/` directory into your project. 


## Usage

There are five main classes in KeyStorage:

1. KeyStorage - The protocol which all of the storage providers must conform 
2. KeyStorageCrypter - The protocol used to encrypt and decrypt key values 
3. KeyStorageKeyChainProvider - A keychain implementation of the KeyStorage protocol
4. KeyStoreDefaultsProvider -  A NSUserDefaults implementation of the KeyStorage protocol
5. KeychainHelpers - Tools for workign with the iOS keychain

## Examples

The KeyStorage githib wiki contains detailed examples of each method.  Below demonstrates a few of the common uses to get you started.

### Using NSUserDefault Storage Provider

The KeyStoreDefaultsProvider Storage Provider will read / write information from NSUserDefaults using the configuration options provided when the class is initialized.  See the creation section below for more details on the available configuration options.

```swift
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
```

### Using Keychain Storage Provider

The KeyStorageKeyChainProvider Storage Provider will read / write information from Keychain using the configuration options provided when the class is initialized.  See the creation section below for more details on the available configuration options.

```swift
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

```

## Save Options

Each of the KeyStorage providers has a variety of type safe options to save key information.  Please visit the [wiki](https://github.com/benbahrenburg/KeyStorage/wiki/KeyStorage---Save-Options) for more details.

        
## Return Options

Each of the KeyStorage providers has a variety of type safe options to read key information.  Please visit the [wiki](https://github.com/benbahrenburg/KeyStorage/wiki/KeyStorage---Read-Options) for more details.

## Actions / Helpers

KeyStorage provides a few methods to help you work with your StorageProvders.

**exists** - Returns a Boolean if the specified key exists

```swift
let doesExist = keyStoreProvider.exists(forKey: "Hello")
```

**removeKey** - Removes the stored value for the specified key

```swift
let success = keyStoreProvider.removeKey(forKey: "Hello")
print("was success? \(success)")
```

**removeAllKeys** - Removes all stored values for the KeyStorage provider

```swift
let success = keyStoreProvider.removeAllKeys()
print("was success? \(success)")
```

## Storage Providers

### KeyStoreDefaultsProvider
The KeyStoreDefaultsProvider storage provider manages persistance to NSUserDefaults.

#### KeyStoreDefaultsProvider - Creation 

The KeyStoreDefaultsProvider can be created with the following optional arguments.

**suiteName** : String

The specified app group name that will be used

```swift
let provider = KeyStoreDefaultsProvider(suiteName: "MyAppGroup")
```

**cryptoProvider** : KeyStorageCrypter

The encryption provider that will be used to encrypt and decrypt key values

```swift
let provider = KeyStoreDefaultsProvider(cryptoProvider: myCryptoProvider)
```

**Combined Example**

You can specify both if you wish to use an encryption provider and implement app group sharing.

```swift
let provider = KeyStoreDefaultsProvider(suiteName: "MyAppGroup", cryptoProvider: myCryptoProvider)
```

### KeyStorageKeyChainProvider
The KeyStorageKeyChainProvider storage provider manages persistance to iOS Keychain.

#### KeyStorageKeyChainProvider - Creation 

The KeyStorageKeyChainProvider can be created with the following optional arguments.

**serviceName** : String

The serviceName used to identify key values stored in the Keychain.

```swift
let provider = KeyStorageKeyChainProvider(serviceName: "myApp")
```

**accessGroup** : String

The Keychain Access Group used to identify key values stored in the Keychain. This must be implemented if you are using Keychain sharing.

```swift
let provider = KeyStorageKeyChainProvider(accessGroup: "myApp")
```

**cryptoProvider** : KeyStorageCrypter

The encryption provider that will be used to encrypt and decrypt key values

```swift
let provider = KeyStorageKeyChainProvider(cryptoProvider: myCryptoProvider)
```

**accessible** : KeyChainInfo.accessibleOption

The accessibility level of the values in the Keychain. See the Keychain documentation [here](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html) for details.

```swift
let provider = KeyStorageKeyChainProvider(accessible: .afterFirstUnlock)
```

**Combined Example**

You can combine all of the above as needed.  Below is an example of this fully implemented.

```swift
let provider = KeyStorageKeyChainProvider(serviceName: "myApp", accessGroup: "my-awesome-group", accessible: .afterFirstUnlockThisDeviceOnly, cryptoProvider: myCryptoProvider)
```

## KeychainHelpers

### Get Keychain AccessGroup Information

Programmatically look-up your application's App ID Prefix and default Keychain Group.

```swift
//Get Information 
let info = KeychainHelpers.getAccessGroupInfo()

print("App ID Prefix \(info.prefix)")
print("KeyChain Group \(info.keyChainGroup)")
print("Raw kSecAttrAccessGroup value \(info.rawValue)")
```

## Author

Ben Bahrenburg, [@bencoding](https://twitter.com/bencoding)

## License

KeyStorage is available under the MIT license. See the LICENSE file for more info.
