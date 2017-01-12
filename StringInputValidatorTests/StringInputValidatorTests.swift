//
//  StringInputValidatorTests.swift
//  StringInputValidatorTests
//
//  Created by Bernd Rabe on 12.01.17.
//  Copyright © 2017 RABE_IT Services. All rights reserved.
//

import XCTest
@testable import StringInputValidator

class StringInputValidatorTests: XCTestCase {
    
    func test_CompositeValidator() {
        let lengthVal = LengthValidator(lengthLimit: 5)
        let emptyVal = NotEmptyValidator()
        
        let sut = CompositeValidator(validators: lengthVal, emptyVal)
        
        let res = sut.validate(value: "")
        XCTAssert(res.isValid == false)
        if case let .invalid(error) = res {
            XCTAssert(error.contains(.empty))
            XCTAssert(error.contains(.lengthMismatch))
        } else {
            XCTFail("Expected .invalid")
        }
        
        let numVal = RegularExpressionValidator.numeric
        let sut1 = CompositeValidator(validators: numVal, sut)
        let res2 = sut1.validate(value: "absdefgh")
        XCTAssert(res2.isValid == false)
        if case let .invalid(error) = res2 {
            XCTAssert(error.contains(.invalidFormat))
            XCTAssert(error.contains(.lengthExceeded))
        } else {
            XCTFail("Expected .invalid")
        }
    }
    
    // MARK: - RegularExpressionValidator
    
    func test_NumericStringValidator() {
        let numericValidator = RegularExpressionValidator.numeric
        XCTAssert(numericValidator.validate(value: "01234").isValid)
        XCTAssert(numericValidator.validate(value: nil).isValid == false)
        
        let result = numericValidator.validate(value: "01x234")
        XCTAssert(result.isValid == false)
        if case let .invalid(error) = result {
            XCTAssert(error == .invalidFormat)
        } else {
            XCTFail("Expected .invalid")
        }
    }

    func test_RegularExpressionValidator_EquatableConformance() {
        let val = RegularExpressionValidator.numeric
        let val1 = RegularExpressionValidator.alphaNumeric
        XCTAssertFalse(val == val1)
    }
    
    func test_RegularExpressionValidator_Description() {
        let val = RegularExpressionValidator.numeric
        XCTAssertTrue(val.description.contains("RegEX: "))
    }
    
    // MARK: - LengthValidator
    
    func test_LengthValidator_isValid_CorrectLength() {
        let sut = LengthValidator(lengthLimit: 5)
        
        let res = sut.validate(value: "01234")
        XCTAssertTrue(res.isValid == true)
    }
    
    func test_LengthValidator_NotValid_NilValue() {
        let sut = LengthValidator(lengthLimit: 5)
        
        let res = sut.validate(value: nil)
        XCTAssertTrue(res.isValid == false)
    }
    
    func test_LengthValidator_invalid_LengthMismatchAndLengthExceeded() {
        let sut = LengthValidator(lengthLimit: 5)
        
        let res = sut.validate(value: "0123456789")
        
        if case let .invalid(error) = res {
            XCTAssertTrue(error.contains(.lengthMismatch) == true)
            XCTAssertTrue(error.contains(.lengthExceeded) == true)
        } else {
            XCTFail("Expected .invalid with")
        }
    }
    
    func test_LengthValidator_invalid_LengthMismatch() {
        let sut = LengthValidator(lengthLimit: 5)
        
        let res = sut.validate(value: "")
        if case let .invalid(error) = res {
            XCTAssertTrue(error.contains(.lengthMismatch) == true)
        } else {
            XCTFail("Expected .invalid")
        }
    }
    
    func test_LengthValidator_EquatableConformance() {
        let val = LengthValidator(lengthLimit: 5)
        let val1 = LengthValidator(lengthLimit: 5)
        let val2 = LengthValidator(lengthLimit: 10)
        XCTAssertTrue(val == val1)
        XCTAssertFalse(val == val2)
    }
    
    func test_LengthValidator_Description() {
        let val = LengthValidator(lengthLimit: 5)
        XCTAssertTrue(val.description == "LengthLimit: 5")
    }
}
