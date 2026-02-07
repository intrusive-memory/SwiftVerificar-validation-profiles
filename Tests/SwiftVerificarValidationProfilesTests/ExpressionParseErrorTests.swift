import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ExpressionParseError Tests")
struct ExpressionParseErrorTests {

    // MARK: - Error Description Tests

    @Test("emptyExpression has correct description")
    func emptyExpressionDescription() {
        let error = ExpressionParseError.emptyExpression
        #expect(error.errorDescription == "Expression is empty")
        #expect(error.description == "Expression is empty")
    }

    @Test("unexpectedToken has correct description")
    func unexpectedTokenDescription() {
        let error = ExpressionParseError.unexpectedToken(expected: "identifier", found: "+", position: 5)
        #expect(error.errorDescription == "Unexpected token at position 5: expected identifier, found '+'")
    }

    @Test("unexpectedCharacter has correct description")
    func unexpectedCharacterDescription() {
        let error = ExpressionParseError.unexpectedCharacter(character: "@", position: 10)
        #expect(error.errorDescription == "Unexpected character '@' at position 10")
    }

    @Test("unexpectedEndOfInput has correct description")
    func unexpectedEndOfInputDescription() {
        let error = ExpressionParseError.unexpectedEndOfInput(expected: "operand")
        #expect(error.errorDescription == "Unexpected end of input: expected operand")
    }

    @Test("unterminatedString has correct description")
    func unterminatedStringDescription() {
        let error = ExpressionParseError.unterminatedString(position: 15)
        #expect(error.errorDescription == "Unterminated string literal starting at position 15")
    }

    @Test("unterminatedRegex has correct description")
    func unterminatedRegexDescription() {
        let error = ExpressionParseError.unterminatedRegex(position: 20)
        #expect(error.errorDescription == "Unterminated regex literal starting at position 20")
    }

    @Test("invalidNumber has correct description")
    func invalidNumberDescription() {
        let error = ExpressionParseError.invalidNumber(text: "12.34.56", position: 0)
        #expect(error.errorDescription == "Invalid number '12.34.56' at position 0")
    }

    @Test("invalidOperator has correct description")
    func invalidOperatorDescription() {
        let error = ExpressionParseError.invalidOperator(text: "&", position: 3)
        #expect(error.errorDescription == "Invalid operator '&' at position 3")
    }

    @Test("invalidEscapeSequence has correct description")
    func invalidEscapeSequenceDescription() {
        let error = ExpressionParseError.invalidEscapeSequence(sequence: "\\x", position: 5)
        #expect(error.errorDescription == "Invalid escape sequence '\\x' at position 5")
    }

    @Test("divisionByZero has correct description")
    func divisionByZeroDescription() {
        let error = ExpressionParseError.divisionByZero
        #expect(error.errorDescription == "Division by zero in constant expression")
    }

    @Test("maxDepthExceeded has correct description")
    func maxDepthExceededDescription() {
        let error = ExpressionParseError.maxDepthExceeded(depth: 100)
        #expect(error.errorDescription == "Maximum expression depth exceeded (100)")
    }

    // MARK: - Equality Tests

    @Test("same errors are equal")
    func equalErrors() {
        #expect(ExpressionParseError.emptyExpression == ExpressionParseError.emptyExpression)
        #expect(ExpressionParseError.divisionByZero == ExpressionParseError.divisionByZero)

        let error1 = ExpressionParseError.unexpectedToken(expected: "a", found: "b", position: 1)
        let error2 = ExpressionParseError.unexpectedToken(expected: "a", found: "b", position: 1)
        #expect(error1 == error2)
    }

    @Test("different errors are not equal")
    func differentErrors() {
        #expect(ExpressionParseError.emptyExpression != ExpressionParseError.divisionByZero)

        let error1 = ExpressionParseError.unexpectedToken(expected: "a", found: "b", position: 1)
        let error2 = ExpressionParseError.unexpectedToken(expected: "a", found: "c", position: 1)
        #expect(error1 != error2)
    }

    // MARK: - Hashable Tests

    @Test("ExpressionParseError is hashable")
    func hashable() {
        let set: Set<ExpressionParseError> = [
            .emptyExpression,
            .divisionByZero,
            .unexpectedToken(expected: "x", found: "y", position: 0),
            .maxDepthExceeded(depth: 100)
        ]
        #expect(set.count == 4)
    }

    // MARK: - Error Protocol Tests

    @Test("ExpressionParseError conforms to Error")
    func conformsToError() {
        let error: Error = ExpressionParseError.emptyExpression
        #expect(error is ExpressionParseError)
    }

    @Test("ExpressionParseError conforms to LocalizedError")
    func conformsToLocalizedError() {
        let error: LocalizedError = ExpressionParseError.emptyExpression
        #expect(error.errorDescription != nil)
    }

    // MARK: - Description Consistency Tests

    @Test("description matches errorDescription")
    func descriptionMatchesErrorDescription() {
        let errors: [ExpressionParseError] = [
            .emptyExpression,
            .unexpectedToken(expected: "a", found: "b", position: 0),
            .unexpectedCharacter(character: "@", position: 0),
            .unexpectedEndOfInput(expected: "value"),
            .unterminatedString(position: 0),
            .unterminatedRegex(position: 0),
            .invalidNumber(text: "abc", position: 0),
            .invalidOperator(text: "&", position: 0),
            .invalidEscapeSequence(sequence: "\\z", position: 0),
            .divisionByZero,
            .maxDepthExceeded(depth: 50)
        ]

        for error in errors {
            #expect(error.description == error.errorDescription)
        }
    }
}
