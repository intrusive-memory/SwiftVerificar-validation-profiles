import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileLoadError Tests")
struct ProfileLoadErrorTests {

    // MARK: - Error Cases

    @Test("profileNotFound stores flavour")
    func profileNotFound() {
        let error = ProfileLoadError.profileNotFound(.pdfUA2)

        if case .profileNotFound(let flavour) = error {
            #expect(flavour == .pdfUA2)
        } else {
            Issue.record("Expected profileNotFound case")
        }
    }

    @Test("resourceBundleUnavailable case exists")
    func resourceBundleUnavailable() {
        let error = ProfileLoadError.resourceBundleUnavailable
        if case .resourceBundleUnavailable = error {
            // Success
        } else {
            Issue.record("Expected resourceBundleUnavailable case")
        }
    }

    @Test("fileReadError stores path")
    func fileReadError() {
        let error = ProfileLoadError.fileReadError("/path/to/file.xml")

        if case .fileReadError(let path) = error {
            #expect(path == "/path/to/file.xml")
        } else {
            Issue.record("Expected fileReadError case")
        }
    }

    // MARK: - Equatable

    @Test("Same profileNotFound are equal")
    func profileNotFoundEquality() {
        #expect(ProfileLoadError.profileNotFound(.pdfUA1) == ProfileLoadError.profileNotFound(.pdfUA1))
    }

    @Test("Different profileNotFound are not equal")
    func profileNotFoundInequality() {
        #expect(ProfileLoadError.profileNotFound(.pdfUA1) != ProfileLoadError.profileNotFound(.pdfUA2))
    }

    @Test("resourceBundleUnavailable equals resourceBundleUnavailable")
    func resourceBundleUnavailableEquality() {
        #expect(ProfileLoadError.resourceBundleUnavailable == ProfileLoadError.resourceBundleUnavailable)
    }

    @Test("Same fileReadError are equal")
    func fileReadErrorEquality() {
        #expect(ProfileLoadError.fileReadError("/a/b") == ProfileLoadError.fileReadError("/a/b"))
    }

    @Test("Different fileReadError are not equal")
    func fileReadErrorInequality() {
        #expect(ProfileLoadError.fileReadError("/a") != ProfileLoadError.fileReadError("/b"))
    }

    @Test("Different error types are not equal")
    func differentTypesInequality() {
        #expect(ProfileLoadError.resourceBundleUnavailable != ProfileLoadError.fileReadError("/path"))
        #expect(ProfileLoadError.profileNotFound(.pdfUA2) != ProfileLoadError.resourceBundleUnavailable)
    }

    // MARK: - LocalizedError

    @Test("profileNotFound has error description")
    func profileNotFoundErrorDescription() {
        let error = ProfileLoadError.profileNotFound(.pdfUA2)
        #expect(error.errorDescription?.contains("PDF/UA-2") == true)
        #expect(error.errorDescription?.contains("not found") == true)
    }

    @Test("resourceBundleUnavailable has error description")
    func resourceBundleUnavailableErrorDescription() {
        let error = ProfileLoadError.resourceBundleUnavailable
        #expect(error.errorDescription?.contains("bundle") == true)
        #expect(error.errorDescription?.contains("not available") == true)
    }

    @Test("fileReadError has error description")
    func fileReadErrorErrorDescription() {
        let error = ProfileLoadError.fileReadError("/some/path.xml")
        #expect(error.errorDescription?.contains("/some/path.xml") == true)
        #expect(error.errorDescription?.contains("read") == true)
    }

    // MARK: - Error Protocol

    @Test("ProfileLoadError conforms to Error")
    func conformsToError() {
        let error: Error = ProfileLoadError.resourceBundleUnavailable
        #expect(error is ProfileLoadError)
    }

    @Test("ProfileLoadError can be thrown and caught")
    func canBeThrown() throws {
        func throwingFunction() throws {
            throw ProfileLoadError.profileNotFound(.pdfA1a)
        }

        #expect(throws: ProfileLoadError.self) {
            try throwingFunction()
        }
    }

    // MARK: - All Flavours

    @Test("profileNotFound works for all flavours")
    func profileNotFoundAllFlavours() {
        for flavour in PDFFlavour.allCases {
            let error = ProfileLoadError.profileNotFound(flavour)
            if case .profileNotFound(let stored) = error {
                #expect(stored == flavour)
            } else {
                Issue.record("Expected profileNotFound case for \(flavour)")
            }
        }
    }
}
