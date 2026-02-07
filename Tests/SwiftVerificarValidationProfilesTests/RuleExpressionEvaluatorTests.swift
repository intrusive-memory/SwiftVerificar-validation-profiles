import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("RuleExpressionEvaluator Tests")
struct RuleExpressionEvaluatorTests {

    let evaluator = RuleExpressionEvaluator()

    // MARK: - Literal Evaluation Tests

    @Test("evaluates null literal")
    func evalNull() throws {
        let result = try evaluator.evaluate(expression: "null", properties: [:])
        #expect(result == false)
    }

    @Test("evaluates true literal")
    func evalTrue() throws {
        let result = try evaluator.evaluate(expression: "true", properties: [:])
        #expect(result == true)
    }

    @Test("evaluates false literal")
    func evalFalse() throws {
        let result = try evaluator.evaluate(expression: "false", properties: [:])
        #expect(result == false)
    }

    @Test("evaluates integer literal truthiness")
    func evalIntegerTruthiness() throws {
        #expect(try evaluator.evaluate(expression: "0", properties: [:]) == false)
        #expect(try evaluator.evaluate(expression: "1", properties: [:]) == true)
        #expect(try evaluator.evaluate(expression: "42", properties: [:]) == true)
    }

    @Test("evaluates string literal truthiness")
    func evalStringTruthiness() throws {
        #expect(try evaluator.evaluate(expression: "\"\"", properties: [:]) == false)
        #expect(try evaluator.evaluate(expression: "\"hello\"", properties: [:]) == true)
    }

    // MARK: - Identifier Evaluation Tests

    @Test("evaluates identifier from properties")
    func evalIdentifier() throws {
        let result = try evaluator.evaluate(
            expression: "containsStructTreeRoot",
            properties: ["containsStructTreeRoot": .bool(true)]
        )
        #expect(result == true)
    }

