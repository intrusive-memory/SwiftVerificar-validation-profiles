import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("PDFFlavour Tests")
struct PDFFlavourTests {

    // MARK: - Case Count

    @Test("PDFFlavour has exactly 16 cases")
    func caseCount() {
        #expect(PDFFlavour.allCases.count == 16)
    }

    // MARK: - Raw Values

    @Test("PDF/A raw values are correct")
    func pdfARawValues() {
        #expect(PDFFlavour.pdfA1a.rawValue == "PDFA_1_A")
        #expect(PDFFlavour.pdfA1b.rawValue == "PDFA_1_B")
        #expect(PDFFlavour.pdfA2a.rawValue == "PDFA_2_A")
        #expect(PDFFlavour.pdfA2b.rawValue == "PDFA_2_B")
        #expect(PDFFlavour.pdfA2u.rawValue == "PDFA_2_U")
        #expect(PDFFlavour.pdfA3a.rawValue == "PDFA_3_A")
        #expect(PDFFlavour.pdfA3b.rawValue == "PDFA_3_B")
        #expect(PDFFlavour.pdfA3u.rawValue == "PDFA_3_U")
        #expect(PDFFlavour.pdfA4.rawValue == "PDFA_4")
        #expect(PDFFlavour.pdfA4e.rawValue == "PDFA_4_E")
        #expect(PDFFlavour.pdfA4f.rawValue == "PDFA_4_F")
    }

    @Test("PDF/UA raw values are correct")
    func pdfUARawValues() {
        #expect(PDFFlavour.pdfUA1.rawValue == "PDFUA_1")
        #expect(PDFFlavour.pdfUA2.rawValue == "PDFUA_2")
    }

    @Test("WCAG raw value is correct")
    func wcagRawValue() {
        #expect(PDFFlavour.wcag22.rawValue == "WCAG_2_2")
    }

    @Test("WTPDF raw values are correct")
    func wtpdfRawValues() {
        #expect(PDFFlavour.wtpdf1Accessibility.rawValue == "WTPDF_1_0_ACCESSIBILITY")
        #expect(PDFFlavour.wtpdf1Reuse.rawValue == "WTPDF_1_0_REUSE")
    }

    // MARK: - Round-trip from raw value

    @Test("All cases can be constructed from raw values")
    func roundTripRawValues() {
        for flavour in PDFFlavour.allCases {
            let reconstructed = PDFFlavour(rawValue: flavour.rawValue)
            #expect(reconstructed == flavour)
        }
    }

    @Test("Invalid raw value returns nil")
    func invalidRawValue() {
        #expect(PDFFlavour(rawValue: "INVALID") == nil)
        #expect(PDFFlavour(rawValue: "") == nil)
        #expect(PDFFlavour(rawValue: "pdfa_1_a") == nil) // case sensitive
    }

    // MARK: - isPDFA

    @Test("isPDFA returns true for all PDF/A flavours")
    func isPDFATrue() {
        let pdfAFlavours: [PDFFlavour] = [
            .pdfA1a, .pdfA1b, .pdfA2a, .pdfA2b, .pdfA2u,
            .pdfA3a, .pdfA3b, .pdfA3u, .pdfA4, .pdfA4e, .pdfA4f
        ]
        for flavour in pdfAFlavours {
            #expect(flavour.isPDFA == true, "Expected \(flavour) to be PDF/A")
        }
    }

    @Test("isPDFA returns false for non-PDF/A flavours")
    func isPDFAFalse() {
        let nonPDFA: [PDFFlavour] = [.pdfUA1, .pdfUA2, .wcag22, .wtpdf1Accessibility, .wtpdf1Reuse]
        for flavour in nonPDFA {
            #expect(flavour.isPDFA == false, "Expected \(flavour) to NOT be PDF/A")
        }
    }

    // MARK: - isPDFUA

    @Test("isPDFUA returns true for PDF/UA flavours")
    func isPDFUATrue() {
        #expect(PDFFlavour.pdfUA1.isPDFUA == true)
        #expect(PDFFlavour.pdfUA2.isPDFUA == true)
    }

    @Test("isPDFUA returns false for non-PDF/UA flavours")
    func isPDFUAFalse() {
        let nonUA: [PDFFlavour] = [
            .pdfA1a, .pdfA1b, .pdfA2a, .pdfA2b, .pdfA2u,
            .pdfA3a, .pdfA3b, .pdfA3u, .pdfA4, .pdfA4e, .pdfA4f,
            .wcag22, .wtpdf1Accessibility, .wtpdf1Reuse
        ]
        for flavour in nonUA {
            #expect(flavour.isPDFUA == false, "Expected \(flavour) to NOT be PDF/UA")
        }
    }

    // MARK: - isAccessibilityRelated

