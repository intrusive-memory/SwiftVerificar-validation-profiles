import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("BinaryOperator Tests")
struct BinaryOperatorTests {

    // MARK: - Raw Value Tests

    @Test("comparison operators have correct raw values")
    func comparisonOperatorRawValues() {
        #expect(BinaryOperator.eq.rawValue == "==")
        #expect(BinaryOperator.neq.rawValue == "!=")
        #expect(BinaryOperator.lt.rawValue == "<")
        #expect(BinaryOperator.lte.rawValue == "<=")
        #expect(BinaryOperator.gt.rawValue == ">")
        #expect(BinaryOperator.gte.rawValue == ">=")
    }

    @Test("logical operators have correct raw values")
    func logicalOperatorRawValues() {
        #expect(BinaryOperator.and.rawValue == "&&")
        #expect(BinaryOperator.or.rawValue == "||")
    }

    @Test("arithmetic operators have correct raw values")
    func arithmeticOperatorRawValues() {
        #expect(BinaryOperator.plus.rawValue == "+")
        #expect(BinaryOperator.minus.rawValue == "-")
        #expect(BinaryOperator.multiply.rawValue == "*")
        #expect(BinaryOperator.divide.rawValue == "/")
        #expect(BinaryOperator.modulo.rawValue == "%")
    }

    // MARK: - Precedence Tests

    @Test("OR has lowest precedence")
    func orLowestPrecedence() {
        #expect(BinaryOperator.or.precedence == 1)
    }

    @Test("AND has higher precedence than OR")
    func andHigherThanOr() {
        #expect(BinaryOperator.and.precedence > BinaryOperator.or.precedence)
    }

    @Test("equality has higher precedence than AND")
    func equalityHigherThanAnd() {
        #expect(BinaryOperator.eq.precedence > BinaryOperator.and.precedence)
        #expect(BinaryOperator.neq.precedence > BinaryOperator.and.precedence)
    }

    @Test("comparison has higher precedence than equality")
    func comparisonHigherThanEquality() {
        #expect(BinaryOperator.lt.precedence > BinaryOperator.eq.precedence)
        #expect(BinaryOperator.lte.precedence > BinaryOperator.eq.precedence)
        #expect(BinaryOperator.gt.precedence > BinaryOperator.eq.precedence)
        #expect(BinaryOperator.gte.precedence > BinaryOperator.eq.precedence)
    }

    @Test("additive has higher precedence than comparison")
    func additiveHigherThanComparison() {
        #expect(BinaryOperator.plus.precedence > BinaryOperator.lt.precedence)
        #expect(BinaryOperator.minus.precedence > BinaryOperator.lt.precedence)
    }

    @Test("multiplicative has highest precedence")
    func multiplicativeHighestPrecedence() {
        #expect(BinaryOperator.multiply.precedence > BinaryOperator.plus.precedence)
        #expect(BinaryOperator.divide.precedence > BinaryOperator.plus.precedence)
        #expect(BinaryOperator.modulo.precedence > BinaryOperator.plus.precedence)
    }

    @Test("precedence levels are correct")
    func precedenceLevels() {
        #expect(BinaryOperator.or.precedence == 1)
        #expect(BinaryOperator.and.precedence == 2)
        #expect(BinaryOperator.eq.precedence == 3)
        #expect(BinaryOperator.neq.precedence == 3)
        #expect(BinaryOperator.lt.precedence == 4)
        #expect(BinaryOperator.lte.precedence == 4)
        #expect(BinaryOperator.gt.precedence == 4)
        #expect(BinaryOperator.gte.precedence == 4)
        #expect(BinaryOperator.plus.precedence == 5)
        #expect(BinaryOperator.minus.precedence == 5)
        #expect(BinaryOperator.multiply.precedence == 6)
        #expect(BinaryOperator.divide.precedence == 6)
        #expect(BinaryOperator.modulo.precedence == 6)
    }

    // MARK: - Category Tests

    @Test("isComparison identifies comparison operators")
    func isComparisonTest() {
        #expect(BinaryOperator.eq.isComparison == true)
        #expect(BinaryOperator.neq.isComparison == true)
        #expect(BinaryOperator.lt.isComparison == true)
        #expect(BinaryOperator.lte.isComparison == true)
        #expect(BinaryOperator.gt.isComparison == true)
        #expect(BinaryOperator.gte.isComparison == true)
        #expect(BinaryOperator.and.isComparison == false)
        #expect(BinaryOperator.plus.isComparison == false)
    }

    @Test("isLogical identifies logical operators")
    func isLogicalTest() {
        #expect(BinaryOperator.and.isLogical == true)
        #expect(BinaryOperator.or.isLogical == true)
        #expect(BinaryOperator.eq.isLogical == false)
        #expect(BinaryOperator.plus.isLogical == false)
    }

    @Test("isArithmetic identifies arithmetic operators")
    func isArithmeticTest() {
        #expect(BinaryOperator.plus.isArithmetic == true)
        #expect(BinaryOperator.minus.isArithmetic == true)
        #expect(BinaryOperator.multiply.isArithmetic == true)
        #expect(BinaryOperator.divide.isArithmetic == true)
        #expect(BinaryOperator.modulo.isArithmetic == true)
        #expect(BinaryOperator.and.isArithmetic == false)
        #expect(BinaryOperator.eq.isArithmetic == false)
    }

    @Test("all operators are left-associative")
    func allLeftAssociative() {
        for op in BinaryOperator.allCases {
            #expect(op.isLeftAssociative == true)
        }
    }

    // MARK: - CaseIterable Tests

    @Test("allCases contains all 13 operators")
    func allCasesCount() {
        #expect(BinaryOperator.allCases.count == 13)
    }

    // MARK: - CustomStringConvertible Tests

    @Test("description matches rawValue")
    func descriptionMatchesRawValue() {
        for op in BinaryOperator.allCases {
            #expect(op.description == op.rawValue)
        }
    }

    // MARK: - Codable Tests

    @Test("BinaryOperator round-trips through JSON")
    func codableRoundTrip() throws {
        for op in BinaryOperator.allCases {
            let data = try JSONEncoder().encode(op)
            let decoded = try JSONDecoder().decode(BinaryOperator.self, from: data)
            #expect(decoded == op)
        }
    }

    // MARK: - Hashable Tests

    @Test("BinaryOperator is hashable")
    func hashable() {
        let set = Set(BinaryOperator.allCases)
        #expect(set.count == 13)
    }

    // MARK: - Init from Raw Value Tests

    @Test("init from valid raw values")
    func initFromRawValue() {
        #expect(BinaryOperator(rawValue: "==") == .eq)
        #expect(BinaryOperator(rawValue: "!=") == .neq)
        #expect(BinaryOperator(rawValue: "&&") == .and)
        #expect(BinaryOperator(rawValue: "||") == .or)
        #expect(BinaryOperator(rawValue: "+") == .plus)
        #expect(BinaryOperator(rawValue: "-") == .minus)
        #expect(BinaryOperator(rawValue: "*") == .multiply)
        #expect(BinaryOperator(rawValue: "/") == .divide)
        #expect(BinaryOperator(rawValue: "%") == .modulo)
    }

    @Test("init from invalid raw value returns nil")
    func initFromInvalidRawValue() {
        #expect(BinaryOperator(rawValue: "===") == nil)
        #expect(BinaryOperator(rawValue: "!==") == nil)
        #expect(BinaryOperator(rawValue: "^") == nil)
        #expect(BinaryOperator(rawValue: "invalid") == nil)
    }
}
