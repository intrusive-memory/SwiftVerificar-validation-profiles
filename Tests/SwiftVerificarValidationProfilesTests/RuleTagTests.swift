import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("RuleTag Tests")
struct RuleTagTests {

    // MARK: - Case Count

    @Test("RuleTag has exactly 22 cases")
    func caseCount() {
        #expect(RuleTag.allCases.count == 22)
    }

    // MARK: - Raw Values

    @Test("Severity tag raw values are correct")
    func severityRawValues() {
        #expect(RuleTag.critical.rawValue == "critical")
        #expect(RuleTag.major.rawValue == "major")
        #expect(RuleTag.minor.rawValue == "minor")
        #expect(RuleTag.cosmetic.rawValue == "cosmetic")
    }

    @Test("Checkability tag raw values are correct")
    func checkabilityRawValues() {
        #expect(RuleTag.machine.rawValue == "machine")
        #expect(RuleTag.human.rawValue == "human")
    }

    @Test("Category tag raw values are correct")
    func categoryRawValues() {
        #expect(RuleTag.metadata.rawValue == "metadata")
        #expect(RuleTag.structure.rawValue == "structure")
        #expect(RuleTag.text.rawValue == "text")
        #expect(RuleTag.font.rawValue == "font")
        #expect(RuleTag.annotation.rawValue == "annotation")
        #expect(RuleTag.syntax.rawValue == "syntax")
        #expect(RuleTag.artifact.rawValue == "artifact")
    }

    @Test("Feature-specific tag raw values are correct")
    func featureSpecificRawValues() {
        #expect(RuleTag.altText.rawValue == "alt-text")
        #expect(RuleTag.lang.rawValue == "lang")
        #expect(RuleTag.table.rawValue == "table")
        #expect(RuleTag.list.rawValue == "list")
        #expect(RuleTag.heading.rawValue == "heading")
        #expect(RuleTag.figure.rawValue == "figure")
        #expect(RuleTag.note.rawValue == "note")
        #expect(RuleTag.toc.rawValue == "toc")
        #expect(RuleTag.form.rawValue == "form")
    }

    // MARK: - Round-trip from raw value

    @Test("All cases can be constructed from raw values")
    func roundTripRawValues() {
        for tag in RuleTag.allCases {
            let reconstructed = RuleTag(rawValue: tag.rawValue)
            #expect(reconstructed == tag)
        }
    }

    @Test("Invalid raw value returns nil")
    func invalidRawValue() {
        #expect(RuleTag(rawValue: "invalid") == nil)
        #expect(RuleTag(rawValue: "") == nil)
        #expect(RuleTag(rawValue: "CRITICAL") == nil) // case sensitive
        #expect(RuleTag(rawValue: "altText") == nil) // wrong format, should be "alt-text"
    }

    @Test("alt-text raw value requires hyphen")
    func altTextRequiresHyphen() {
        // "alt-text" is the raw value, not "altText"
        #expect(RuleTag(rawValue: "alt-text") == .altText)
        #expect(RuleTag(rawValue: "altText") == nil)
    }

    // MARK: - isSeverity

    @Test("isSeverity returns true for severity tags")
    func isSeverityTrue() {
        let severityTags: [RuleTag] = [.critical, .major, .minor, .cosmetic]
        for tag in severityTags {
            #expect(tag.isSeverity == true, "Expected \(tag) to be a severity tag")
        }
    }

    @Test("isSeverity returns false for non-severity tags")
    func isSeverityFalse() {
        let nonSeverity: [RuleTag] = [
            .machine, .human, .metadata, .structure, .text, .font,
            .annotation, .syntax, .artifact, .altText, .lang,
            .table, .list, .heading, .figure, .note, .toc, .form
        ]
        for tag in nonSeverity {
            #expect(tag.isSeverity == false, "Expected \(tag) to NOT be a severity tag")
        }
    }

    // MARK: - isCheckability

    @Test("isCheckability returns true for checkability tags")
    func isCheckabilityTrue() {
        #expect(RuleTag.machine.isCheckability == true)
        #expect(RuleTag.human.isCheckability == true)
    }

    @Test("isCheckability returns false for non-checkability tags")
    func isCheckabilityFalse() {
        let nonCheckability: [RuleTag] = [
            .critical, .major, .minor, .cosmetic, .metadata, .structure, .text,
            .font, .annotation, .syntax, .artifact, .altText, .lang,
            .table, .list, .heading, .figure, .note, .toc, .form
        ]
        for tag in nonCheckability {
            #expect(tag.isCheckability == false, "Expected \(tag) to NOT be a checkability tag")
        }
    }

