import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ExpressionToken Tests")
struct ExpressionTokenTests {

    // MARK: - Description Tests

    @Test("null description")
    func nullDescription() {
        #expect(ExpressionToken.null.description == "null")
    }

    @Test("bool literal descriptions")
    func boolLiteralDescriptions() {
        #expect(ExpressionToken.boolLiteral(true).description == "true")
        #expect(ExpressionToken.boolLiteral(false).description == "false")
    }

    @Test("int literal description")
    func intLiteralDescription() {
        #expect(ExpressionToken.intLiteral(42).description == "42")
        #expect(ExpressionToken.intLiteral(-5).description == "-5")
    }

    @Test("double literal description")
    func doubleLiteralDescription() {
        #expect(ExpressionToken.doubleLiteral(3.14).description == "3.14")
    }

    @Test("string literal description")
    func stringLiteralDescription() {
        #expect(ExpressionToken.stringLiteral("hello").description == "\"hello\"")
    }

    @Test("regex literal description")
    func regexLiteralDescription() {
        #expect(ExpressionToken.regexLiteral("^[a-z]+$").description == "/^[a-z]+$/")
    }

    @Test("identifier description")
    func identifierDescription() {
        #expect(ExpressionToken.identifier("myVar").description == "myVar")
    }

    @Test("operator description")
    func operatorDescription() {
        #expect(ExpressionToken.operator("==").description == "==")
        #expect(ExpressionToken.operator("&&").description == "&&")
    }

    @Test("punctuation descriptions")
    func punctuationDescriptions() {
        #expect(ExpressionToken.leftParen.description == "(")
        #expect(ExpressionToken.rightParen.description == ")")
        #expect(ExpressionToken.leftBracket.description == "[")
        #expect(ExpressionToken.rightBracket.description == "]")
        #expect(ExpressionToken.comma.description == ",")
        #expect(ExpressionToken.dot.description == ".")
        #expect(ExpressionToken.question.description == "?")
        #expect(ExpressionToken.colon.description == ":")
        #expect(ExpressionToken.arrow.description == "=>")
    }

    @Test("EOF description")
    func eofDescription() {
        #expect(ExpressionToken.eof.description == "<EOF>")
    }

    // MARK: - Classification Tests

    @Test("isLiteral identifies literals")
    func isLiteralTest() {
        #expect(ExpressionToken.null.isLiteral == true)
        #expect(ExpressionToken.boolLiteral(true).isLiteral == true)
        #expect(ExpressionToken.intLiteral(42).isLiteral == true)
        #expect(ExpressionToken.doubleLiteral(3.14).isLiteral == true)
        #expect(ExpressionToken.stringLiteral("hi").isLiteral == true)
        #expect(ExpressionToken.regexLiteral(".*").isLiteral == true)
        #expect(ExpressionToken.identifier("x").isLiteral == false)
        #expect(ExpressionToken.operator("+").isLiteral == false)
        #expect(ExpressionToken.leftParen.isLiteral == false)
    }

    @Test("isOperator identifies operators")
    func isOperatorTest() {
        #expect(ExpressionToken.operator("==").isOperator == true)
        #expect(ExpressionToken.operator("+").isOperator == true)
        #expect(ExpressionToken.null.isOperator == false)
        #expect(ExpressionToken.identifier("x").isOperator == false)
        #expect(ExpressionToken.leftParen.isOperator == false)
    }

    @Test("isPunctuation identifies punctuation")
    func isPunctuationTest() {
        #expect(ExpressionToken.leftParen.isPunctuation == true)
        #expect(ExpressionToken.rightParen.isPunctuation == true)
        #expect(ExpressionToken.leftBracket.isPunctuation == true)
        #expect(ExpressionToken.rightBracket.isPunctuation == true)
        #expect(ExpressionToken.comma.isPunctuation == true)
        #expect(ExpressionToken.dot.isPunctuation == true)
        #expect(ExpressionToken.question.isPunctuation == true)
        #expect(ExpressionToken.colon.isPunctuation == true)
        #expect(ExpressionToken.arrow.isPunctuation == true)
        #expect(ExpressionToken.null.isPunctuation == false)
        #expect(ExpressionToken.operator("+").isPunctuation == false)
    }

