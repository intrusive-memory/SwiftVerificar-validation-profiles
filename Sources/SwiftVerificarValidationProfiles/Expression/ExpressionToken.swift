import Foundation

/// Lexer tokens for rule expression parsing.
///
/// `ExpressionToken` represents the individual tokens produced by the lexer
/// when tokenizing a rule test expression string. These tokens are consumed
/// by ``ExpressionParser`` to build the expression AST.
///
/// ## Token Categories
/// - Literals: numbers, strings, booleans, null
/// - Identifiers: variable and property names
/// - Operators: binary and unary operators
/// - Punctuation: parentheses, brackets, commas, dots
/// - Special: regex literals, arrow functions
///
/// ## Example
/// The expression `x == 5 && y != null` tokenizes to:
/// ```swift
/// [
///     .identifier("x"),
///     .operator(.eq),
///     .intLiteral(5),
///     .operator(.and),
///     .identifier("y"),
///     .operator(.neq),
///     .null
/// ]
/// ```
///
/// - Note: This type is used internally by ``ExpressionParser``.
public enum ExpressionToken: Sendable, Hashable {
    // MARK: - Literals

    /// A null literal (`null`).
    case null

    /// A boolean literal (`true` or `false`).
    case boolLiteral(Bool)

    /// An integer literal (e.g., `42`, `-5`).
    case intLiteral(Int64)

    /// A floating-point literal (e.g., `3.14`, `-0.5`).
    case doubleLiteral(Double)

    /// A string literal (e.g., `"hello"`, `'world'`).
    case stringLiteral(String)

    /// A regular expression literal (e.g., `/^[a-z]+$/`).
    case regexLiteral(String)

    // MARK: - Identifiers

    /// An identifier (variable or property name).
    case identifier(String)

    // MARK: - Operators

    /// A binary or unary operator symbol.
    case `operator`(String)

    // MARK: - Punctuation

    /// Left parenthesis `(`.
    case leftParen

    /// Right parenthesis `)`.
    case rightParen

    /// Left bracket `[`.
    case leftBracket

    /// Right bracket `]`.
    case rightBracket

    /// Comma `,`.
    case comma

    /// Dot/period `.`.
    case dot

    /// Question mark `?` (for ternary).
    case question

    /// Colon `:` (for ternary).
    case colon

    /// Arrow `=>` (for lambda).
    case arrow

    // MARK: - End of Input

    /// End of input marker.
    case eof
}

// MARK: - CustomStringConvertible

extension ExpressionToken: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null:
            return "null"
        case .boolLiteral(let value):
            return value ? "true" : "false"
        case .intLiteral(let value):
            return String(value)
        case .doubleLiteral(let value):
            return String(value)
        case .stringLiteral(let value):
            return "\"\(value)\""
        case .regexLiteral(let pattern):
            return "/\(pattern)/"
        case .identifier(let name):
            return name
        case .operator(let op):
            return op
        case .leftParen:
            return "("
        case .rightParen:
            return ")"
        case .leftBracket:
            return "["
        case .rightBracket:
            return "]"
        case .comma:
            return ","
        case .dot:
            return "."
        case .question:
            return "?"
        case .colon:
            return ":"
        case .arrow:
            return "=>"
        case .eof:
            return "<EOF>"
        }
    }
}

// MARK: - Token Classification

extension ExpressionToken {
    /// Whether this token is a literal value.
    public var isLiteral: Bool {
        switch self {
        case .null, .boolLiteral, .intLiteral, .doubleLiteral, .stringLiteral, .regexLiteral:
            return true
        default:
            return false
        }
    }

    /// Whether this token is an operator.
    public var isOperator: Bool {
        if case .operator = self {
            return true
        }
        return false
    }

    /// Whether this token is punctuation.
    public var isPunctuation: Bool {
        switch self {
        case .leftParen, .rightParen, .leftBracket, .rightBracket,
             .comma, .dot, .question, .colon, .arrow:
            return true
        default:
            return false
        }
    }

