# StringInputValidator

[![Build Status](https://travis-ci.org/HHuckebein/StringInputValidator.svg?branch=master)](https://travis-ci.org/HHuckebein/StringInputValidator)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov](https://codecov.io/gh/HHuckebein/StringInputValidator/branch/master/graph/badge.svg)](https://codecov.io/gh/HHuckebein/StringInputValidator)
 
StringInputValidator provides a convenient way to test a given string against a validator.
A validator can be as simple the RegularExpressionValidator.numeric which checks wether the string contains numeric values only. Or a complex
validator if you combine length/format validation using a composite validator.
 
## How to use StringInputValidator
```swift
	let lengthVal = LengthValidator(lengthLimit: 5)
    let emptyVal = NotEmptyValidator()
     let numVal = RegularExpressionValidator.numeric
        
    let compVal = CompositeValidator(validators: lengthVal, emptyVal, numVal)
    let res = compVal.validate(value: "absdefgh")

    // ask for validity
    res.isValid()

    // or 
    if case let .invalid(error) = res {
        error.contains(.invalidFormat)
        error.contains(.lengthExceeded)
    } else {}

    // check the description [InvalidFormat, LengthExceeded, LengthMismatch]
    let string = error.description

```

## Installation

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate StringInputValidator into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "HHuckebein/StringInputValidator"
```

Run `carthage` to build the framework and drag the built `StringInputValidator.framework` into your Xcode project.


## Author

RABE_IT Services, development@berndrabe.de

## License

StringInputValidator is available under the MIT license. See the LICENSE file for more info.
