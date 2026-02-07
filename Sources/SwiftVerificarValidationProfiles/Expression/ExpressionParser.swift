import Foundation

/// A recursive descent parser for rule test expressions.
///
/// `ExpressionParser` converts a rule test expression string into a
/// ``RuleExpression`` AST. It handles operator precedence, function calls,
/// member access, array indexing, and other JavaScript-like syntax.
///
/// ## Example
/// ```swift
/// let parser = ExpressionParser()
/// let ast = try parser.parse("x == 5 && y != null")
/// // Returns: binary(binary(identifier("x"), .eq, literal(.int(5))), .and, ...)
/// ```
///
/// ## Supported Syntax
/// - Literals: `true`, `false`, `null`, integers, doubles, strings
/// - Identifiers: `variableName`, `camelCase`
/// - Binary operators: `==`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`, `+`, `-`, `*`, `/`, `%`
/// - Unary operators: `!`, `-`
/// - Parentheses: `(expression)`
/// - Member access: `object.property`
/// - Array index: `array[index]`
/// - Function calls: `func(arg1, arg2)`
/// - Method calls: `object.method(args)`
/// - Ternary: `condition ? then : else`
/// - Lambda: `param => expression`
/// - Regex: `/pattern/`
///
/// - Note: This parser is thread-safe and can be used concurrently.
public struct ExpressionParser: Sendable {
    /// Maximum nesting depth to prevent stack overflow.
    static let maxDepth = 100

    /// Creates a new expression parser.
    public init() {}

    /// Parses an expression string into an AST.
    ///
    /// - Parameter input: The expression string to parse.
    /// - Returns: The parsed expression AST.
    /// - Throws: ``ExpressionParseError`` if parsing fails.
    public func parse(_ input: String) throws -> RuleExpression {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ExpressionParseError.emptyExpression
        }

        var state = ParserState(input: trimmed)
        try state.tokenize()
        let result = try state.parseExpression(depth: 0)

        // Ensure we consumed all tokens
        if state.current != .eof {
            throw ExpressionParseError.unexpectedToken(
                expected: "end of expression",
                found: state.current.description,
                position: state.position
            )
        }

        return result
    }
}

// MARK: - Parser State

/// Internal mutable state for parsing.
private struct ParserState {
    let input: String
    var tokens: [ExpressionToken] = []
    var position: Int = 0
    var tokenIndex: Int = 0

    init(input: String) {
        self.input = input
    }

    var current: ExpressionToken {
        tokenIndex < tokens.count ? tokens[tokenIndex] : .eof
    }

    mutating func advance() {
        if tokenIndex < tokens.count {
            tokenIndex += 1
        }
    }

    func peek(offset: Int = 1) -> ExpressionToken {
        let index = tokenIndex + offset
        return index < tokens.count ? tokens[index] : .eof
    }

    mutating func match(_ expected: ExpressionToken) -> Bool {
        if current == expected {
            advance()
            return true
        }
        return false
    }

    mutating func expect(_ expected: ExpressionToken, description: String) throws {
        if current == expected {
            advance()
        } else {
            throw ExpressionParseError.unexpectedToken(
                expected: description,
                found: current.description,
                position: position
            )
        }
    }
}

// MARK: - Tokenizer