    @Test("canStartPrimary identifies primary starters")
    func canStartPrimaryTest() {
        // Can start primary
        #expect(ExpressionToken.null.canStartPrimary == true)
        #expect(ExpressionToken.boolLiteral(true).canStartPrimary == true)
        #expect(ExpressionToken.intLiteral(42).canStartPrimary == true)
        #expect(ExpressionToken.doubleLiteral(3.14).canStartPrimary == true)
        #expect(ExpressionToken.stringLiteral("hi").canStartPrimary == true)
        #expect(ExpressionToken.regexLiteral(".*").canStartPrimary == true)
        #expect(ExpressionToken.identifier("x").canStartPrimary == true)
        #expect(ExpressionToken.leftParen.canStartPrimary == true)
        #expect(ExpressionToken.operator("!").canStartPrimary == true)
        #expect(ExpressionToken.operator("-").canStartPrimary == true)

        // Cannot start primary
        #expect(ExpressionToken.rightParen.canStartPrimary == false)
        #expect(ExpressionToken.operator("+").canStartPrimary == false)
        #expect(ExpressionToken.comma.canStartPrimary == false)
        #expect(ExpressionToken.eof.canStartPrimary == false)
    }

    // MARK: - Equality Tests

    @Test("same tokens are equal")
    func equalTokens() {
        #expect(ExpressionToken.null == ExpressionToken.null)
        #expect(ExpressionToken.boolLiteral(true) == ExpressionToken.boolLiteral(true))
        #expect(ExpressionToken.intLiteral(42) == ExpressionToken.intLiteral(42))
        #expect(ExpressionToken.doubleLiteral(3.14) == ExpressionToken.doubleLiteral(3.14))
        #expect(ExpressionToken.stringLiteral("hi") == ExpressionToken.stringLiteral("hi"))
        #expect(ExpressionToken.identifier("x") == ExpressionToken.identifier("x"))
        #expect(ExpressionToken.operator("+") == ExpressionToken.operator("+"))
        #expect(ExpressionToken.leftParen == ExpressionToken.leftParen)
    }

    @Test("different tokens are not equal")
    func differentTokens() {
        #expect(ExpressionToken.null != ExpressionToken.boolLiteral(false))
        #expect(ExpressionToken.intLiteral(1) != ExpressionToken.intLiteral(2))
        #expect(ExpressionToken.identifier("x") != ExpressionToken.identifier("y"))
        #expect(ExpressionToken.operator("+") != ExpressionToken.operator("-"))
    }

    // MARK: - Hashable Tests

    @Test("ExpressionToken is hashable")
    func hashable() {
        let set: Set<ExpressionToken> = [
            .null,
            .boolLiteral(true),
            .intLiteral(42),
            .stringLiteral("hi"),
            .identifier("x"),
            .operator("+"),
            .leftParen
        ]
        #expect(set.count == 7)
    }

    // MARK: - Codable Tests

    @Test("null round-trips through JSON")
    func nullCodableRoundTrip() throws {
        let original = ExpressionToken.null
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
        #expect(decoded == original)
    }

    @Test("boolLiteral round-trips through JSON")
    func boolLiteralCodableRoundTrip() throws {
        for value in [true, false] {
            let original = ExpressionToken.boolLiteral(value)
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
            #expect(decoded == original)
        }
    }

    @Test("intLiteral round-trips through JSON")
    func intLiteralCodableRoundTrip() throws {
        let original = ExpressionToken.intLiteral(42)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
        #expect(decoded == original)
    }

    @Test("doubleLiteral round-trips through JSON")
    func doubleLiteralCodableRoundTrip() throws {
        let original = ExpressionToken.doubleLiteral(3.14)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
        #expect(decoded == original)
    }

    @Test("stringLiteral round-trips through JSON")
    func stringLiteralCodableRoundTrip() throws {
        let original = ExpressionToken.stringLiteral("hello world")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
        #expect(decoded == original)
    }

    @Test("regexLiteral round-trips through JSON")
    func regexLiteralCodableRoundTrip() throws {
        let original = ExpressionToken.regexLiteral("^[a-z]+$")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
        #expect(decoded == original)
    }

    @Test("identifier round-trips through JSON")
    func identifierCodableRoundTrip() throws {
        let original = ExpressionToken.identifier("myVariable")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
        #expect(decoded == original)
    }

    @Test("operator round-trips through JSON")
    func operatorCodableRoundTrip() throws {
        let original = ExpressionToken.operator("==")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
        #expect(decoded == original)
    }

    @Test("punctuation round-trips through JSON")
    func punctuationCodableRoundTrip() throws {
        let tokens: [ExpressionToken] = [
            .leftParen, .rightParen, .leftBracket, .rightBracket,
            .comma, .dot, .question, .colon, .arrow, .eof
        ]
        for original in tokens {
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(ExpressionToken.self, from: data)
            #expect(decoded == original)
        }
    }
}
