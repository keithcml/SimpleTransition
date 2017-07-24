# SimpleTransition

[![CI Status](http://img.shields.io/travis/Keith/SimpleTransition.svg?style=flat)](https://travis-ci.org/Keith/SimpleTransition)
[![Version](https://img.shields.io/cocoapods/v/SimpleTransition.svg?style=flat)](http://cocoapods.org/pods/SimpleTransition)
[![License](https://img.shields.io/cocoapods/l/SimpleTransition.svg?style=flat)](http://cocoapods.org/pods/SimpleTransition)
[![Platform](https://img.shields.io/cocoapods/p/SimpleTransition.svg?style=flat)](http://cocoapods.org/pods/SimpleTransition)

## Demo
![Demo](https://img.youtube.com/vi/bUai3MLJcNA/0.jpg)(https://www.youtube.com/watch?v=bUai3MLJcNA)

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 8.0+

## Installation

SimpleTransition is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SimpleTransition"
```

via Carthage
```
github "MingLoan/SimpleTransition"
```

## Usage

```
// init SimpleTransitionDelegate with presenting and presented view controller
let simpleTransitionDelegate = SimpleTransition(presentingViewController: self, presentedViewController: presentedViewCtl)

// setup delegate with options
simpleTransitionDelegate.setup(
            animation,
            alignment: alignment,
            motion: motion,
            presentingViewSize: presentingViewSize)
            
// assign simpleTransitionDelegate to presented view controller
presentedViewCtl.simpleTransitionDelegate = simpleTransitionDelegate

// call UIKit present method       
present(presentedViewCtl, animated: true, completion: nil)
        
```

## Author

Mingloan, mingloanchan@gmail.com

## License

SimpleTransition is available under the MIT license. See the LICENSE file for more info.
