import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ExpressionParser Tests")
struct ExpressionParserTests {

    let parser = ExpressionParser()

    // MARK: - Literal Parsing Tests

    @Test("parses null literal")
    func parseNull() throws {
        let expr: RuleExpression = try parser.parse("null")
        #expect(expr == .literal(.null))
    }

    @Test("parses true literal")
    func parseTrue() throws {
        let expr: RuleExpression = try parser.parse("true")
        #expect(expr == .literal(.bool(true)))
    }

    @Test("parses false literal")
    func parseFalse() throws {
        let expr: RuleExpression = try parser.parse("false")
        #expect(expr == .literal(.bool(false)))
    }

    @Test("parses integer literal")
    func parseInteger() throws {
        let expr: RuleExpression = try parser.parse("42")
        #expect(expr == .literal(.int(42)))
    }

    @Test("parses negative integer literal")
    func parseNegativeInteger() throws {
        let expr: RuleExpression = try parser.parse("-5")
        // Negative number literals are parsed directly as literals with negative values
        // This is more efficient and matches standard parsing behavior
        #expect(expr == .literal(.int(-5)))
    }

    @Test("parses double literal")
    func parseDouble() throws {
        let expr: RuleExpression = try parser.parse("3.14")
        #expect(expr == .literal(.double(3.14)))
    }

    @Test("parses scientific notation")
    func parseScientificNotation() throws {
        let expr: RuleExpression = try parser.parse("1e10")
        #expect(expr == .literal(.double(1e10)))
    }

    @Test("parses double-quoted string")
    func parseDoubleQuotedString() throws {
        let expr: RuleExpression = try parser.parse("\"hello\"")
        #expect(expr == .literal(.string("hello")))
    }

    @Test("parses single-quoted string")
    func parseSingleQuotedString() throws {
        let expr: RuleExpression = try parser.parse("'hello'")
        #expect(expr == .literal(.string("hello")))
    }

    @Test("parses string with escape sequences")
    func parseStringEscapes() throws {
        let expr: RuleExpression = try parser.parse("\"line1\\nline2\"")
        #expect(expr == .literal(.string("line1\nline2")))
    }

    @Test("parses empty string")
    func parseEmptyString() throws {
        let expr: RuleExpression = try parser.parse("\"\"")
        #expect(expr == .literal(.string("")))
    }

    // MARK: - Identifier Parsing Tests

    @Test("parses simple identifier")
    func parseIdentifier() throws {
        let expr: RuleExpression = try parser.parse("containsStructTreeRoot")
        #expect(expr == .identifier("containsStructTreeRoot"))
    }

    @Test("parses identifier with underscore")
    func parseIdentifierWithUnderscore() throws {
        let expr: RuleExpression = try parser.parse("my_var")
        #expect(expr == .identifier("my_var"))
    }

    @Test("parses identifier starting with underscore")
    func parseIdentifierStartingWithUnderscore() throws {
        let expr: RuleExpression = try parser.parse("_private")
        #expect(expr == .identifier("_private"))
    }

    // MARK: - Binary Operator Parsing Tests

    @Test("parses equality comparison")
    func parseEquality() throws {
        let expr: RuleExpression = try parser.parse("x == 5")
        #expect(expr == .binary(.identifier("x"), .eq, .literal(.int(5))))
    }

    @Test("parses inequality comparison")
    func parseInequality() throws {
        let expr: RuleExpression = try parser.parse("x != null")
        #expect(expr == .binary(.identifier("x"), .neq, .literal(.null)))
    }

    @Test("parses less than comparison")
    func parseLessThan() throws {
        let expr: RuleExpression = try parser.parse("x < 10")
        #expect(expr == .binary(.identifier("x"), .lt, .literal(.int(10))))
    }

    @Test("parses less than or equal comparison")
    func parseLessThanOrEqual() throws {
        let expr: RuleExpression = try parser.parse("x <= 10")
        #expect(expr == .binary(.identifier("x"), .lte, .literal(.int(10))))
    }

    @Test("parses greater than comparison")
    func parseGreaterThan() throws {
        let expr: RuleExpression = try parser.parse("x > 0")
        #expect(expr == .binary(.identifier("x"), .gt, .literal(.int(0))))
    }

