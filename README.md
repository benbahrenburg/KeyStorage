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


## Author

Ben Bahrenburg, [@bencoding](https://twitter.com/bencoding)

## License

KeyStorage is available under the MIT license. See the LICENSE file for more info.