extension ParserState {
    mutating func tokenize() throws {
        tokens = []
        var index = input.startIndex

        while index < input.endIndex {
            let char = input[index]
            position = input.distance(from: input.startIndex, to: index)

            // Skip whitespace
            if char.isWhitespace {
                index = input.index(after: index)
                continue
            }

            // Regex literal (must check before division operator)
            if char == "/" {
                // Check if this could be a regex (simple heuristic)
                let lastToken = tokens.last
                let isRegexContext = lastToken == nil ||
                    lastToken == .leftParen ||
                    lastToken == .leftBracket ||
                    lastToken == .comma ||
                    lastToken == .colon ||
                    lastToken == .question ||
                    lastToken == .arrow ||
                    (lastToken?.isOperator ?? false)

                if isRegexContext {
                    let (regex, newIndex) = try tokenizeRegex(from: index)
                    tokens.append(.regexLiteral(regex))
                    index = newIndex
                    continue
                }
            }

            // String literals
            if char == "\"" || char == "'" {
                let (string, newIndex) = try tokenizeString(from: index, quote: char)
                tokens.append(.stringLiteral(string))
                index = newIndex
                continue
            }

            // Numbers
            if char.isNumber || (char == "-" && canStartNegativeNumber() && hasDigitAfter(index)) {
                let (token, newIndex) = try tokenizeNumber(from: index)
                tokens.append(token)
                index = newIndex
                continue
            }

            // Identifiers and keywords
            if char.isLetter || char == "_" {
                let (identifier, newIndex) = tokenizeIdentifier(from: index)
                tokens.append(keywordToken(for: identifier))
                index = newIndex
                continue
            }

            // Operators and punctuation
            if let (token, newIndex) = try tokenizeOperatorOrPunctuation(from: index) {
                tokens.append(token)
                index = newIndex
                continue
            }

            throw ExpressionParseError.unexpectedCharacter(character: char, position: position)
        }

        tokens.append(.eof)
        tokenIndex = 0
    }

    private func canStartNegativeNumber() -> Bool {
        guard let lastToken = tokens.last else { return true }
        switch lastToken {
        case .leftParen, .leftBracket, .comma, .colon, .question, .arrow:
            return true
        case .operator:
            return true
        default:
            return false
        }
    }

    private func hasDigitAfter(_ index: String.Index) -> Bool {
        let nextIndex = input.index(after: index)
        return nextIndex < input.endIndex && input[nextIndex].isNumber
    }

    private mutating func tokenizeString(from start: String.Index, quote: Character) throws -> (String, String.Index) {
        var result = ""
        var index = input.index(after: start)

        while index < input.endIndex {
            let char = input[index]

            if char == quote {
                return (result, input.index(after: index))
            }

            if char == "\\" {
                let nextIndex = input.index(after: index)
                guard nextIndex < input.endIndex else {
                    throw ExpressionParseError.unterminatedString(position: position)
                }
                let escaped = input[nextIndex]
                switch escaped {
                case "n": result.append("\n")
                case "r": result.append("\r")
                case "t": result.append("\t")
                case "\\": result.append("\\")
                case "'": result.append("'")
                case "\"": result.append("\"")
                default:
                    let escapePos = input.distance(from: input.startIndex, to: index)
                    throw ExpressionParseError.invalidEscapeSequence(
                        sequence: "\\\(escaped)",
                        position: escapePos
                    )
                }
                index = input.index(after: nextIndex)
            } else {
                result.append(char)
                index = input.index(after: index)
            }
        }

        throw ExpressionParseError.unterminatedString(position: position)
    }

    private mutating func tokenizeRegex(from start: String.Index) throws -> (String, String.Index) {
        var result = ""
        var index = input.index(after: start)  // Skip opening /

        while index < input.endIndex {
            let char = input[index]

            if char == "/" {
                // Skip any regex flags (g, i, m, etc.)
                var flagIndex = input.index(after: index)
                while flagIndex < input.endIndex && input[flagIndex].isLetter {
                    flagIndex = input.index(after: flagIndex)
                }
                return (result, flagIndex)
            }

            if char == "\\" && input.index(after: index) < input.endIndex {
                // Escape sequence in regex - keep as-is
                let nextIndex = input.index(after: index)
                result.append(char)
                result.append(input[nextIndex])
                index = input.index(after: nextIndex)
            } else {
                result.append(char)
                index = input.index(after: index)
            }
        }

        throw ExpressionParseError.unterminatedRegex(position: position)
    }