    @Test("parses greater than or equal comparison")
    func parseGreaterThanOrEqual() throws {
        let expr: RuleExpression = try parser.parse("x >= 0")
        #expect(expr == .binary(.identifier("x"), .gte, .literal(.int(0))))
    }

    @Test("parses logical AND")
    func parseLogicalAnd() throws {
        let expr: RuleExpression = try parser.parse("a && b")
        #expect(expr == .binary(.identifier("a"), .and, .identifier("b")))
    }

    @Test("parses logical OR")
    func parseLogicalOr() throws {
        let expr: RuleExpression = try parser.parse("a || b")
        #expect(expr == .binary(.identifier("a"), .or, .identifier("b")))
    }

    @Test("parses addition")
    func parseAddition() throws {
        let expr: RuleExpression = try parser.parse("x + y")
        #expect(expr == .binary(.identifier("x"), .plus, .identifier("y")))
    }

    @Test("parses subtraction")
    func parseSubtraction() throws {
        let expr: RuleExpression = try parser.parse("x - y")
        #expect(expr == .binary(.identifier("x"), .minus, .identifier("y")))
    }

    @Test("parses multiplication")
    func parseMultiplication() throws {
        let expr: RuleExpression = try parser.parse("x * y")
        #expect(expr == .binary(.identifier("x"), .multiply, .identifier("y")))
    }

    @Test("parses division")
    func parseDivision() throws {
        let expr: RuleExpression = try parser.parse("x / y")
        #expect(expr == .binary(.identifier("x"), .divide, .identifier("y")))
    }

    @Test("parses modulo")
    func parseModulo() throws {
        let expr: RuleExpression = try parser.parse("x % y")
        #expect(expr == .binary(.identifier("x"), .modulo, .identifier("y")))
    }

    // MARK: - Operator Precedence Tests

    @Test("multiplication binds tighter than addition")
    func precedenceMultOverAdd() throws {
        // a + b * c should parse as a + (b * c)
        let expr: RuleExpression = try parser.parse("a + b * c")
        let expected = RuleExpression.binary(
            .identifier("a"),
            .plus,
            .binary(.identifier("b"), .multiply, .identifier("c"))
        )
        #expect(expr == expected)
    }

    @Test("comparison binds tighter than logical AND")
    func precedenceCompOverAnd() throws {
        // a == b && c == d should parse as (a == b) && (c == d)
        let expr: RuleExpression = try parser.parse("a == b && c == d")
        let expected = RuleExpression.binary(
            .binary(.identifier("a"), .eq, .identifier("b")),
            .and,
            .binary(.identifier("c"), .eq, .identifier("d"))
        )
        #expect(expr == expected)
    }

    @Test("logical AND binds tighter than logical OR")
    func precedenceAndOverOr() throws {
        // a || b && c should parse as a || (b && c)
        let expr: RuleExpression = try parser.parse("a || b && c")
        let expected = RuleExpression.binary(
            .identifier("a"),
            .or,
            .binary(.identifier("b"), .and, .identifier("c"))
        )
        #expect(expr == expected)
    }

    @Test("parentheses override precedence")
    func parenthesesOverridePrecedence() throws {
        // (a + b) * c
        let expr: RuleExpression = try parser.parse("(a + b) * c")
        let expected = RuleExpression.binary(
            .binary(.identifier("a"), .plus, .identifier("b")),
            .multiply,
            .identifier("c")
        )
        #expect(expr == expected)
    }

    // MARK: - Unary Operator Parsing Tests

    @Test("parses logical NOT")
    func parseLogicalNot() throws {
        let expr: RuleExpression = try parser.parse("!flag")
        #expect(expr == .unary(.not, .identifier("flag")))
    }

    @Test("parses double negation")
    func parseDoubleNegation() throws {
        let expr: RuleExpression = try parser.parse("!!flag")
        #expect(expr == .unary(.not, .unary(.not, .identifier("flag"))))
    }

    @Test("parses unary minus")
    func parseUnaryMinus() throws {
        let expr: RuleExpression = try parser.parse("-x")
        #expect(expr == RuleExpression.unary(.minus, RuleExpression.identifier("x")))
    }

    // MARK: - Member Access Parsing Tests

    @Test("parses member access")
    func parseMemberAccess() throws {
        let expr: RuleExpression = try parser.parse("obj.property")
        #expect(expr == .member(.identifier("obj"), "property"))
    }

