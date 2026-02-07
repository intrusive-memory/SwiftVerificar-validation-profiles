import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("EvaluationError Tests")
struct EvaluationErrorTests {

    // MARK: - Error Description Tests

    @Test("unknownIdentifier has correct description")
    func unknownIdentifierDescription() {
        let error = EvaluationError.unknownIdentifier(name: "myVar")
        #expect(error.errorDescription == "Unknown identifier: myVar")
        #expect(error.description == "Unknown identifier: myVar")
    }

    @Test("unknownFunction has correct description")
    func unknownFunctionDescription() {
        let error = EvaluationError.unknownFunction(name: "foo")
        #expect(error.errorDescription == "Unknown function: foo")
    }

    @Test("typeMismatch has correct description")
    func typeMismatchDescription() {
        let error = EvaluationError.typeMismatch(operation: "addition", expected: "number", found: "string")
        #expect(error.errorDescription == "Type mismatch in addition: expected number, found string")
    }

    @Test("divisionByZero has correct description")
    func divisionByZeroDescription() {
        let error = EvaluationError.divisionByZero
        #expect(error.errorDescription == "Division by zero")
    }

    @Test("indexOutOfBounds has correct description")
    func indexOutOfBoundsDescription() {
        let error = EvaluationError.indexOutOfBounds(index: 5, count: 3)
        #expect(error.errorDescription == "Index out of bounds: 5 (array size: 3)")
    }

    @Test("invalidRegex has correct description")
    func invalidRegexDescription() {
        let error = EvaluationError.invalidRegex(pattern: "[invalid")
        #expect(error.errorDescription == "Invalid regular expression: [invalid")
    }

    @Test("invalidArgumentCount has correct description")
    func invalidArgumentCountDescription() {
        let error = EvaluationError.invalidArgumentCount(function: "split", expected: 2, found: 1)
        #expect(error.errorDescription == "Invalid argument count for split: expected 2, found 1")
    }

    @Test("nullReference has correct description")
    func nullReferenceDescription() {
        let error = EvaluationError.nullReference(operation: "member access")
        #expect(error.errorDescription == "Null reference in member access")
    }

    @Test("maxDepthExceeded has correct description")
    func maxDepthExceededDescription() {
        let error = EvaluationError.maxDepthExceeded(depth: 100)
        #expect(error.errorDescription == "Maximum recursion depth exceeded (100)")
    }

    // MARK: - Equality Tests

    @Test("same errors are equal")
    func equalErrors() {
        #expect(EvaluationError.divisionByZero == EvaluationError.divisionByZero)

        let error1 = EvaluationError.unknownIdentifier(name: "x")
        let error2 = EvaluationError.unknownIdentifier(name: "x")
        #expect(error1 == error2)

        let error3 = EvaluationError.indexOutOfBounds(index: 5, count: 3)
        let error4 = EvaluationError.indexOutOfBounds(index: 5, count: 3)
        #expect(error3 == error4)
    }

    @Test("different errors are not equal")
    func differentErrors() {
        #expect(EvaluationError.divisionByZero != EvaluationError.unknownIdentifier(name: "x"))

        let error1 = EvaluationError.unknownIdentifier(name: "x")
        let error2 = EvaluationError.unknownIdentifier(name: "y")
        #expect(error1 != error2)

        let error3 = EvaluationError.indexOutOfBounds(index: 5, count: 3)
        let error4 = EvaluationError.indexOutOfBounds(index: 6, count: 3)
        #expect(error3 != error4)
    }

    // MARK: - Hashable Tests

    @Test("EvaluationError is hashable")
    func hashable() {
        let set: Set<EvaluationError> = [
            .divisionByZero,
            .unknownIdentifier(name: "x"),
            .unknownFunction(name: "foo"),
            .indexOutOfBounds(index: 0, count: 0),
            .maxDepthExceeded(depth: 100)
        ]
        #expect(set.count == 5)
    }

    // MARK: - Error Protocol Tests

    @Test("EvaluationError conforms to Error")
    func conformsToError() {
        let error: Error = EvaluationError.divisionByZero
        #expect(error is EvaluationError)
    }

    @Test("EvaluationError conforms to LocalizedError")
    func conformsToLocalizedError() {
        let error: LocalizedError = EvaluationError.divisionByZero
        #expect(error.errorDescription != nil)
    }

    // MARK: - Description Consistency Tests

    @Test("description matches errorDescription")
    func descriptionMatchesErrorDescription() {
        let errors: [EvaluationError] = [
            .unknownIdentifier(name: "test"),
            .unknownFunction(name: "func"),
            .typeMismatch(operation: "op", expected: "a", found: "b"),
            .divisionByZero,
            .indexOutOfBounds(index: 1, count: 0),
            .invalidRegex(pattern: ".*"),
            .invalidArgumentCount(function: "f", expected: 1, found: 2),
            .nullReference(operation: "test"),
            .maxDepthExceeded(depth: 50)
        ]

        for error in errors {
            #expect(error.description == error.errorDescription)
        }
    }
}
