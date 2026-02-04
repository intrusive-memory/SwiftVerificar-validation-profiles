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

    @Test("ProfileType has correct display names")
    func profileTypeDisplayNames() {
        #expect(ProfileType.pdfUA2.displayName == "PDF/UA-2 (ISO 14289-2:2024)")
        #expect(ProfileType.pdfA1a.displayName == "PDF/A-1a (ISO 19005-1 Level A)")
    }

    @Test("ProfileType correctly identifies accessibility profiles")
    func accessibilityProfiles() {
        #expect(ProfileType.pdfUA1.isAccessibilityProfile == true)
        #expect(ProfileType.pdfUA2.isAccessibilityProfile == true)
        #expect(ProfileType.pdfA1a.isAccessibilityProfile == false)
    }

    @Test("ProfileLoader lists all available profiles")
    func profileLoaderListsProfiles() async {
        let loader = ProfileLoader()
        let profiles = await loader.availableProfiles()
        #expect(profiles.count == ProfileType.allCases.count)
    }
}
