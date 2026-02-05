import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("Specification Tests")
struct SpecificationTests {

    // MARK: - Case Count

    @Test("Specification has exactly 11 cases")
    func caseCount() {
        #expect(Specification.allCases.count == 11)
    }

    // MARK: - Raw Values

    @Test("PDF/A specification raw values are correct")
    func pdfARawValues() {
        #expect(Specification.iso190051.rawValue == "ISO_19005_1")
        #expect(Specification.iso190052.rawValue == "ISO_19005_2")
        #expect(Specification.iso190053.rawValue == "ISO_19005_3")
        #expect(Specification.iso190054.rawValue == "ISO_19005_4")
    }

    @Test("PDF/UA specification raw values are correct")
    func pdfUARawValues() {
        #expect(Specification.iso142891.rawValue == "ISO_14289_1")
        #expect(Specification.iso142892.rawValue == "ISO_14289_2")
    }

    @Test("PDF base specification raw values are correct")
    func pdfBaseRawValues() {
        #expect(Specification.iso320001.rawValue == "ISO_32000_1")
        #expect(Specification.iso320002.rawValue == "ISO_32000_2")
        #expect(Specification.iso32005.rawValue == "ISO_32005")
    }

    @Test("WCAG and noStandard raw values are correct")
    func otherRawValues() {
        #expect(Specification.wcag22.rawValue == "WCAG_2_2")
        #expect(Specification.noStandard.rawValue == "NO_STANDARD")
    }

    // MARK: - Round-trip from raw value

    @Test("All cases can be constructed from raw values")
    func roundTripRawValues() {
        for spec in Specification.allCases {
            let reconstructed = Specification(rawValue: spec.rawValue)
            #expect(reconstructed == spec)
        }
    }

    @Test("Invalid raw value returns nil")
    func invalidRawValue() {
        #expect(Specification(rawValue: "INVALID") == nil)
        #expect(Specification(rawValue: "") == nil)
        #expect(Specification(rawValue: "iso_19005_1") == nil) // case sensitive
    }

    // MARK: - displayName

    @Test("All specifications have non-empty display names")
    func displayNamesNotEmpty() {
        for spec in Specification.allCases {
            #expect(!spec.displayName.isEmpty, "Expected non-empty display name for \(spec)")
        }
    }

    @Test("Display names contain expected text")
    func displayNamesContainExpectedText() {
        #expect(Specification.iso190051.displayName == "ISO 19005-1 (PDF/A-1)")
        #expect(Specification.iso142892.displayName == "ISO 14289-2 (PDF/UA-2)")
        #expect(Specification.iso320001.displayName == "ISO 32000-1 (PDF 1.7)")
        #expect(Specification.iso320002.displayName == "ISO 32000-2 (PDF 2.0)")
        #expect(Specification.iso32005.displayName == "ISO 32005 (Tagged PDF)")
        #expect(Specification.wcag22.displayName == "WCAG 2.2")
        #expect(Specification.noStandard.displayName == "No Standard")
    }

    // MARK: - isPDFA

    @Test("isPDFA returns true for PDF/A specifications")
    func isPDFATrue() {
        let pdfASpecs: [Specification] = [.iso190051, .iso190052, .iso190053, .iso190054]
        for spec in pdfASpecs {
            #expect(spec.isPDFA == true, "Expected \(spec) to be PDF/A")
        }
    }

    @Test("isPDFA returns false for non-PDF/A specifications")
    func isPDFAFalse() {
        let nonPDFA: [Specification] = [.iso142891, .iso142892, .iso320001, .iso320002, .iso32005, .wcag22, .noStandard]
        for spec in nonPDFA {
            #expect(spec.isPDFA == false, "Expected \(spec) to NOT be PDF/A")
        }
    }

    // MARK: - isPDFUA

    @Test("isPDFUA returns true for PDF/UA specifications")
    func isPDFUATrue() {
        #expect(Specification.iso142891.isPDFUA == true)
        #expect(Specification.iso142892.isPDFUA == true)
    }

    @Test("isPDFUA returns false for non-PDF/UA specifications")
    func isPDFUAFalse() {
        let nonUA: [Specification] = [.iso190051, .iso190052, .iso190053, .iso190054, .iso320001, .iso320002, .iso32005, .wcag22, .noStandard]
        for spec in nonUA {
            #expect(spec.isPDFUA == false, "Expected \(spec) to NOT be PDF/UA")
        }
    }

    // MARK: - isAccessibilityRelated

    @Test("isAccessibilityRelated returns true for accessibility specifications")
    func isAccessibilityRelatedTrue() {
        let accessible: [Specification] = [.iso142891, .iso142892, .wcag22]
        for spec in accessible {
            #expect(spec.isAccessibilityRelated == true, "Expected \(spec) to be accessibility-related")
        }
    }

    @Test("isAccessibilityRelated returns false for non-accessibility specifications")
    func isAccessibilityRelatedFalse() {
        let nonAccessible: [Specification] = [.iso190051, .iso190052, .iso190053, .iso190054, .iso320001, .iso320002, .iso32005, .noStandard]
        for spec in nonAccessible {
            #expect(spec.isAccessibilityRelated == false, "Expected \(spec) to NOT be accessibility-related")
        }
    }

    // MARK: - Codable

    @Test("Specification round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for spec in Specification.allCases {
            let data = try encoder.encode(spec)
            let decoded = try decoder.decode(Specification.self, from: data)
            #expect(decoded == spec)
        }
    }

    @Test("Specification encodes to expected JSON string")
    func codableEncodesCorrectly() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(Specification.iso142892)
        let jsonString = String(data: data, encoding: .utf8)
        #expect(jsonString == "\"ISO_14289_2\"")
    }

    // MARK: - Unique raw values

    @Test("All raw values are unique")
    func uniqueRawValues() {
        let rawValues = Specification.allCases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)
        #expect(rawValues.count == uniqueRawValues.count)
    }
}