    private func tokenizeNumber(from start: String.Index) throws -> (ExpressionToken, String.Index) {
        var index = start
        var numberStr = ""
        var hasDecimal = false

        // Handle negative sign
        if input[index] == "-" {
            numberStr.append("-")
            index = input.index(after: index)
        }

        while index < input.endIndex {
            let char = input[index]

            if char.isNumber {
                numberStr.append(char)
                index = input.index(after: index)
            } else if char == "." && !hasDecimal {
                // Check if next char is a digit (not a method call)
                let nextIndex = input.index(after: index)
                if nextIndex < input.endIndex && input[nextIndex].isNumber {
                    hasDecimal = true
                    numberStr.append(char)
                    index = input.index(after: index)
                } else {
                    break
                }
            } else if char == "e" || char == "E" {
                // Scientific notation
                numberStr.append(char)
                index = input.index(after: index)
                if index < input.endIndex && (input[index] == "+" || input[index] == "-") {
                    numberStr.append(input[index])
                    index = input.index(after: index)
                }
            } else {
                break
            }
        }

        if hasDecimal || numberStr.contains("e") || numberStr.contains("E") {
            if let value = Double(numberStr) {
                return (.doubleLiteral(value), index)
            }
        } else {
            if let value = Int64(numberStr) {
                return (.intLiteral(value), index)
            }
        }

        let pos = input.distance(from: input.startIndex, to: start)
        throw ExpressionParseError.invalidNumber(text: numberStr, position: pos)
    }

    private func tokenizeIdentifier(from start: String.Index) -> (String, String.Index) {
        var index = start
        var identifier = ""

        while index < input.endIndex {
            let char = input[index]
            if char.isLetter || char.isNumber || char == "_" {
                identifier.append(char)
                index = input.index(after: index)
            } else {
                break
            }
        }

        return (identifier, index)
    }

    private func keywordToken(for identifier: String) -> ExpressionToken {
        switch identifier {
        case "true": return .boolLiteral(true)
        case "false": return .boolLiteral(false)
        case "null": return .null
        default: return .identifier(identifier)
        }
    }

    private mutating func tokenizeOperatorOrPunctuation(from start: String.Index) throws -> (ExpressionToken, String.Index)? {
        let char = input[start]
        let nextIndex = input.index(after: start)
        let nextChar = nextIndex < input.endIndex ? input[nextIndex] : nil

        switch char {
        case "(": return (.leftParen, nextIndex)
        case ")": return (.rightParen, nextIndex)
        case "[": return (.leftBracket, nextIndex)
        case "]": return (.rightBracket, nextIndex)
        case ",": return (.comma, nextIndex)
        case ".": return (.dot, nextIndex)
        case "?": return (.question, nextIndex)
        case ":": return (.colon, nextIndex)
        case "+": return (.operator("+"), nextIndex)
        case "-": return (.operator("-"), nextIndex)
        case "*": return (.operator("*"), nextIndex)
        case "/": return (.operator("/"), nextIndex)
        case "%": return (.operator("%"), nextIndex)
        case "!":
            if nextChar == "=" {
                return (.operator("!="), input.index(after: nextIndex))
            }
            return (.operator("!"), nextIndex)
        case "=":
            if nextChar == "=" {
                return (.operator("=="), input.index(after: nextIndex))
            }
            if nextChar == ">" {
                return (.arrow, input.index(after: nextIndex))
            }
            let pos = input.distance(from: input.startIndex, to: start)
            throw ExpressionParseError.invalidOperator(text: "=", position: pos)
        case "<":
            if nextChar == "=" {
                return (.operator("<="), input.index(after: nextIndex))
            }
            return (.operator("<"), nextIndex)
        case ">":
            if nextChar == "=" {
                return (.operator(">="), input.index(after: nextIndex))
            }
            return (.operator(">"), nextIndex)
        case "&":
            if nextChar == "&" {
                return (.operator("&&"), input.index(after: nextIndex))
            }
            let pos = input.distance(from: input.startIndex, to: start)
            throw ExpressionParseError.invalidOperator(text: "&", position: pos)
        case "|":
            if nextChar == "|" {
                return (.operator("||"), input.index(after: nextIndex))
            }
            let pos = input.distance(from: input.startIndex, to: start)
            throw ExpressionParseError.invalidOperator(text: "|", position: pos)
        default:
            return nil
        }
    }
}

