import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

// Workaround for Swift 6 naming collision with Foundation.Expression
private func expressionSet(_ exprs: RuleExpression...) -> Set<RuleExpression> {
    Set(exprs)
}

@Suite("Expression Tests")
struct ExpressionTests {

    // MARK: - Convenience Initializer Tests

    @Test("null convenience initializer")
    func nullConvenience() {
        let expr = RuleExpression.null
        if case .literal(.null) = expr {
            // Success
        } else {
            Issue.record("Expected literal null")
        }
    }

    @Test("bool convenience initializer")
    func boolConvenience() {
        let trueExpr = RuleExpression.bool(true)
        let falseExpr = RuleExpression.bool(false)

        if case .literal(.bool(true)) = trueExpr {} else {
            Issue.record("Expected literal true")
        }
        if case .literal(.bool(false)) = falseExpr {} else {
            Issue.record("Expected literal false")
        }
    }

    @Test("int convenience initializer")
    func intConvenience() {
        let expr = RuleExpression.int(42)
        if case .literal(.int(42)) = expr {} else {
            Issue.record("Expected literal int 42")
        }
    }

    @Test("double convenience initializer")
    func doubleConvenience() {
        let expr = RuleExpression.double(3.14)
        if case .literal(.double(3.14)) = expr {} else {
            Issue.record("Expected literal double 3.14")
        }
    }

    @Test("string convenience initializer")
    func stringConvenience() {
        let expr = RuleExpression.string("hello")
        if case .literal(.string("hello")) = expr {} else {
            Issue.record("Expected literal string 'hello'")
        }
    }

    @Test("array convenience initializer")
    func arrayConvenience() {
        let expr = RuleExpression.array([.int(1), .int(2)])
        if case .literal(.array(let arr)) = expr {
            #expect(arr.count == 2)
        } else {
            Issue.record("Expected literal array")
        }
    }

    // MARK: - Description Tests

    @Test("literal description")
    func literalDescription() {
        #expect(RuleExpression.literal(.null).description == "null")
        #expect(RuleExpression.literal(.bool(true)).description == "true")
        #expect(RuleExpression.literal(.int(42)).description == "42")
        #expect(RuleExpression.literal(.double(3.14)).description == "3.14")
        #expect(RuleExpression.literal(.string("hello")).description == "hello")
    }

    @Test("identifier description")
    func identifierDescription() {
        #expect(RuleExpression.identifier("x").description == "x")
        #expect(RuleExpression.identifier("containsStructTreeRoot").description == "containsStructTreeRoot")
    }

    @Test("binary description")
    func binaryDescription() {
        let expr = RuleExpression.binary(.identifier("x"), .eq, .literal(.int(5)))
        #expect(expr.description == "(x == 5)")
    }

    @Test("unary description")
    func unaryDescription() {
        let notExpr = RuleExpression.unary(.not, .identifier("flag"))
        let negExpr = RuleExpression.unary(.minus, .identifier("x"))
        #expect(notExpr.description == "!flag")
        #expect(negExpr.description == "-x")
    }

    @Test("call description")
    func callDescription() {
        let expr = RuleExpression.call("func", [.identifier("x"), .literal(.int(5))])
        #expect(expr.description == "func(x, 5)")
    }

    @Test("member description")
    func memberDescription() {
        let expr = RuleExpression.member(.identifier("obj"), "property")
        #expect(expr.description == "obj.property")
    }

    @Test("index description")
    func indexDescription() {
        let expr = RuleExpression.index(.identifier("arr"), .literal(.int(0)))
        #expect(expr.description == "arr[0]")
    }

    @Test("ternary description")
    func ternaryDescription() {
        let expr = RuleExpression.ternary(
            .identifier("cond"),
            .literal(.int(1)),
            .literal(.int(2))
        )
        #expect(expr.description == "(cond ? 1 : 2)")
    }

    @Test("lambda description")
    func lambdaDescription() {
        let expr = RuleExpression.lambda("x", .binary(.identifier("x"), .gt, .literal(.int(0))))
        #expect(expr.description == "x => (x > 0)")
    }

    @Test("regex description")
    func regexDescription() {
        let expr = RuleExpression.regex("^[a-z]+$")
        #expect(expr.description == "/^[a-z]+$/")
    }

    // MARK: - Hashable Tests

    @Test("same expressions are equal")
    func equalExpressions() {
        let expr1 = RuleExpression.binary(.identifier("x"), .eq, .literal(.int(5)))
        let expr2 = RuleExpression.binary(.identifier("x"), .eq, .literal(.int(5)))
        #expect(expr1 == expr2)
    }

    @Test("different expressions are not equal")
    func differentExpressions() {
        let expr1 = RuleExpression.binary(.identifier("x"), .eq, .literal(.int(5)))
        let expr2 = RuleExpression.binary(.identifier("x"), .eq, .literal(.int(6)))
        #expect(expr1 != expr2)
    }

    @Test("Expression is hashable")
    func hashable() {
        let set = expressionSet(
            .identifier("x"),
            .identifier("y"),
            .literal(.int(1)),
            .binary(.identifier("x"), .eq, .literal(.int(1)))
        )
        #expect(set.count == 4)
    }

    // MARK: - Codable Tests

    @Test("literal round-trips through JSON")
    func literalCodableRoundTrip() throws {
        let values: [PropertyValue] = [
            .null, .bool(true), .bool(false), .int(42), .double(3.14),
            .string("hello"), .array([.int(1), .int(2)])
        ]
        for value in values {
            let original = RuleExpression.literal(value)
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
            #expect(decoded == original)
        }
    }

    @Test("identifier round-trips through JSON")
    func identifierCodableRoundTrip() throws {
        let original = RuleExpression.identifier("containsStructTreeRoot")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("binary round-trips through JSON")
    func binaryCodableRoundTrip() throws {
        let original = RuleExpression.binary(
            .identifier("x"),
            .eq,
            .literal(.int(5))
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("unary round-trips through JSON")
    func unaryCodableRoundTrip() throws {
        let original = RuleExpression.unary(.not, .identifier("flag"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("call round-trips through JSON")
    func callCodableRoundTrip() throws {
        let original = RuleExpression.call("split", [.identifier("str"), .literal(.string(","))])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("member round-trips through JSON")
    func memberCodableRoundTrip() throws {
        let original = RuleExpression.member(.identifier("obj"), "length")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("index round-trips through JSON")
    func indexCodableRoundTrip() throws {
        let original = RuleExpression.index(.identifier("arr"), .literal(.int(0)))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("ternary round-trips through JSON")
    func ternaryCodableRoundTrip() throws {
        let original = RuleExpression.ternary(
            .identifier("cond"),
            .literal(.int(1)),
            .literal(.int(2))
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("lambda round-trips through JSON")
    func lambdaCodableRoundTrip() throws {
        let original = RuleExpression.lambda("x", .binary(.identifier("x"), .gt, .literal(.int(0))))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("regex round-trips through JSON")
    func regexCodableRoundTrip() throws {
        let original = RuleExpression.regex("^[a-z]+$")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }

    @Test("nested expression round-trips through JSON")
    func nestedCodableRoundTrip() throws {
        // (x + y) * z == 10
        let original = RuleExpression.binary(
            .binary(
                .binary(.identifier("x"), .plus, .identifier("y")),
                .multiply,
                .identifier("z")
            ),
            .eq,
            .literal(.int(10))
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RuleExpression.self, from: data)
        #expect(decoded == original)
    }
}
