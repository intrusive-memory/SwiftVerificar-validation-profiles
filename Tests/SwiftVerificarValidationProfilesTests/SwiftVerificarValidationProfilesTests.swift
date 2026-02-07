import Testing
@testable import SwiftVerificarValidationProfiles

@Suite("SwiftVerificarValidationProfiles Tests")
struct SwiftVerificarValidationProfilesTests {

    @Test("Library version is set correctly")
    func versionIsSet() {
        #expect(SwiftVerificarValidationProfiles.version == "0.1.0")
    }

    @Test("Profiles can be instantiated")
    func canInstantiate() {
        let profiles = SwiftVerificarValidationProfiles()
        #expect(profiles != nil)
    }

    @Test("PDFFlavour correctly identifies accessibility profiles")
    func accessibilityProfiles() {
        #expect(PDFFlavour.pdfUA1.isAccessibilityRelated == true)
        #expect(PDFFlavour.pdfUA2.isAccessibilityRelated == true)
        #expect(PDFFlavour.wcag22.isAccessibilityRelated == true)
        #expect(PDFFlavour.pdfA1a.isAccessibilityRelated == false)
    }

    @Test("PDFFlavour has correct display names")
    func flavourDisplayNames() {
        #expect(PDFFlavour.pdfUA2.displayName == "PDF/UA-2")
        #expect(PDFFlavour.pdfA1a.displayName == "PDF/A-1a")
    }
}
