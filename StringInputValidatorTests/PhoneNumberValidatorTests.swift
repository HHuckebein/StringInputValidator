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
        let numbers: [String?] = ["+49 89 123456", "0 30 / 12 34 56", "01 58058-0", "+43 1 58058-0", "+49 (30) 12345 - 67", "+49 89 123456 0", "+49 89 123456 123", "0049 89 1234567", "(042) 123 4567", "+31 42 123 4567", "😩🤬", "", nil]
        let result: [ValidatorResult] = [.valid, .valid, .valid, .valid, .valid, .valid, .valid, .valid, .valid, .valid, .invalid(error: .invalidFormat), .invalid(error: .empty), .invalid(error: .empty)]
        let validator = PhoneNumberValidator()
        
        for (index, number) in numbers.enumerated() {
            let validationResult = validator.validate(value: number)
            XCTAssertEqual(validationResult, result[index])
        }
    }
}