    @Test("isAccessibilityRelated returns true for accessibility flavours")
    func isAccessibilityRelatedTrue() {
        let accessible: [PDFFlavour] = [.pdfUA1, .pdfUA2, .wcag22, .wtpdf1Accessibility]
        for flavour in accessible {
            #expect(flavour.isAccessibilityRelated == true, "Expected \(flavour) to be accessibility-related")
        }
    }

    @Test("isAccessibilityRelated returns false for non-accessibility flavours")
    func isAccessibilityRelatedFalse() {
        let nonAccessible: [PDFFlavour] = [
            .pdfA1a, .pdfA1b, .pdfA2a, .pdfA2b, .pdfA2u,
            .pdfA3a, .pdfA3b, .pdfA3u, .pdfA4, .pdfA4e, .pdfA4f,
            .wtpdf1Reuse
        ]
        for flavour in nonAccessible {
            #expect(flavour.isAccessibilityRelated == false, "Expected \(flavour) to NOT be accessibility-related")
        }
    }

    // MARK: - specification

    @Test("PDF/A-1 flavours map to ISO 19005-1")
    func specificationPDFA1() {
        #expect(PDFFlavour.pdfA1a.specification == .iso190051)
        #expect(PDFFlavour.pdfA1b.specification == .iso190051)
    }

    @Test("PDF/A-2 flavours map to ISO 19005-2")
    func specificationPDFA2() {
        #expect(PDFFlavour.pdfA2a.specification == .iso190052)
        #expect(PDFFlavour.pdfA2b.specification == .iso190052)
        #expect(PDFFlavour.pdfA2u.specification == .iso190052)
    }

    @Test("PDF/A-3 flavours map to ISO 19005-3")
    func specificationPDFA3() {
        #expect(PDFFlavour.pdfA3a.specification == .iso190053)
        #expect(PDFFlavour.pdfA3b.specification == .iso190053)
        #expect(PDFFlavour.pdfA3u.specification == .iso190053)
    }

    @Test("PDF/A-4 flavours map to ISO 19005-4")
    func specificationPDFA4() {
        #expect(PDFFlavour.pdfA4.specification == .iso190054)
        #expect(PDFFlavour.pdfA4e.specification == .iso190054)
        #expect(PDFFlavour.pdfA4f.specification == .iso190054)
    }

    @Test("PDF/UA flavours map to correct ISO specs")
    func specificationPDFUA() {
        #expect(PDFFlavour.pdfUA1.specification == .iso142891)
        #expect(PDFFlavour.pdfUA2.specification == .iso142892)
    }

    @Test("WCAG 2.2 maps to WCAG spec")
    func specificationWCAG() {
        #expect(PDFFlavour.wcag22.specification == .wcag22)
    }

    @Test("WTPDF flavours map to ISO 32000-2")
    func specificationWTPDF() {
        #expect(PDFFlavour.wtpdf1Accessibility.specification == .iso320002)
        #expect(PDFFlavour.wtpdf1Reuse.specification == .iso320002)
    }

    // MARK: - displayName

    @Test("All flavours have non-empty display names")
    func displayNamesNotEmpty() {
        for flavour in PDFFlavour.allCases {
            #expect(!flavour.displayName.isEmpty, "Expected non-empty display name for \(flavour)")
        }
    }

    @Test("Display names contain expected text")
    func displayNamesContainExpectedText() {
        #expect(PDFFlavour.pdfA1a.displayName == "PDF/A-1a")
        #expect(PDFFlavour.pdfUA2.displayName == "PDF/UA-2")
        #expect(PDFFlavour.wcag22.displayName == "WCAG 2.2")
        #expect(PDFFlavour.wtpdf1Accessibility.displayName == "WTPDF 1.0 Accessibility")
        #expect(PDFFlavour.wtpdf1Reuse.displayName == "WTPDF 1.0 Reuse")
    }

    // MARK: - Codable

    @Test("PDFFlavour round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for flavour in PDFFlavour.allCases {
            let data = try encoder.encode(flavour)
            let decoded = try decoder.decode(PDFFlavour.self, from: data)
            #expect(decoded == flavour)
        }
    }

    @Test("PDFFlavour encodes to expected JSON string")
    func codableEncodesCorrectly() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(PDFFlavour.pdfUA2)
        let jsonString = String(data: data, encoding: .utf8)
        #expect(jsonString == "\"PDFUA_2\"")
    }

    // MARK: - Sendable and CaseIterable conformance

    @Test("PDFFlavour conforms to CaseIterable")
    func caseIterableConformance() {
        let allCases = PDFFlavour.allCases
        #expect(allCases.contains(.pdfA1a))
        #expect(allCases.contains(.pdfUA2))
        #expect(allCases.contains(.wcag22))
        #expect(allCases.contains(.wtpdf1Reuse))
    }

    @Test("All raw values are unique")
    func uniqueRawValues() {
        let rawValues = PDFFlavour.allCases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)
        #expect(rawValues.count == uniqueRawValues.count)
    }
}