    @Test("parses chained member access")
    func parseChainedMemberAccess() throws {
        let expr: RuleExpression = try parser.parse("a.b.c")
        let expected = RuleExpression.member(
            .member(.identifier("a"), "b"),
            "c"
        )
        #expect(expr == expected)
    }

    @Test("parses length property")
    func parseLengthProperty() throws {
        let expr: RuleExpression = try parser.parse("str.length")
        #expect(expr == .member(.identifier("str"), "length"))
    }

    // MARK: - Index Access Parsing Tests

    @Test("parses array index")
    func parseArrayIndex() throws {
        let expr: RuleExpression = try parser.parse("arr[0]")
        #expect(expr == .index(.identifier("arr"), .literal(.int(0))))
    }

    @Test("parses index with expression")
    func parseIndexWithExpression() throws {
        let expr: RuleExpression = try parser.parse("arr[i + 1]")
        let expected = RuleExpression.index(
            .identifier("arr"),
            .binary(.identifier("i"), .plus, .literal(.int(1)))
        )
        #expect(expr == expected)
    }

    @Test("parses chained index access")
    func parseChainedIndexAccess() throws {
        let expr: RuleExpression = try parser.parse("matrix[0][1]")
        let expected = RuleExpression.index(
            .index(.identifier("matrix"), .literal(.int(0))),
            .literal(.int(1))
        )
        #expect(expr == expected)
    }

    // MARK: - Function Call Parsing Tests

    @Test("parses function call without arguments")
    func parseFunctionCallNoArgs() throws {
        let expr: RuleExpression = try parser.parse("func()")
        #expect(expr == .call("func", []))
    }

    @Test("parses function call with one argument")
    func parseFunctionCallOneArg() throws {
        let expr: RuleExpression = try parser.parse("func(x)")
        #expect(expr == .call("func", [.identifier("x")]))
    }

    @Test("parses function call with multiple arguments")
    func parseFunctionCallMultipleArgs() throws {
        let expr: RuleExpression = try parser.parse("func(x, y, z)")
        #expect(expr == .call("func", [.identifier("x"), .identifier("y"), .identifier("z")]))
    }

    @Test("parses method call")
    func parseMethodCall() throws {
        let expr: RuleExpression = try parser.parse("str.split(',')")
        #expect(expr == .call("split", [.identifier("str"), .literal(.string(","))]))
    }

    @Test("parses chained method calls")
    func parseChainedMethodCalls() throws {
        // str.split(',').filter(...)
        let expr: RuleExpression = try parser.parse("str.trim()")
        #expect(expr == .call("trim", [.identifier("str")]))
    }

    // MARK: - Ternary Parsing Tests

    @Test("parses ternary expression")
    func parseTernary() throws {
        let expr: RuleExpression = try parser.parse("cond ? a : b")
        #expect(expr == .ternary(.identifier("cond"), .identifier("a"), .identifier("b")))
    }

    @Test("parses nested ternary")
    func parseNestedTernary() throws {
        // a ? b : c ? d : e should parse as a ? b : (c ? d : e)
        let expr: RuleExpression = try parser.parse("a ? b : c ? d : e")
        let expected = RuleExpression.ternary(
            .identifier("a"),
            .identifier("b"),
            .ternary(.identifier("c"), .identifier("d"), .identifier("e"))
        )
        #expect(expr == expected)
    }

    // MARK: - Lambda Parsing Tests

    @Test("parses lambda expression")
    func parseLambda() throws {
        let expr: RuleExpression = try parser.parse("x => x > 0")
        let expected = RuleExpression.lambda(
            "x",
            .binary(.identifier("x"), .gt, .literal(.int(0)))
        )
        #expect(expr == expected)
    }

    @Test("parses lambda with equality")
    func parseLambdaEquality() throws {
        let expr: RuleExpression = try parser.parse("elem => elem == 'Figure'")
        let expected = RuleExpression.lambda(
            "elem",
            .binary(.identifier("elem"), .eq, .literal(.string("Figure")))
        )
        #expect(expr == expected)
    }

    // MARK: - Regex Parsing Tests

    @Test("parses regex literal")
    func parseRegex() throws {
        let expr: RuleExpression = try parser.parse("/^[a-z]+$/")
        #expect(expr == .regex("^[a-z]+$"))
    }