    /// Whether this token can start a primary expression.
    public var canStartPrimary: Bool {
        switch self {
        case .null, .boolLiteral, .intLiteral, .doubleLiteral,
             .stringLiteral, .regexLiteral, .identifier, .leftParen:
            return true
        case .operator(let op) where op == "!" || op == "-":
            return true
        default:
            return false
        }
    }
}

// MARK: - Codable

extension ExpressionToken: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, value
    }

    private enum TokenType: String, Codable {
        case null, boolLiteral, intLiteral, doubleLiteral, stringLiteral, regexLiteral
        case identifier, `operator`
        case leftParen, rightParen, leftBracket, rightBracket
        case comma, dot, question, colon, arrow, eof
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TokenType.self, forKey: .type)

        switch type {
        case .null:
            self = .null
        case .boolLiteral:
            let value = try container.decode(Bool.self, forKey: .value)
            self = .boolLiteral(value)
        case .intLiteral:
            let value = try container.decode(Int64.self, forKey: .value)
            self = .intLiteral(value)
        case .doubleLiteral:
            let value = try container.decode(Double.self, forKey: .value)
            self = .doubleLiteral(value)
        case .stringLiteral:
            let value = try container.decode(String.self, forKey: .value)
            self = .stringLiteral(value)
        case .regexLiteral:
            let value = try container.decode(String.self, forKey: .value)
            self = .regexLiteral(value)
        case .identifier:
            let value = try container.decode(String.self, forKey: .value)
            self = .identifier(value)
        case .operator:
            let value = try container.decode(String.self, forKey: .value)
            self = .operator(value)
        case .leftParen:
            self = .leftParen
        case .rightParen:
            self = .rightParen
        case .leftBracket:
            self = .leftBracket
        case .rightBracket:
            self = .rightBracket
        case .comma:
            self = .comma
        case .dot:
            self = .dot
        case .question:
            self = .question
        case .colon:
            self = .colon
        case .arrow:
            self = .arrow
        case .eof:
            self = .eof
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .null:
            try container.encode(TokenType.null, forKey: .type)
        case .boolLiteral(let value):
            try container.encode(TokenType.boolLiteral, forKey: .type)
            try container.encode(value, forKey: .value)
        case .intLiteral(let value):
            try container.encode(TokenType.intLiteral, forKey: .type)
            try container.encode(value, forKey: .value)
        case .doubleLiteral(let value):
            try container.encode(TokenType.doubleLiteral, forKey: .type)
            try container.encode(value, forKey: .value)
        case .stringLiteral(let value):
            try container.encode(TokenType.stringLiteral, forKey: .type)
            try container.encode(value, forKey: .value)
        case .regexLiteral(let value):
            try container.encode(TokenType.regexLiteral, forKey: .type)
            try container.encode(value, forKey: .value)
        case .identifier(let value):
            try container.encode(TokenType.identifier, forKey: .type)
            try container.encode(value, forKey: .value)
        case .operator(let value):
            try container.encode(TokenType.operator, forKey: .type)
            try container.encode(value, forKey: .value)
        case .leftParen:
            try container.encode(TokenType.leftParen, forKey: .type)
        case .rightParen:
            try container.encode(TokenType.rightParen, forKey: .type)
        case .leftBracket:
            try container.encode(TokenType.leftBracket, forKey: .type)
        case .rightBracket:
            try container.encode(TokenType.rightBracket, forKey: .type)
        case .comma:
            try container.encode(TokenType.comma, forKey: .type)
        case .dot:
            try container.encode(TokenType.dot, forKey: .type)
        case .question:
            try container.encode(TokenType.question, forKey: .type)
        case .colon:
            try container.encode(TokenType.colon, forKey: .type)
        case .arrow:
            try container.encode(TokenType.arrow, forKey: .type)
        case .eof:
            try container.encode(TokenType.eof, forKey: .type)
        }
    }
}
