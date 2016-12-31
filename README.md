# KeyStorage
Save key information quickly, easily, and securely.  KeyStorage is a type safe persistance layer built on top of the iOS KeyChain and NSUserDefaults.

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

## KeyStorage Save Options

Each of the KeyStorage providers has a variety of type safe options to save key information.  Please visit the [wiki](https://github.com/benbahrenburg/KeyStorage/wiki/KeyStorage---Save-Options) for more details.

        
## KeyStorage Return Options

Each of the KeyStorage providers has a variety of type safe options to read key information.  Please visit the [wiki](https://github.com/benbahrenburg/KeyStorage/wiki/KeyStorage---Read-Options) for more details.

## KeyStorage Working Options

<b>exists</b>

<b>removeKey</b>

<b>removeAllKeys</b>

## KeyStoreDefaultsProvider
The KeyStoreDefaultsProvider storage provider manages persistance to NSUserDefaults.

### KeyStoreDefaultsProvider - Creation 

The KeyStoreDefaultsProvider can be created with the following optional arguments.

<b>suiteName</b> : String

The specified app group name that will be used

<b>cryptoProvider</b> : String

The encryption provider that will be used to encrypt and decrypt key values

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