    @Test("throws on unknown identifier")
    func throwsOnUnknownIdentifier() throws {
        #expect(throws: EvaluationError.self) {
            _ = try evaluator.evaluate(expression: "unknownVar", properties: [:])
        }
    }

    // MARK: - Equality Comparison Tests

    @Test("evaluates equality with true")
    func evalEqualityTrue() throws {
        let result = try evaluator.evaluate(
            expression: "x == 5",
            properties: ["x": .int(5)]
        )
        #expect(result == true)
    }

    @Test("evaluates equality with false")
    func evalEqualityFalse() throws {
        let result = try evaluator.evaluate(
            expression: "x == 5",
            properties: ["x": .int(10)]
        )
        #expect(result == false)
    }

    @Test("evaluates inequality")
    func evalInequality() throws {
        let result = try evaluator.evaluate(
            expression: "x != null",
            properties: ["x": .string("value")]
        )
        #expect(result == true)
    }

    @Test("evaluates null equality")
    func evalNullEquality() throws {
        #expect(try evaluator.evaluate(expression: "x == null", properties: ["x": .null]) == true)
        #expect(try evaluator.evaluate(expression: "x != null", properties: ["x": .null]) == false)
        #expect(try evaluator.evaluate(expression: "x != null", properties: ["x": .string("hi")]) == true)
    }

    @Test("evaluates int-double equality")
    func evalIntDoubleEquality() throws {
        let result = try evaluator.evaluate(
            expression: "x == 5.0",
            properties: ["x": .int(5)]
        )
        #expect(result == true)
    }

    // MARK: - Comparison Operator Tests

    @Test("evaluates less than")
    func evalLessThan() throws {
        #expect(try evaluator.evaluate(expression: "x < 10", properties: ["x": .int(5)]) == true)
        #expect(try evaluator.evaluate(expression: "x < 10", properties: ["x": .int(10)]) == false)
        #expect(try evaluator.evaluate(expression: "x < 10", properties: ["x": .int(15)]) == false)
    }

    @Test("evaluates less than or equal")
    func evalLessThanOrEqual() throws {
        #expect(try evaluator.evaluate(expression: "x <= 10", properties: ["x": .int(5)]) == true)
        #expect(try evaluator.evaluate(expression: "x <= 10", properties: ["x": .int(10)]) == true)
        #expect(try evaluator.evaluate(expression: "x <= 10", properties: ["x": .int(15)]) == false)
    }

    @Test("evaluates greater than")
    func evalGreaterThan() throws {
        #expect(try evaluator.evaluate(expression: "x > 0", properties: ["x": .int(5)]) == true)
        #expect(try evaluator.evaluate(expression: "x > 0", properties: ["x": .int(0)]) == false)
        #expect(try evaluator.evaluate(expression: "x > 0", properties: ["x": .int(-1)]) == false)
    }

    @Test("evaluates greater than or equal")
    func evalGreaterThanOrEqual() throws {
        #expect(try evaluator.evaluate(expression: "x >= 0", properties: ["x": .int(5)]) == true)
        #expect(try evaluator.evaluate(expression: "x >= 0", properties: ["x": .int(0)]) == true)
        #expect(try evaluator.evaluate(expression: "x >= 0", properties: ["x": .int(-1)]) == false)
    }

    @Test("evaluates string comparison")
    func evalStringComparison() throws {
        #expect(try evaluator.evaluate(expression: "s < 'b'", properties: ["s": .string("a")]) == true)
        #expect(try evaluator.evaluate(expression: "s > 'b'", properties: ["s": .string("c")]) == true)
    }

    // MARK: - Logical Operator Tests

    @Test("evaluates logical AND with true")
    func evalAndTrue() throws {
        let result = try evaluator.evaluate(
            expression: "a && b",
            properties: ["a": .bool(true), "b": .bool(true)]
        )
        #expect(result == true)
    }

    @Test("evaluates logical AND with false")
    func evalAndFalse() throws {
        let result = try evaluator.evaluate(
            expression: "a && b",
            properties: ["a": .bool(true), "b": .bool(false)]
        )
        #expect(result == false)
    }

    @Test("evaluates logical OR with true")
    func evalOrTrue() throws {
        let result = try evaluator.evaluate(
            expression: "a || b",
            properties: ["a": .bool(false), "b": .bool(true)]
        )
        #expect(result == true)
    }

    @Test("evaluates logical OR with false")
    func evalOrFalse() throws {
        let result = try evaluator.evaluate(
            expression: "a || b",
            properties: ["a": .bool(false), "b": .bool(false)]
        )
        #expect(result == false)
    }

    @Test("evaluates short-circuit AND")
    func evalShortCircuitAnd() throws {
        // Should not throw even though y is unknown because x is false
        let result = try evaluator.evaluate(
            expression: "x && y",
            properties: ["x": .bool(false)]
        )
        #expect(result == false)
    }

    @Test("evaluates short-circuit OR")
    func evalShortCircuitOr() throws {
        // Should not throw even though y is unknown because x is true
        let result = try evaluator.evaluate(
            expression: "x || y",
            properties: ["x": .bool(true)]
        )
        #expect(result == true)
    }

    // MARK: - Arithmetic Operator Tests

    @Test("evaluates addition")
    func evalAddition() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("x + y")
        let result = try evaluator.evaluate(ast, with: ["x": .int(3), "y": .int(4)])
        #expect(result == .int(7))
    }

    @Test("evaluates subtraction")
    func evalSubtraction() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("x - y")
        let result = try evaluator.evaluate(ast, with: ["x": .int(10), "y": .int(3)])
        #expect(result == .int(7))
    }

    @Test("evaluates multiplication")
    func evalMultiplication() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("x * y")
        let result = try evaluator.evaluate(ast, with: ["x": .int(3), "y": .int(4)])
        #expect(result == .int(12))
    }

    @Test("evaluates division")
    func evalDivision() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("x / y")
        let result = try evaluator.evaluate(ast, with: ["x": .int(12), "y": .int(4)])
        #expect(result == .int(3))
    }

    @Test("evaluates modulo")
    func evalModulo() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("x % y")
        let result = try evaluator.evaluate(ast, with: ["x": .int(10), "y": .int(3)])
        #expect(result == .int(1))
    }

    @Test("throws on division by zero")
    func throwsOnDivisionByZero() throws {
        #expect(throws: EvaluationError.self) {
            let parser = ExpressionParser()
            let ast: RuleExpression = try parser.parse("x / 0")
            _ = try evaluator.evaluate(ast, with: ["x": .int(10)])
        }
    }

    @Test("evaluates string concatenation")
    func evalStringConcat() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("a + b")
        let result = try evaluator.evaluate(ast, with: ["a": .string("hello"), "b": .string(" world")])
        #expect(result == .string("hello world"))
    }

    @Test("evaluates mixed-type addition with string")
    func evalMixedAddition() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s + n")
        let result = try evaluator.evaluate(ast, with: ["s": .string("value: "), "n": .int(42)])
        #expect(result == .string("value: 42"))
    }

    // MARK: - Unary Operator Tests

    @Test("evaluates logical NOT")
    func evalLogicalNot() throws {
        #expect(try evaluator.evaluate(expression: "!true", properties: [:]) == false)
        #expect(try evaluator.evaluate(expression: "!false", properties: [:]) == true)
        #expect(try evaluator.evaluate(expression: "!null", properties: [:]) == true)
    }

    @Test("evaluates unary minus")
    func evalUnaryMinus() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("-x")
        let result = try evaluator.evaluate(ast, with: ["x": .int(5)])
        #expect(result == .int(-5))
    }

    // MARK: - Ternary Operator Tests

    @Test("evaluates ternary with true condition")
    func evalTernaryTrue() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("cond ? 1 : 2")
        let result = try evaluator.evaluate(ast, with: ["cond": .bool(true)])
        #expect(result == .int(1))
    }

    @Test("evaluates ternary with false condition")
    func evalTernaryFalse() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("cond ? 1 : 2")
        let result = try evaluator.evaluate(ast, with: ["cond": .bool(false)])
        #expect(result == .int(2))
    }

    // MARK: - Member Access Tests

    @Test("evaluates string length")
    func evalStringLength() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s.length")
        let result = try evaluator.evaluate(ast, with: ["s": .string("hello")])
        #expect(result == .int(5))
    }

    @Test("evaluates array length")
    func evalArrayLength() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("arr.length")
        let result = try evaluator.evaluate(ast, with: ["arr": .array([.int(1), .int(2), .int(3)])])
        #expect(result == .int(3))
    }

    // MARK: - Index Access Tests

    @Test("evaluates array index access")
    func evalArrayIndex() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("arr[1]")
        let result = try evaluator.evaluate(ast, with: ["arr": .array([.int(10), .int(20), .int(30)])])
        #expect(result == .int(20))
    }

    @Test("evaluates string index access")
    func evalStringIndex() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s[0]")
        let result = try evaluator.evaluate(ast, with: ["s": .string("hello")])
        #expect(result == .string("h"))
    }

    @Test("throws on index out of bounds")
    func throwsOnIndexOutOfBounds() throws {
        #expect(throws: EvaluationError.self) {
            let parser = ExpressionParser()
            let ast: RuleExpression = try parser.parse("arr[10]")
            _ = try evaluator.evaluate(ast, with: ["arr": .array([.int(1), .int(2)])])
        }
    }

    // MARK: - String Method Tests

    @Test("evaluates split method")
    func evalSplit() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s.split(',')")
        let result = try evaluator.evaluate(ast, with: ["s": .string("a,b,c")])
        #expect(result == .array([.string("a"), .string("b"), .string("c")]))
    }

    @Test("evaluates trim method")
    func evalTrim() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s.trim()")
        let result = try evaluator.evaluate(ast, with: ["s": .string("  hello  ")])
        #expect(result == .string("hello"))
    }

    @Test("evaluates toLowerCase method")
    func evalToLowerCase() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s.toLowerCase()")
        let result = try evaluator.evaluate(ast, with: ["s": .string("HELLO")])
        #expect(result == .string("hello"))
    }

    @Test("evaluates toUpperCase method")
    func evalToUpperCase() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s.toUpperCase()")
        let result = try evaluator.evaluate(ast, with: ["s": .string("hello")])
        #expect(result == .string("HELLO"))
    }

    @Test("evaluates startsWith method")
    func evalStartsWith() throws {
        #expect(try evaluator.evaluate(expression: "s.startsWith('he')", properties: ["s": .string("hello")]) == true)
        #expect(try evaluator.evaluate(expression: "s.startsWith('lo')", properties: ["s": .string("hello")]) == false)
    }

    @Test("evaluates endsWith method")
    func evalEndsWith() throws {
        #expect(try evaluator.evaluate(expression: "s.endsWith('lo')", properties: ["s": .string("hello")]) == true)
        #expect(try evaluator.evaluate(expression: "s.endsWith('he')", properties: ["s": .string("hello")]) == false)
    }

    @Test("evaluates contains method")
    func evalContains() throws {
        #expect(try evaluator.evaluate(expression: "s.contains('ell')", properties: ["s": .string("hello")]) == true)
        #expect(try evaluator.evaluate(expression: "s.contains('xyz')", properties: ["s": .string("hello")]) == false)
    }

    @Test("evaluates indexOf method on string")
    func evalStringIndexOf() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s.indexOf('l')")
        let result = try evaluator.evaluate(ast, with: ["s": .string("hello")])
        #expect(result == .int(2))
    }

    @Test("evaluates indexOf method not found")
    func evalIndexOfNotFound() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("s.indexOf('x')")
        let result = try evaluator.evaluate(ast, with: ["s": .string("hello")])
        #expect(result == .int(-1))
    }

    // MARK: - Array Method Tests

    @Test("evaluates filter method")
    func evalFilter() throws {
        let result = try evaluator.evaluate(
            expression: "arr.filter(x => x > 2).length == 2",
            properties: ["arr": .array([.int(1), .int(2), .int(3), .int(4)])]
        )
        #expect(result == true)
    }

    @Test("evaluates map method")
    func evalMap() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("arr.map(x => x + 1)")
        let result = try evaluator.evaluate(ast, with: ["arr": .array([.int(1), .int(2), .int(3)])])
        #expect(result == .array([.int(2), .int(3), .int(4)]))
    }

    @Test("evaluates some method true")
    func evalSomeTrue() throws {
        let result = try evaluator.evaluate(
            expression: "arr.some(x => x > 3)",
            properties: ["arr": .array([.int(1), .int(2), .int(4)])]
        )
        #expect(result == true)
    }

    @Test("evaluates some method false")
    func evalSomeFalse() throws {
        let result = try evaluator.evaluate(
            expression: "arr.some(x => x > 10)",
            properties: ["arr": .array([.int(1), .int(2), .int(3)])]
        )
        #expect(result == false)
    }

    @Test("evaluates every method true")
    func evalEveryTrue() throws {
        let result = try evaluator.evaluate(
            expression: "arr.every(x => x > 0)",
            properties: ["arr": .array([.int(1), .int(2), .int(3)])]
        )
        #expect(result == true)
    }

    @Test("evaluates every method false")
    func evalEveryFalse() throws {
        let result = try evaluator.evaluate(
            expression: "arr.every(x => x > 1)",
            properties: ["arr": .array([.int(1), .int(2), .int(3)])]
        )
        #expect(result == false)
    }

    @Test("evaluates includes method true")
    func evalIncludesTrue() throws {
        let result = try evaluator.evaluate(
            expression: "arr.includes(2)",
            properties: ["arr": .array([.int(1), .int(2), .int(3)])]
        )
        #expect(result == true)
    }

    @Test("evaluates includes method false")
    func evalIncludesFalse() throws {
        let result = try evaluator.evaluate(
            expression: "arr.includes(5)",
            properties: ["arr": .array([.int(1), .int(2), .int(3)])]
        )
        #expect(result == false)
    }

    @Test("evaluates indexOf method on array")
    func evalArrayIndexOf() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("arr.indexOf(2)")
        let result = try evaluator.evaluate(ast, with: ["arr": .array([.int(1), .int(2), .int(3)])])
        #expect(result == .int(1))
    }

    // MARK: - Math Function Tests

    @Test("evaluates abs function")
    func evalAbs() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("abs(x)")
        #expect(try evaluator.evaluate(ast, with: ["x": .int(-5)]) == .int(5))
        #expect(try evaluator.evaluate(ast, with: ["x": .int(5)]) == .int(5))
        #expect(try evaluator.evaluate(ast, with: ["x": .double(-3.5)]) == .double(3.5))
    }

    @Test("evaluates floor function")
    func evalFloor() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("floor(x)")
        let result = try evaluator.evaluate(ast, with: ["x": .double(3.7)])
        #expect(result == .double(3.0))
    }

    @Test("evaluates ceil function")
    func evalCeil() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("ceil(x)")
        let result = try evaluator.evaluate(ast, with: ["x": .double(3.2)])
        #expect(result == .double(4.0))
    }

    @Test("evaluates round function")
    func evalRound() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("round(x)")
        #expect(try evaluator.evaluate(ast, with: ["x": .double(3.4)]) == .double(3.0))
        #expect(try evaluator.evaluate(ast, with: ["x": .double(3.6)]) == .double(4.0))
    }

    @Test("evaluates min function")
    func evalMin() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("min(a, b)")
        let result = try evaluator.evaluate(ast, with: ["a": .int(5), "b": .int(3)])
        #expect(result == .int(3))
    }

    @Test("evaluates max function")
    func evalMax() throws {
        let parser = ExpressionParser()
        let ast: RuleExpression = try parser.parse("max(a, b)")
        let result = try evaluator.evaluate(ast, with: ["a": .int(5), "b": .int(3)])
        #expect(result == .int(5))
    }

    // MARK: - Regex Tests

    @Test("evaluates regex test true")
    func evalRegexTestTrue() throws {
        let result = try evaluator.evaluate(
            expression: "/^[a-z]+$/.test(s)",
            properties: ["s": .string("hello")]
        )
        #expect(result == true)
    }

    @Test("evaluates regex test false")
    func evalRegexTestFalse() throws {
        let result = try evaluator.evaluate(
            expression: "/^[a-z]+$/.test(s)",
            properties: ["s": .string("Hello123")]
        )
        #expect(result == false)
    }

    @Test("evaluates complex regex pattern")
    func evalComplexRegex() throws {
        let result = try evaluator.evaluate(
            expression: "/^[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*$/.test(s)",
            properties: ["s": .string("en-US")]
        )
        #expect(result == true)
    }

    // MARK: - veraPDF Expression Tests

    @Test("evaluates veraPDF containsStructTreeRoot check")
    func evalVeraPDFStructTreeRoot() throws {
        let result = try evaluator.evaluate(
            expression: "containsStructTreeRoot == true",
            properties: ["containsStructTreeRoot": .bool(true)]
        )
        #expect(result == true)
    }

    @Test("evaluates veraPDF null check")
    func evalVeraPDFNullCheck() throws {
        let result = try evaluator.evaluate(
            expression: "Alt != null || ActualText != null",
            properties: ["Alt": .null, "ActualText": .string("Some text")]
        )
        #expect(result == true)
    }

    @Test("evaluates veraPDF complex filter expression")
    func evalVeraPDFFilter() throws {
        // kidsStandardTypes.split('&').filter(elem => elem == 'Figure').length == 0
        let result = try evaluator.evaluate(
            expression: "kidsStandardTypes.split('&').filter(elem => elem == 'Figure').length == 0",
            properties: ["kidsStandardTypes": .string("Span&P&Div")]
        )
        #expect(result == true)
    }

    @Test("evaluates veraPDF triple null check")
    func evalVeraPDFTripleNullCheck() throws {
        let result = try evaluator.evaluate(
            expression: "F == null && FFilter == null && FDecodeParms == null",
            properties: ["F": .null, "FFilter": .null, "FDecodeParms": .null]
        )
        #expect(result == true)
    }

    @Test("evaluates veraPDF hasIntersection check")
    func evalVeraPDFHasIntersection() throws {
        let result = try evaluator.evaluate(
            expression: "hasIntersection != true",
            properties: ["hasIntersection": .bool(false)]
        )
        #expect(result == true)
    }

    // MARK: - Error Handling Tests

    @Test("throws on unknown function")
    func throwsOnUnknownFunction() throws {
        #expect(throws: EvaluationError.self) {
            _ = try evaluator.evaluate(expression: "unknownFunc()", properties: [:])
        }
    }

    @Test("throws on type mismatch in comparison")
    func throwsOnTypeMismatch() throws {
        #expect(throws: EvaluationError.self) {
            _ = try evaluator.evaluate(expression: "x < y", properties: ["x": .int(5), "y": .array([])])
        }
    }

    @Test("throws on invalid regex")
    func throwsOnInvalidRegex() throws {
        #expect(throws: EvaluationError.self) {
            _ = try evaluator.evaluate(expression: "/[invalid/.test(s)", properties: ["s": .string("test")])
        }
    }
}
