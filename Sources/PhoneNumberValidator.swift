//
//  PhoneNumberValidator.swift
//  StringInputValidator
//
//  Created by Bernd Rabe on 16.12.17.
//  Copyright © 2017 RABE_IT Services. All rights reserved.
//

import Foundation

/// Validates a string containing a phone number against
/// [Wikipedia E.164](https://de.wikipedia.org/wiki/E.164).
///
public struct PhoneNumberValidator: StringValidator {
    /// Validate a string against E.164.
    ///
    /// - Parameter string: input string
    /// - Returns: Validation result.
    public func validate(value string: String?) -> ValidationResult {
        guard let string = string, string.isEmpty == false else { return .invalid(error: .empty) }
        
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        if let matches = detector?.numberOfMatches(in: string, options: .anchored, range: NSRange(location: 0, length: string.count)), matches == 1 {
            return .valid(result: nil)
        } else {
            return .invalid(error: .invalidFormat)
        }
    }
    
    public var description: String {
        return String(describing: self)
    }
}