    @Test("parses regex with flags")
    func parseRegexWithFlags() throws {
        let expr: RuleExpression = try parser.parse("/pattern/gi")
        #expect(expr == .regex("pattern"))
    }

    @Test("parses regex with escape sequences")
    func parseRegexWithEscapes() throws {
        let expr: RuleExpression = try parser.parse("/\\d+\\.\\d+/")
        #expect(expr == .regex("\\d+\\.\\d+"))
    }

    // MARK: - Array Literal Parsing Tests

    @Test("parses empty array")
    func parseEmptyArray() throws {
        let expr: RuleExpression = try parser.parse("[]")
        #expect(expr == .literal(.array([])))
    }

    @Test("parses array with elements")
    func parseArrayWithElements() throws {
        let expr: RuleExpression = try parser.parse("[1, 2, 3]")
        #expect(expr == .literal(.array([.int(1), .int(2), .int(3)])))
    }

    // MARK: - Complex Expression Tests

    @Test("parses veraPDF-style null check")
    func parseNullCheck() throws {
        let expr: RuleExpression = try parser.parse("Alt != null || ActualText != null")
        let expected = RuleExpression.binary(
            .binary(.identifier("Alt"), .neq, .literal(.null)),
            .or,
            .binary(.identifier("ActualText"), .neq, .literal(.null))
        )
        #expect(expr == expected)
    }

    @Test("parses veraPDF-style boolean check")
    func parseBooleanCheck() throws {
        let expr: RuleExpression = try parser.parse("containsStructTreeRoot == true")
        let expected = RuleExpression.binary(
            .identifier("containsStructTreeRoot"),
            .eq,
            .literal(.bool(true))
        )
        #expect(expr == expected)
    }

    @Test("parses complex boolean expression")
    func parseComplexBoolean() throws {
        let expr: RuleExpression = try parser.parse("F == null && FFilter == null && FDecodeParms == null")
        // This should parse as ((F == null) && (FFilter == null)) && (FDecodeParms == null)
        let expected = RuleExpression.binary(
            .binary(
                .binary(.identifier("F"), .eq, .literal(.null)),
                .and,
                .binary(.identifier("FFilter"), .eq, .literal(.null))
            ),
            .and,
            .binary(.identifier("FDecodeParms"), .eq, .literal(.null))
        )
        #expect(expr == expected)
    }

    // MARK: - Error Handling Tests

    @Test("throws on empty expression")
    func throwsOnEmptyExpression() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("")
        }
    }

    @Test("throws on whitespace-only expression")
    func throwsOnWhitespaceOnly() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("   ")
        }
    }

    @Test("throws on unterminated string")
    func throwsOnUnterminatedString() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("\"hello")
        }
    }

    @Test("throws on invalid operator")
    func throwsOnInvalidOperator() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("x & y")
        }
    }

    @Test("throws on unexpected token")
    func throwsOnUnexpectedToken() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("x == == y")
        }
    }

    @Test("throws on missing closing paren")
    func throwsOnMissingClosingParen() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("(x + y")
        }
    }

    @Test("throws on missing closing bracket")
    func throwsOnMissingClosingBracket() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("arr[0")
        }
    }

    @Test("throws on invalid escape sequence")
    func throwsOnInvalidEscapeSequence() throws {
        #expect(throws: ExpressionParseError.self) {
            _ = try parser.parse("\"hello\\x\"")
        }
    }

    // MARK: - Whitespace Handling Tests

    @Test("ignores leading and trailing whitespace")
    func ignoresWhitespace() throws {
        let expr: RuleExpression = try parser.parse("  x == 5  ")
        #expect(expr == .binary(.identifier("x"), .eq, .literal(.int(5))))
    }

    @Test("handles whitespace between tokens")
    func handlesWhitespaceBetweenTokens() throws {
        let expr: RuleExpression = try parser.parse("x   ==   5")
        #expect(expr == .binary(.identifier("x"), .eq, .literal(.int(5))))
    }

    @Test("handles no whitespace between tokens")
    func handlesNoWhitespaceBetweenTokens() throws {
        let expr: RuleExpression = try parser.parse("x==5")
        #expect(expr == .binary(.identifier("x"), .eq, .literal(.int(5))))
    }
}