    // MARK: - isCategory

    @Test("isCategory returns true for category tags")
    func isCategoryTrue() {
        let categoryTags: [RuleTag] = [.metadata, .structure, .text, .font, .annotation, .syntax, .artifact]
        for tag in categoryTags {
            #expect(tag.isCategory == true, "Expected \(tag) to be a category tag")
        }
    }

    @Test("isCategory returns false for non-category tags")
    func isCategoryFalse() {
        let nonCategory: [RuleTag] = [
            .critical, .major, .minor, .cosmetic, .machine, .human,
            .altText, .lang, .table, .list, .heading, .figure, .note, .toc, .form
        ]
        for tag in nonCategory {
            #expect(tag.isCategory == false, "Expected \(tag) to NOT be a category tag")
        }
    }

    // MARK: - isFeatureSpecific

    @Test("isFeatureSpecific returns true for feature-specific tags")
    func isFeatureSpecificTrue() {
        let featureTags: [RuleTag] = [.altText, .lang, .table, .list, .heading, .figure, .note, .toc, .form]
        for tag in featureTags {
            #expect(tag.isFeatureSpecific == true, "Expected \(tag) to be a feature-specific tag")
        }
    }

    @Test("isFeatureSpecific returns false for non-feature-specific tags")
    func isFeatureSpecificFalse() {
        let nonFeature: [RuleTag] = [
            .critical, .major, .minor, .cosmetic, .machine, .human,
            .metadata, .structure, .text, .font, .annotation, .syntax, .artifact
        ]
        for tag in nonFeature {
            #expect(tag.isFeatureSpecific == false, "Expected \(tag) to NOT be a feature-specific tag")
        }
    }

    // MARK: - Classification completeness

    @Test("Every tag falls into exactly one classification")
    func everyTagHasOneClassification() {
        for tag in RuleTag.allCases {
            let classifications = [
                tag.isSeverity,
                tag.isCheckability,
                tag.isCategory,
                tag.isFeatureSpecific
            ]
            let trueCount = classifications.filter { $0 }.count
            #expect(trueCount == 1, "Expected \(tag) to fall into exactly 1 classification, got \(trueCount)")
        }
    }

    @Test("Classification counts sum to total case count")
    func classificationCountsSum() {
        let severityCount = RuleTag.allCases.filter(\.isSeverity).count
        let checkabilityCount = RuleTag.allCases.filter(\.isCheckability).count
        let categoryCount = RuleTag.allCases.filter(\.isCategory).count
        let featureCount = RuleTag.allCases.filter(\.isFeatureSpecific).count

        #expect(severityCount == 4)
        #expect(checkabilityCount == 2)
        #expect(categoryCount == 7)
        #expect(featureCount == 9)
        #expect(severityCount + checkabilityCount + categoryCount + featureCount == 22)
    }

    // MARK: - Codable

    @Test("RuleTag round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for tag in RuleTag.allCases {
            let data = try encoder.encode(tag)
            let decoded = try decoder.decode(RuleTag.self, from: data)
            #expect(decoded == tag)
        }
    }

    @Test("RuleTag encodes to expected JSON strings")
    func codableEncodesCorrectly() throws {
        let encoder = JSONEncoder()

        let criticalData = try encoder.encode(RuleTag.critical)
        #expect(String(data: criticalData, encoding: .utf8) == "\"critical\"")

        let altTextData = try encoder.encode(RuleTag.altText)
        #expect(String(data: altTextData, encoding: .utf8) == "\"alt-text\"")
    }

    @Test("RuleTag decodes from hyphenated JSON string")
    func codableDecodesHyphenated() throws {
        let decoder = JSONDecoder()
        let data = "\"alt-text\"".data(using: .utf8)!
        let decoded = try decoder.decode(RuleTag.self, from: data)
        #expect(decoded == .altText)
    }

    // MARK: - Set usage

    @Test("RuleTag works in Set collections")
    func setUsage() {
        let tags: Set<RuleTag> = [.critical, .machine, .altText, .figure]
        #expect(tags.count == 4)
        #expect(tags.contains(.critical))
        #expect(tags.contains(.machine))
        #expect(tags.contains(.altText))
        #expect(tags.contains(.figure))
        #expect(!tags.contains(.minor))
    }

    // MARK: - Unique raw values

    @Test("All raw values are unique")
    func uniqueRawValues() {
        let rawValues = RuleTag.allCases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)
        #expect(rawValues.count == uniqueRawValues.count)
    }
}
