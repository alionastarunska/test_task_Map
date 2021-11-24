# ViewState

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Version](https://img.shields.io/cocoapods/v/ViewState.svg?style=flat)](http://cocoapods.org/pods/ViewState)
[![License](https://img.shields.io/cocoapods/l/ViewState.svg?style=flat)](http://cocoapods.org/pods/ViewState)
[![Platform](https://img.shields.io/cocoapods/p/ViewState.svg?style=flat)](http://cocoapods.org/pods/ViewState)
[![CI Status](http://img.shields.io/travis/APUtils/ViewState.svg?style=flat)](https://travis-ci.org/APUtils/ViewState)

Adds an ability to check current view controller's view state and also to subscribe to view state changes notifications. Also, adds several helpful properties to easily configure some complex behaviors in xibs and storyboards.

## Example

Clone the repo and then open `Carthage Project/ViewState.xcodeproj`

## Installation

#### Carthage

Please check [official guide](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)

Cartfile:

```
github "APUtils/ViewState" ~> 1.2
```

#### CocoaPods

ViewState is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ViewState', '~> 1.2'
```

#### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding `ViewState` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`.

**⚠️ WARNING** You must call `ViewState.setupOnce()` somewhere in you code or it won't work. The issue is that SPM doesn't support mixed source code and the framework can't load himself without Objective-C part.

```swift
dependencies: [
    .package(url: "https://github.com/APUtils/ViewState.git", .upToNextMajor(from: "1.2.1"))
]
```

## Usage

#### UIViewController subclasses

- Extends UIViewController with .viewState enum property. Possible cases: `.notLoaded`, `.didLoad`, `.willAppear`, `.didAppear`, `.willDisappear`, `.didDisappear`.
- Every UIViewController starts to send notifications about its state change. Available notifications to observe: `.UIViewControllerWillMoveToParentViewController`, `.UIViewControllerViewDidLoad`, `.UIViewControllerViewWillAppear`, `.UIViewControllerViewDidAppear`, `.UIViewControllerViewWillDisappear`, `.UIViewControllerViewDidDisappear`. You could check `userInfo` notification's dictionary for parameters if needed.
- Adds `.hideKeyboardOnTouch` @IBInspectable property to hide keyboard on touch outside.

#### UIResponder subclasses

- Adds `.becomeFirstResponderOnViewDidAppear` @IBInspectable property to become first responser on `viewDidAppear`.

#### UIScrollView subclasses

- Adds `.flashScrollIndicatorsOnViewDidAppear` @IBInspectable property to flash scroll indicators on `viewDidAppear`.

See example and test projects for more details.

## Contributions

Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

## Author

Anton Plebanovich, anton.plebanovich@gmail.com

## License

ViewState is available under the MIT license. See the LICENSE file for more info.