// MARK: - Expression Parsing

extension ParserState {
    mutating func parseExpression(depth: Int) throws -> RuleExpression {
        guard depth < ExpressionParser.maxDepth else {
            throw ExpressionParseError.maxDepthExceeded(depth: depth)
        }
        return try parseTernary(depth: depth)
    }

    private mutating func parseTernary(depth: Int) throws -> RuleExpression {
        var condition = try parseOr(depth: depth)

        if match(.question) {
            let thenExpr = try parseExpression(depth: depth + 1)
            try expect(.colon, description: "':'")
            let elseExpr = try parseExpression(depth: depth + 1)
            condition = .ternary(condition, thenExpr, elseExpr)
        }

        return condition
    }

    private mutating func parseOr(depth: Int) throws -> RuleExpression {
        var left = try parseAnd(depth: depth)

        while case .operator("||") = current {
            advance()
            let right = try parseAnd(depth: depth + 1)
            left = .binary(left, .or, right)
        }

        return left
    }

    private mutating func parseAnd(depth: Int) throws -> RuleExpression {
        var left = try parseEquality(depth: depth)

        while case .operator("&&") = current {
            advance()
            let right = try parseEquality(depth: depth + 1)
            left = .binary(left, .and, right)
        }

        return left
    }

    private mutating func parseEquality(depth: Int) throws -> RuleExpression {
        var left = try parseComparison(depth: depth)

        while true {
            if case .operator("==") = current {
                advance()
                let right = try parseComparison(depth: depth + 1)
                left = .binary(left, .eq, right)
            } else if case .operator("!=") = current {
                advance()
                let right = try parseComparison(depth: depth + 1)
                left = .binary(left, .neq, right)
            } else {
                break
            }
        }

        return left
    }

    private mutating func parseComparison(depth: Int) throws -> RuleExpression {
        var left = try parseAdditive(depth: depth)

        while true {
            let op: BinaryOperator
            switch current {
            case .operator("<"): op = .lt
            case .operator("<="): op = .lte
            case .operator(">"): op = .gt
            case .operator(">="): op = .gte
            default: return left
            }
            advance()
            let right = try parseAdditive(depth: depth + 1)
            left = .binary(left, op, right)
        }
    }

    private mutating func parseAdditive(depth: Int) throws -> RuleExpression {
        var left = try parseMultiplicative(depth: depth)

        while true {
            let op: BinaryOperator
            switch current {
            case .operator("+"): op = .plus
            case .operator("-"): op = .minus
            default: return left
            }
            advance()
            let right = try parseMultiplicative(depth: depth + 1)
            left = .binary(left, op, right)
        }
    }

    private mutating func parseMultiplicative(depth: Int) throws -> RuleExpression {
        var left = try parseUnary(depth: depth)

        while true {
            let op: BinaryOperator
            switch current {
            case .operator("*"): op = .multiply
            case .operator("/"): op = .divide
            case .operator("%"): op = .modulo
            default: return left
            }
            advance()
            let right = try parseUnary(depth: depth + 1)
            left = .binary(left, op, right)
        }
    }

    private mutating func parseUnary(depth: Int) throws -> RuleExpression {
        switch current {
        case .operator("!"):
            advance()
            let operand = try parseUnary(depth: depth + 1)
            return .unary(.not, operand)
        case .operator("-"):
            advance()
            let operand = try parseUnary(depth: depth + 1)
            return .unary(.minus, operand)
        default:
            return try parsePostfix(depth: depth)
        }
    }

