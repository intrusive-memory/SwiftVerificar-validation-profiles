import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("RuleID Tests")
struct RuleIDTests {

    // MARK: - Initialization

    @Test("RuleID stores specification, clause, and testNumber correctly")
    func initialization() {
        let ruleID = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)

        #expect(ruleID.specification == .iso142892)
        #expect(ruleID.clause == "8.2.5.26")
        #expect(ruleID.testNumber == 1)
    }

    @Test("RuleID with different specifications")
    func differentSpecifications() {
        let pdfA1 = RuleID(specification: .iso190051, clause: "6.1.2", testNumber: 3)
        let pdfUA1 = RuleID(specification: .iso142891, clause: "7.1", testNumber: 1)
        let wcag = RuleID(specification: .wcag22, clause: "1.1.1", testNumber: 2)

        #expect(pdfA1.specification == .iso190051)
        #expect(pdfUA1.specification == .iso142891)
        #expect(wcag.specification == .wcag22)
    }

    @Test("RuleID with various clause formats")
    func variousClauseFormats() {
        let simple = RuleID(specification: .iso142892, clause: "8", testNumber: 1)
        let dotted = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)
        let complex = RuleID(specification: .iso190051, clause: "6.1.2.3.4", testNumber: 1)

        #expect(simple.clause == "8")
        #expect(dotted.clause == "8.2.5.26")
        #expect(complex.clause == "6.1.2.3.4")
    }

    // MARK: - Unique ID

    @Test("uniqueID produces correct format")
    func uniqueIDFormat() {
        let ruleID = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)

        #expect(ruleID.uniqueID == "ISO_14289_2-8.2.5.26-1")
    }

    @Test("uniqueID varies with specification")
    func uniqueIDVariesWithSpec() {
        let id1 = RuleID(specification: .iso190051, clause: "6.1", testNumber: 1)
        let id2 = RuleID(specification: .iso142892, clause: "6.1", testNumber: 1)

        #expect(id1.uniqueID == "ISO_19005_1-6.1-1")
        #expect(id2.uniqueID == "ISO_14289_2-6.1-1")
        #expect(id1.uniqueID != id2.uniqueID)
    }

    @Test("uniqueID varies with testNumber")
    func uniqueIDVariesWithTestNumber() {
        let id1 = RuleID(specification: .iso142892, clause: "8.2", testNumber: 1)
        let id2 = RuleID(specification: .iso142892, clause: "8.2", testNumber: 2)

        #expect(id1.uniqueID == "ISO_14289_2-8.2-1")
        #expect(id2.uniqueID == "ISO_14289_2-8.2-2")
        #expect(id1.uniqueID != id2.uniqueID)
    }

    @Test("uniqueID with noStandard specification")
    func uniqueIDNoStandard() {
        let ruleID = RuleID(specification: .noStandard, clause: "0", testNumber: 0)
        #expect(ruleID.uniqueID == "NO_STANDARD-0-0")
    }

    // MARK: - Hashable

    @Test("Equal RuleIDs have the same hash value")
    func hashableEquality() {
        let id1 = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)
        let id2 = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)

        #expect(id1 == id2)
        #expect(id1.hashValue == id2.hashValue)
    }

    @Test("Different RuleIDs are not equal")
    func hashableInequality() {
        let id1 = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)
        let id2 = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 2)
        let id3 = RuleID(specification: .iso142891, clause: "8.2.5.26", testNumber: 1)
        let id4 = RuleID(specification: .iso142892, clause: "8.2.5.27", testNumber: 1)

        #expect(id1 != id2)
        #expect(id1 != id3)
        #expect(id1 != id4)
    }

    @Test("RuleIDs can be used as dictionary keys")
    func dictionaryKey() {
        let id1 = RuleID(specification: .iso142892, clause: "8.2", testNumber: 1)
        let id2 = RuleID(specification: .iso142892, clause: "8.3", testNumber: 1)

        var dict: [RuleID: String] = [:]
        dict[id1] = "rule1"
        dict[id2] = "rule2"

        #expect(dict[id1] == "rule1")
        #expect(dict[id2] == "rule2")
    }

    @Test("RuleIDs can be stored in a Set")
    func setStorage() {
        let id1 = RuleID(specification: .iso142892, clause: "8.2", testNumber: 1)
        let id2 = RuleID(specification: .iso142892, clause: "8.2", testNumber: 1)
        let id3 = RuleID(specification: .iso142892, clause: "8.3", testNumber: 1)

        let set: Set<RuleID> = [id1, id2, id3]
        #expect(set.count == 2)
    }

    // MARK: - Codable

    @Test("RuleID round-trips through JSON encoding/decoding")
    func codableRoundTrip() throws {
        let original = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RuleID.self, from: data)

        #expect(decoded == original)
        #expect(decoded.specification == .iso142892)
        #expect(decoded.clause == "8.2.5.26")
        #expect(decoded.testNumber == 1)
    }

    @Test("RuleID array round-trips through JSON")
    func codableArrayRoundTrip() throws {
        let originals = [
            RuleID(specification: .iso190051, clause: "6.1", testNumber: 1),
            RuleID(specification: .iso142892, clause: "8.2", testNumber: 2),
            RuleID(specification: .wcag22, clause: "1.1.1", testNumber: 3),
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(originals)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([RuleID].self, from: data)

        #expect(decoded.count == 3)
        #expect(decoded[0] == originals[0])
        #expect(decoded[1] == originals[1])
        #expect(decoded[2] == originals[2])
    }
}
