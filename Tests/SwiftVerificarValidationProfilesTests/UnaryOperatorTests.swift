import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("UnaryOperator Tests")
struct UnaryOperatorTests {

    // MARK: - Raw Value Tests

    @Test("not operator has correct raw value")
    func notRawValue() {
        #expect(UnaryOperator.not.rawValue == "!")
    }

    @Test("minus operator has correct raw value")
    func minusRawValue() {
        #expect(UnaryOperator.minus.rawValue == "-")
    }

    // MARK: - Prefix Tests

    @Test("all unary operators are prefix")
    func allArePrefix() {
        for op in UnaryOperator.allCases {
            #expect(op.isPrefix == true)
        }
    }

    // MARK: - Name Tests

    @Test("not operator has descriptive name")
    func notName() {
        #expect(UnaryOperator.not.name == "logical NOT")
    }

    @Test("minus operator has descriptive name")
    func minusName() {
        #expect(UnaryOperator.minus.name == "negation")
    }

    // MARK: - CaseIterable Tests

    @Test("allCases contains both operators")
    func allCasesCount() {
        #expect(UnaryOperator.allCases.count == 2)
        #expect(UnaryOperator.allCases.contains(.not))
        #expect(UnaryOperator.allCases.contains(.minus))
    }

    // MARK: - CustomStringConvertible Tests

    @Test("description matches rawValue")
    func descriptionMatchesRawValue() {
        for op in UnaryOperator.allCases {
            #expect(op.description == op.rawValue)
        }
    }

    // MARK: - Codable Tests

    @Test("UnaryOperator round-trips through JSON")
    func codableRoundTrip() throws {
        for op in UnaryOperator.allCases {
            let data = try JSONEncoder().encode(op)
            let decoded = try JSONDecoder().decode(UnaryOperator.self, from: data)
            #expect(decoded == op)
        }
    }

    // MARK: - Hashable Tests

    @Test("UnaryOperator is hashable")
    func hashable() {
        let set = Set(UnaryOperator.allCases)
        #expect(set.count == 2)
    }

    // MARK: - Init from Raw Value Tests

    @Test("init from valid raw values")
    func initFromRawValue() {
        #expect(UnaryOperator(rawValue: "!") == .not)
        #expect(UnaryOperator(rawValue: "-") == .minus)
    }

    @Test("init from invalid raw value returns nil")
    func initFromInvalidRawValue() {
        #expect(UnaryOperator(rawValue: "+") == nil)
        #expect(UnaryOperator(rawValue: "~") == nil)
        #expect(UnaryOperator(rawValue: "not") == nil)
    }

    // MARK: - Equality Tests

    @Test("same operators are equal")
    func equality() {
        #expect(UnaryOperator.not == UnaryOperator.not)
        #expect(UnaryOperator.minus == UnaryOperator.minus)
    }

    @Test("different operators are not equal")
    func inequality() {
        #expect(UnaryOperator.not != UnaryOperator.minus)
    }
}