    private mutating func parsePostfix(depth: Int) throws -> RuleExpression {
        var expr = try parsePrimary(depth: depth)

        while true {
            switch current {
            case .dot:
                advance()
                guard case .identifier(let name) = current else {
                    throw ExpressionParseError.unexpectedToken(
                        expected: "property name",
                        found: current.description,
                        position: position
                    )
                }
                advance()

                // Check for method call
                if current == .leftParen {
                    advance()
                    var args: [RuleExpression] = [expr]  // receiver is first arg
                    if current != .rightParen {
                        args.append(try parseExpression(depth: depth + 1))
                        while match(.comma) {
                            args.append(try parseExpression(depth: depth + 1))
                        }
                    }
                    try expect(.rightParen, description: "')'")
                    expr = .call(name, args)
                } else {
                    expr = .member(expr, name)
                }

            case .leftBracket:
                advance()
                let index = try parseExpression(depth: depth + 1)
                try expect(.rightBracket, description: "']'")
                expr = .index(expr, index)

            case .leftParen:
                // Only allow function calls on identifiers or member access
                if case .identifier(let name) = expr {
                    advance()
                    var args: [RuleExpression] = []
                    if current != .rightParen {
                        args.append(try parseExpression(depth: depth + 1))
                        while match(.comma) {
                            args.append(try parseExpression(depth: depth + 1))
                        }
                    }
                    try expect(.rightParen, description: "')'")
                    expr = .call(name, args)
                } else {
                    return expr
                }

            default:
                return expr
            }
        }
    }

    private mutating func parsePrimary(depth: Int) throws -> RuleExpression {
        switch current {
        case .null:
            advance()
            return .literal(.null)

        case .boolLiteral(let value):
            advance()
            return .literal(.bool(value))

        case .intLiteral(let value):
            advance()
            return .literal(.int(value))

        case .doubleLiteral(let value):
            advance()
            return .literal(.double(value))

        case .stringLiteral(let value):
            advance()
            return .literal(.string(value))

        case .regexLiteral(let pattern):
            advance()
            return .regex(pattern)

        case .identifier(let name):
            advance()
            // Check for arrow function
            if current == .arrow {
                advance()
                let body = try parseExpression(depth: depth + 1)
                return .lambda(name, body)
            }
            return .identifier(name)

        case .leftParen:
            advance()
            // Check for arrow function with parenthesized parameter
            if case .identifier(let name) = current, peek() == .rightParen {
                advance()  // consume identifier
                if match(.rightParen) && current == .arrow {
                    advance()  // consume arrow
                    let body = try parseExpression(depth: depth + 1)
                    return .lambda(name, body)
                }
                // Not an arrow function, backtrack
                tokenIndex -= 2
            }
            let expr = try parseExpression(depth: depth + 1)
            try expect(.rightParen, description: "')'")
            return expr

        case .leftBracket:
            // Array literal
            advance()
            var elements: [PropertyValue] = []
            if current != .rightBracket {
                let firstExpr = try parseExpression(depth: depth + 1)
                if case .literal(let value) = firstExpr {
                    elements.append(value)
                } else {
                    // Non-literal array element - represent as expression array
                    // For now, only support literal arrays
                    throw ExpressionParseError.unexpectedToken(
                        expected: "literal value",
                        found: firstExpr.description,
                        position: position
                    )
                }
                while match(.comma) {
                    let elemExpr = try parseExpression(depth: depth + 1)
                    if case .literal(let value) = elemExpr {
                        elements.append(value)
                    } else {
                        throw ExpressionParseError.unexpectedToken(
                            expected: "literal value",
                            found: elemExpr.description,
                            position: position
                        )
                    }
                }
            }
            try expect(.rightBracket, description: "']'")
            return .literal(.array(elements))

        default:
            throw ExpressionParseError.unexpectedToken(
                expected: "expression",
                found: current.description,
                position: position
            )
        }
    }
}
