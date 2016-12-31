# KeyStorage
KeyStorage makes working with key information (passwords, preferences, etc) quick, easily and secure.  KeyStorage is a type safe persistance layer built on top of the iOS KeyChain and NSUserDefaults.

## Features

* Strongly typed persistance to either KeyChain or NSUserDefaults
* Built-in AES 256 encryption [feature in process]
* Extensible - add new storage or encrytion providers
* Keychain helpers for finding AccessGroup information

## Requirements

* Xcode 8.2 or newer
* Swift 3.0

## Installation

KeyStorage is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KeyStorage"
```

## Usage

There are five main classes in KeyStorage:

1. KeyStorage - The protocol which all of the storage providers must conform 
2. KeyStorageCrypter - The protocol used to encrypt and decrypt key values 
3. KeyStorageKeyChainProvider - A keychain implementation of the KeyStorage protocol
4. KeyStoreDefaultsProvider -  A NSUserDefaults implementation of the KeyStorage protocol
5. KeychainHelpers - Tools for workign with the iOS keychain

## Save Options

Each of the KeyStorage providers has a variety of type safe options to save key information.  Please visit the [wiki](https://github.com/benbahrenburg/KeyStorage/wiki/KeyStorage---Save-Options) for more details.

        
## Return Options

Each of the KeyStorage providers has a variety of type safe options to read key information.  Please visit the [wiki](https://github.com/benbahrenburg/KeyStorage/wiki/KeyStorage---Read-Options) for more details.

## Actions / Helpers

KeyStorage provides a few methods to help you work with your StorageProvders.

<b>exists</b> - Returns a Boolean if the specified key exists

```swift
let doesExist = keyStoreProvider.exists(forKey: "Hello")
```

<b>removeKey</b> - Removes the stored value for the specified key

```swift
let success = keyStoreProvider.removeKey(forKey: "Hello")
print("was success? \(success)")
```

<b>removeAllKeys</b> - Removes all stored values for the KeyStorage provider

```swift
let success = keyStoreProvider.removeAllKeys()
print("was success? \(success)")
```

## Storage Providers

### KeyStoreDefaultsProvider
The KeyStoreDefaultsProvider storage provider manages persistance to NSUserDefaults.

#### KeyStoreDefaultsProvider - Creation 

The KeyStoreDefaultsProvider can be created with the following optional arguments.

* suiteName : String
<br/>The specified app group name that will be used
```swift
let provider = KeyStoreDefaultsProvider(suiteName: "MyAppGroup")
```

* cryptoProvider : KeyStorageCrypter
<br/>The encryption provider that will be used to encrypt and decrypt key values
```swift
let provider = KeyStoreDefaultsProvider(cryptoProvider: myCryptoProvider)
```

* Combined Example
<br/>You can specify both if you wish to use an encryption provider and implement app group sharing.

```swift
let provider = KeyStoreDefaultsProvider(suiteName: "MyAppGroup", cryptoProvider: myCryptoProvider)
```

### KeyStorageKeyChainProvider
The KeyStorageKeyChainProvider storage provider manages persistance to iOS Keychain.

#### KeyStorageKeyChainProvider - Creation 

The KeyStorageKeyChainProvider can be created with the following optional arguments.

* serviceName : String
<br/>The serviceName used to identify key values stored in the Keychain.
```swift
let provider = KeyStorageKeyChainProvider(serviceName: "myApp")
```

* accessGroup : String
<br/>The Keychain Access Group used to identify key values stored in the Keychain. This must be implemented if you are using Keychain sharing.
```swift
let provider = KeyStorageKeyChainProvider(accessGroup: "myApp")
```

* cryptoProvider : KeyStorageCrypter
<br/>The encryption provider that will be used to encrypt and decrypt key values
```swift
let provider = KeyStorageKeyChainProvider(cryptoProvider: myCryptoProvider)
```

* accessible : KeyChainInfo.accessibleOption
<br/>The accessibility level of the values in the Keychain. See the Keychain documentation [here](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html) for details.
```swift
let provider = KeyStorageKeyChainProvider(accessible: .afterFirstUnlock)
```

* Combined Example
<br/>You can combine all of the above as needed.  Below is an example of this fully implemented.
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
