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
 
 **When you extend it, provide additional enum and description values for debugging purposes.**
 */
public struct ValidatorError: OptionSet, CustomStringConvertible {
    private enum ValidatorErrorEnum : Int, CustomStringConvertible {
        /** The corresponding enum for the invalidFormat error. */
        case invalidFormat  = 1
        
        /** The corresponding enum for the lengthExceeded error. */
        case lengthExceeded = 2
        
        /** The corresponding enum for the invalidemptyStringFormat error. */
        case emptyString    = 4
        
        /** The corresponding enum for the lengthMismatch error. */
        case lengthMismatch = 8
        
        /** CustomStringConvertible conformance */
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
    
    /** Returned by `RegularExpressionValidator` if input string does not conform to the regex pattern. */
    public static let invalidFormat = ValidatorError(rawValue:  1 << 0)
    
    /** Returned by `LengthValidator` characters count is greater than `lengthLimit`. */
    public static let lengthExceeded = ValidatorError(rawValue:  1 << 1)
    
    /** Returned by `LengthValidator` if characters count is unequal to `lengthLimit`. */
    public static let lengthMismatch = ValidatorError(rawValue:  1 << 3)
    
    /** Returned by `NotEmptyValidator` if validation fails. */
    public static let empty = ValidatorError(rawValue:  1 << 2)
    
    /** CustomStringConvertible conformance */
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
    /** Return if validation succeeds. */
    case valid
    
    /** If validation fails for one of the validators.
     Associated value is `ValidatorError`
     */
    case invalid(error: ValidatorError)
    
    /** Convenience function to check wether
     the string is valid according to the validators assigned.
     */
    public var isValid: Bool {
        switch self {
        case .valid:             return true
        case .invalid(error: _): return false
        }
    }
    
    /** Returns wether the validation result contains .empty
     */
    public var isEmpty: Bool {
        return checkContainment(for: .empty, checkAgainst: true)
    }
    
    /** Returns wether the validation result contains .lengthExceeded.
     */
    public var hasMaxLengthExceeded: Bool {
        return checkContainment(for: .lengthExceeded, checkAgainst: true)
    }
    
    /** Returns wether the validation result contains .lengthMismatch.
     */
    public var hasLengthMismatch: Bool {
        return checkContainment(for: .lengthMismatch, checkAgainst: true)
    }
    
    /** Returns wether the validation result contains .lengthMismatch.
     */
    public var containsOnlyValidCharacters: Bool {
        return checkContainment(for: .invalidFormat, checkAgainst: false)
    }
    
    private func checkContainment(for error: ValidatorError, checkAgainst condition: Bool) -> Bool {
        switch self {
        case .valid: return !condition
        case .invalid(error: let error): return error.contains(error) == condition
        }
    }
}

/** StringValidator Protocol. */
public protocol StringValidator: CustomStringConvertible {
    /** The validation function every validator has to implement.
     
     - parameter value: An optional input string.
     - returns: An option set of type `ValidatorResult`.
     In case of a non existing `value` returns .empty.
     */
    func validate(value string: String?) -> ValidatorResult
}

/** A CompositeValidator allows for chaining or nesting of
 several validators. Individual validators can add their own
 .invalid error to the total result.
 */
public struct CompositeValidator: StringValidator {
    private let validators: [StringValidator]
    
    /** Initializer accepts single as well as a composite validators. */
    public init(validators: StringValidator...) {
        self.validators = validators
    }
    
    /** Traverses all validators and asks for the validation result.
     Individual results will be added. Independent of a single result
     all validators will be asked to return their validation result.
     */
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
    
    /** CustomStringConvertible conformance */
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
    
    /** Validate the string for, wether characters count
     matches or exceeds the lengthLimit.
     */
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
    
    /** Lengthvalidator initializer.
     
     - parameter lengthLimit: Marks the maximum acceptable length
     before the validator returns a .lengthExceeded validation result.
     */
    public init(lengthLimit: Int) {
        self.lengthLimit = lengthLimit
    }
    
    /** CustomStringConvertible conformance */
    public var description: String {
        return "LengthLimit: \(lengthLimit)"
    }
}

/** Equatable conformance */
public func ==(lhs: LengthValidator, rhs: LengthValidator) -> Bool {
    return lhs.lengthLimit == rhs.lengthLimit
}

// MARK: - RegularExpressionValidator's

/** Create a RegularExpressionStringValidator with a regular expression pattern.
 There are some predefined validators available in the extension.
 */

public struct RegularExpressionValidator: StringValidator, Equatable {
    let regex: NSRegularExpression
    
    /** RegularExpression Validators return nil if the pattern can not
     be transformed into a valid regular expression.
     
     - parameter pattern: The reqular expression pattern.
     */
    public init?(withPattern pattern: String) {
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        } catch {
            print("Creating NSRegularExpression for \(pattern) failed with \(error)")
            return nil
        }
    }
    
    /** Validates the string according to the pattern. */
    public func validate(value string: String?) -> ValidatorResult {
        guard let text = string else {
            return .invalid(error: .invalidFormat)
        }
        
        let numberOfMatches = regex.numberOfMatches(in: text, options: .anchored, range: NSMakeRange(0, text.count))
        if text.count > 0 && numberOfMatches == 0 {
            return .invalid(error: .invalidFormat)
        } else {
            return .valid
        }
    }
    
    /** CustomStringConvertible conformance */
    public var description: String {
        return "RegEX: \(regex.pattern)"
    }
}

/** Equatable conformance */
public func ==(lhs: RegularExpressionValidator, rhs: RegularExpressionValidator) -> Bool {
    return lhs.regex.pattern == rhs.regex.pattern
}

// MARK: Preconfigured RegularExpressionValidator's

public extension RegularExpressionValidator {
    /** An Inputvalidator which checks for numbers only. */
    public static var numeric = RegularExpressionValidator(withPattern: "^[0-9]*$")!
    
    /** An Inputvalidator which checks for numbers and characters ranging from a-z/A-Z only. */
    public static var alphaNumeric = RegularExpressionValidator(withPattern: "^[0-9a-zA-Z]*$")!
}

// MARK: - NotEmptyValidator

/** Check wether a string exists and is not empty. */
public struct NotEmptyValidator: StringValidator, Equatable {
    
    public init() {}
    
    /** Returns .empty if the string is nil or contains no character. */
    public func validate(value string: String?) -> ValidatorResult {
        if let text = string, text.isEmpty == false {
            return .valid
        } else {
            return .invalid(error: .empty)
        }
    }
    
    /** CustomStringConvertible conformance */
    public var description: String {
        return "NotEmpty"
    }
}

/** Equatable conformance */
public func ==(lhs: NotEmptyValidator, rhs: NotEmptyValidator) -> Bool {
    return true
}
