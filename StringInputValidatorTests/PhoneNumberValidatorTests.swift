//
//  PhoneNumberValidatorTests.swift
//  StringInputValidatorTests
//
//  Created by Bernd Rabe on 16.12.17.
//  Copyright © 2017 RABE_IT Services. All rights reserved.
//

import XCTest
@testable import StringInputValidator

class PhoneNumberValidatorTests: XCTestCase {
    func test_PhoneNumberValidator() {
        let tests: [String: ValidationResult] = ["+49 89 123456": .valid(result: nil),
                                                  "0 30 / 12 34 56": .valid(result: nil),
                                                  "01 58058-0": .valid(result: nil),
                                                  "+43 1 58058-0": .valid(result: nil),
                                                  "+49 (30) 12345 - 67": .valid(result: nil),
                                                  "+49 89 123456 0": .valid(result: nil),
                                                  "+49 89 123456 123": .valid(result: nil),
                                                  "0049 89 1234567": .valid(result: nil),
                                                  "(042) 123 4567": .valid(result: nil),
                                                  "+31 42 123 4567": .valid(result: nil),
                                                  "😩🤬": .invalid(error: .invalidFormat),
                                                  "": .invalid(error: .empty)]
        let validator = PhoneNumberValidator()
        
        for (test, result) in tests {
            let validationResult = validator.validate(value: test)
            XCTAssertEqual(validationResult, result)
        }
        XCTAssertEqual(.invalid(error: .empty), validator.validate(value: nil))
    }
}
