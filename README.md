# LayoutLoopHunter

[![CI Status](https://img.shields.io/travis/rsrbk/LayoutLoopHunter.svg?style=flat)](https://travis-ci.org/rsrbk/LayoutLoopHunter)
[![Version](https://img.shields.io/cocoapods/v/LayoutLoopHunter.svg?style=flat)](https://cocoapods.org/pods/LayoutLoopHunter)
[![License](https://img.shields.io/cocoapods/l/LayoutLoopHunter.svg?style=flat)](https://cocoapods.org/pods/LayoutLoopHunter)
[![Platform](https://img.shields.io/cocoapods/p/LayoutLoopHunter.svg?style=flat)](https://cocoapods.org/pods/LayoutLoopHunter)

![img](https://cdn-images-1.medium.com/max/1600/0*zrLTiLtPpTx3nb9-.jpg)

The library helps to catch the OOMs caused by Autolayout Feedback Loop by replicating the behavior of `UIViewLayoutFeedbackLoopDebuggingThreshold` in the live code.

This is the final result of the runtime tutorial on [AppCoda](https://www.appcoda.com/layout-feedback-loop/).

## Installation

LayoutLoopHunter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LayoutLoopHunter'
```
and run `pod install` in your terminal.

Alternatively, you can manually add the files from the `LayoutLoopHunter` directory to your project.

## Usage

Please use the `setUp` method to set up tracking for your UIView:
```swift
static func setUp(for view: UIView, threshold: Int = 100, onLoop: @escaping () -> ())
```
The callback will be called when the `layoutSubviews()` method is called a certain amount of times in a single run loop.

## Example

```swift
LayoutLoopHunter.setUp(for: view) {
    print("Hello, world")
}
```
## Author

Ruslan Serebriakov

Twitter: [@rsrbk123](https://twitter.com/rsrbk123)

## Check out my other libraries

[SmileToUnlock](https://github.com/rsrbk/SRCountdownTimer) - this library uses ARKit Face Tracking in order to catch a user's smile..<br>
[SRCountdownTimer](https://github.com/rsrbk/SRCountdownTimer) - a simple circle countdown with a configurable timer.<br>
[SRAttractionsMap](https://github.com/rsrbk/SRAttractionsMap) - the map with attractions on which you can click and see the full description.

## License

MIT License

Copyright (c) 2019 Ruslan Serebriakov <rsrbk1@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
