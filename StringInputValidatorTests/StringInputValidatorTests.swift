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
    
    func test_CompositeValidator_Failure() {
        let lengthVal = LengthValidator(lengthLimit: 5)
        let emptyVal = NotEmptyValidator()
        
        let sut = CompositeValidator(validators: lengthVal, emptyVal)
        
        let res = sut.validate(value: "")
        XCTAssertFalse(res.isValid)
        if case let .invalid(error) = res {
            XCTAssert(error.contains(.empty))
            XCTAssert(error.contains(.lengthMismatch))
        } else {
            XCTFail("Expected .invalid")
        }

        let numVal = RegularExpressionValidator.numeric
        let sut1 = CompositeValidator(validators: numVal, sut)
        let res2 = sut1.validate(value: "absdefgh")
        XCTAssertFalse(res2.isValid)
        if case let .invalid(error) = res2 {
            XCTAssert(error.contains(.invalidFormat))
            XCTAssert(error.contains(.lengthExceeded))
            print(error.description)
            XCTAssertTrue(error.description == "[InvalidFormat, LengthExceeded, LengthMismatch]")
        } else {
            XCTFail("Expected .invalid")
        }
    }
    
    func test_CompositeValidator_Success() {
        let lengthVal = LengthValidator(lengthLimit: 5)
        let emptyVal = NotEmptyValidator()
        
        let sut = CompositeValidator(validators: lengthVal, emptyVal)
        let res = sut.validate(value: "12345")
        XCTAssertTrue(res.isValid)
    }
    
    func test_CompositeValidator_Description() {
        let lengthVal = LengthValidator(lengthLimit: 5)
        let emptyVal = NotEmptyValidator()
        
        let sut = CompositeValidator(validators: lengthVal, emptyVal)
        XCTAssertTrue(sut.description == "CompositeValidator: LengthLimit: 5, NotEmpty,")
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
    
    func test_RegularExpressionValidator_wrongRegEX() {
        XCTAssertNil(RegularExpressionValidator(withPattern: ""))
    }
    
    // MARK: - NotEmptyValidator
    
    func test_NotEmptyValidator_Success() {
        let val = NotEmptyValidator()
        let result = val.validate(value: "01x234")
        XCTAssertTrue(result.isValid)
    }
    
    func test_NotEmptyValidator_Empty() {
        let val = NotEmptyValidator()
        XCTAssertFalse(val.validate(value: "").isValid)
        XCTAssertFalse(val.validate(value: nil).isValid)
    }
    
    func test_NotEmptyValidator_EquatableConformance() {
        let val = NotEmptyValidator()
        let val1 = NotEmptyValidator()
        XCTAssertTrue(val == val1)
    }
    
    // MARK: - LengthValidator
    
    func test_LengthValidator_isValid_CorrectLength() {
        let sut = LengthValidator(lengthLimit: 5)
        
        let res = sut.validate(value: "01234")
        XCTAssertTrue(res.isValid)
    }
    
    func test_LengthValidator_NotValid_NilValue() {
        let sut = LengthValidator(lengthLimit: 5)
        
        let res = sut.validate(value: nil)
        XCTAssertFalse(res.isValid)
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
