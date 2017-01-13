//
//  StringInputValidation.swift
//  OptionSet
//
//  Created by Bernd Rabe on 27.11.16.
//  Copyright © 2016 RABE_IT Services. All rights reserved.
//

import Foundation
 
/** ValidatorError is formed as OptionSetType to be able to report multiple 
 validation results.
 When you extend it, provide additional enum and description values for debugging purposes.
 */
public struct ValidatorError: OptionSet, CustomStringConvertible {
    private enum ValidatorErrorEnum : Int, CustomStringConvertible {
        case invalidFormat  = 1
        case lengthExceeded = 2
        case emptyString    = 4
        case lengthMismatch = 8
        
        var description: String {
            var shift = 0
            while (rawValue >> shift != 1) {
                shift += 1
            }
            return ["InvalidFormat", "LengthExceeded", "EmptyString", "LengthMismatch"][shift]
        }
    }
    
    private init(_ validatorErrorEnum: ValidatorErrorEnum) {
        self.rawValue = validatorErrorEnum.rawValue
    }
    
    // MARK: Public API
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public let rawValue: Int
    
    public static let invalidFormat = ValidatorError(rawValue:  1 << 0)
    public static let lengthExceeded = ValidatorError(rawValue:  1 << 1)
    public static let empty = ValidatorError(rawValue:  1 << 2)
    public static let lengthMismatch = ValidatorError(rawValue:  1 << 3)
    
    public var description: String {
        var result = ""
        var shift = 0
        
        while let value = ValidatorErrorEnum(rawValue: 1 << shift) {
            shift += 1
            if contains(ValidatorError(value)) {
                result += result.isEmpty ? "\(value)" : ", \(value)"
            }
        }
        
        return "[\(result)]"
    }
}
 
public enum ValidatorResult {
    case valid
    case invalid(error: ValidatorError)
    
    public var isValid: Bool {
        switch self {
        case .valid:             return true
        case .invalid(error: _): return false
        }
    }
}
 
/** StringValidator Protocol
 
 - parameter value: An optional string
 - returns: An option set of type `ValidatorResult`. In case of
 a non existing `value` returns .empty.
 */
public protocol StringValidator: CustomStringConvertible {
    func validate(value string: String?) -> ValidatorResult
}

/** A CompositeValidator allows for chaining or nesting of
 several validators. Individual validators can add their
 .invalid error to the total result.
 */
public struct CompositeValidator: StringValidator {
    private let validators: [StringValidator]
    
    public init(validators: StringValidator...) {
        self.validators = validators
    }
    
    public func validate(value string: String?) -> ValidatorResult {
        var validatorResult = ValidatorError()
        
        for validator in validators {
            switch validator.validate(value: string) {
            case .valid: continue
            case .invalid(let error): validatorResult.insert(error)
            }
        }
        
        return  validatorResult.rawValue > 0 ? .invalid(error: validatorResult) : .valid
    }
    
    public var description: String {
        let desc = "\(String(describing: CompositeValidator.self)):"
        return validators.reduce(desc, { $0 + " \($1),"})
    }
}

// MARK: - LengthValidator

/** LengthValidator can return several results, e.g.
 for cases where the characters count is greater than zero
 * .lengthMismatch - if the count is unequal to lengthBorder
 * .lengthExceeded - if the count is greater than lengthBorder
 
 The last two ValidatorResults might appear in combination.
 */
public struct LengthValidator: StringValidator, Equatable {
    let lengthLimit: Int
    public func validate(value string: String?) -> ValidatorResult {
        guard let text = string else {
            return .invalid(error: .lengthMismatch)
        }
 
        let count = text.characters.count
        if count > lengthLimit {
            return .invalid(error: [.lengthExceeded, .lengthMismatch])
        } else if count != lengthLimit {
            return .invalid(error: .lengthMismatch)
        } else {
            return .valid
        }
    }
    
    public init(lengthLimit: Int) {
        self.lengthLimit = lengthLimit
    }
    
    public var description: String {
        return "LengthLimit: \(lengthLimit)"
    }
}
 
public func ==(lhs: LengthValidator, rhs: LengthValidator) -> Bool {
    return lhs.lengthLimit == rhs.lengthLimit
}
 
// MARK: - RegularExpressionValidator's

/** Create a RegularExpressionStringValidator with a regular expression pattern.
 There are some predefined validators available in the extension.
 */
 
public struct RegularExpressionValidator: StringValidator, Equatable {
    let regex: NSRegularExpression
    
    public init?(withPattern pattern: String) {
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        } catch {
            print("Creating NSRegularExpression for \(pattern) failed with \(error)")
            return nil
        }
    }
    
    public func validate(value string: String?) -> ValidatorResult {
        guard let text = string else {
            return .invalid(error: .invalidFormat)
        }
 
        let numberOfMatches = regex.numberOfMatches(in: text, options: .anchored, range: NSMakeRange(0, text.characters.count))
        if text.characters.count > 0 && numberOfMatches == 0 {
            return .invalid(error: .invalidFormat)
        } else {
            return .valid
        }
    }
    
    public var description: String {
        return "RegEX: \(regex.pattern)"
    }
}

public func ==(lhs: RegularExpressionValidator, rhs: RegularExpressionValidator) -> Bool {
    return lhs.regex.pattern == rhs.regex.pattern
}
 
// MARK: Preconfigured RegularExpressionValidator's

public extension RegularExpressionValidator {
    public static var numeric = RegularExpressionValidator(withPattern: "^[0-9]*$")!
    public static var alphaNumeric = RegularExpressionValidator(withPattern: "^[0-9a-zA-Z]*$")!
}
 
// MARK: - NotEmptyValidator

public struct NotEmptyValidator: StringValidator, Equatable {
    public init() {}
    public func validate(value string: String?) -> ValidatorResult {
        if let text = string, text.isEmpty == false {
            return .valid
        } else {
            return .invalid(error: .empty)
        }
    }
    
    public var description: String {
        return "NotEmpty"
    }
}
 
public func ==(lhs: NotEmptyValidator, rhs: NotEmptyValidator) -> Bool {
    return true
}
