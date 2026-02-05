import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("PDFObjectType Tests")
struct PDFObjectTypeTests {

    // MARK: - Case Count

    @Test("PDFObjectType has exactly 188 cases")
    func caseCount() {
        #expect(PDFObjectType.allCases.count == 188)
    }

    // MARK: - COS Layer Raw Values (19 + 4 = 23 cases)

    @Test("COS layer raw values are correct")
    func cosLayerRawValues() {
        #expect(PDFObjectType.cosArray.rawValue == "CosArray")
        #expect(PDFObjectType.cosBBox.rawValue == "CosBBox")
        #expect(PDFObjectType.cosBM.rawValue == "CosBM")
        #expect(PDFObjectType.cosDict.rawValue == "CosDict")
        #expect(PDFObjectType.cosDocument.rawValue == "CosDocument")
        #expect(PDFObjectType.cosFileSpecification.rawValue == "CosFileSpecification")
        #expect(PDFObjectType.cosFilter.rawValue == "CosFilter")
        #expect(PDFObjectType.cosIIFilter.rawValue == "CosIIFilter")
        #expect(PDFObjectType.cosIndirect.rawValue == "CosIndirect")
        #expect(PDFObjectType.cosInfo.rawValue == "CosInfo")
        #expect(PDFObjectType.cosInteger.rawValue == "CosInteger")
        #expect(PDFObjectType.cosName.rawValue == "CosName")
        #expect(PDFObjectType.cosReal.rawValue == "CosReal")
        #expect(PDFObjectType.cosRenderingIntent.rawValue == "CosRenderingIntent")
        #expect(PDFObjectType.cosStream.rawValue == "CosStream")
        #expect(PDFObjectType.cosString.rawValue == "CosString")
        #expect(PDFObjectType.cosTrailer.rawValue == "CosTrailer")
        #expect(PDFObjectType.cosUnicodeName.rawValue == "CosUnicodeName")
        #expect(PDFObjectType.cosXRef.rawValue == "CosXRef")
    }

    @Test("COS text/language raw values are correct")
    func cosTextLanguageRawValues() {
        #expect(PDFObjectType.cosActualText.rawValue == "CosActualText")
        #expect(PDFObjectType.cosAlt.rawValue == "CosAlt")
        #expect(PDFObjectType.cosLang.rawValue == "CosLang")
        #expect(PDFObjectType.cosTextString.rawValue == "CosTextString")
    }

    // MARK: - PD Layer Raw Values

    @Test("PD document raw values are correct")
    func pdDocumentRawValues() {
        #expect(PDFObjectType.pdDocument.rawValue == "PDDocument")
        #expect(PDFObjectType.pdPage.rawValue == "PDPage")
        #expect(PDFObjectType.pdContentStream.rawValue == "PDContentStream")
        #expect(PDFObjectType.pdEncryption.rawValue == "PDEncryption")
        #expect(PDFObjectType.pdPerms.rawValue == "PDPerms")
        #expect(PDFObjectType.pdOutline.rawValue == "PDOutline")
    }

    @Test("PD identification raw values are correct")
    func pdIdentificationRawValues() {
        #expect(PDFObjectType.pdfaIdentification.rawValue == "PDFAIdentification")
        #expect(PDFObjectType.pdfuaIdentification.rawValue == "PDFUAIdentification")
        #expect(PDFObjectType.pdUAIdentification.rawValue == "PDUAIdentification")
        #expect(PDFObjectType.mainXMPPackage.rawValue == "MainXMPPackage")
    }

    @Test("PD structure raw values are correct")
    func pdStructureRawValues() {
        #expect(PDFObjectType.pdStructTreeRoot.rawValue == "PDStructTreeRoot")
        #expect(PDFObjectType.pdStructElem.rawValue == "PDStructElem")
    }

    @Test("PD annotation raw values are correct")
    func pdAnnotationRawValues() {
        #expect(PDFObjectType.pdAnnot.rawValue == "PDAnnot")
        #expect(PDFObjectType.pd3DAnnot.rawValue == "PD3DAnnot")
        #expect(PDFObjectType.pdFileAttachmentAnnot.rawValue == "PDFileAttachmentAnnot")
        #expect(PDFObjectType.pdInkAnnot.rawValue == "PDInkAnnot")
        #expect(PDFObjectType.pdLinkAnnot.rawValue == "PDLinkAnnot")
        #expect(PDFObjectType.pdMarkupAnnot.rawValue == "PDMarkupAnnot")
        #expect(PDFObjectType.pdMovieAnnot.rawValue == "PDMovieAnnot")
        #expect(PDFObjectType.pdPopupAnnot.rawValue == "PDPopupAnnot")
        #expect(PDFObjectType.pdPrinterMarkAnnot.rawValue == "PDPrinterMarkAnnot")
        #expect(PDFObjectType.pdRichMediaAnnot.rawValue == "PDRichMediaAnnot")
        #expect(PDFObjectType.pdRubberStampAnnot.rawValue == "PDRubberStampAnnot")
        #expect(PDFObjectType.pdScreenAnnot.rawValue == "PDScreenAnnot")
        #expect(PDFObjectType.pdSoundAnnot.rawValue == "PDSoundAnnot")
        #expect(PDFObjectType.pdTrapNetAnnot.rawValue == "PDTrapNetAnnot")
        #expect(PDFObjectType.pdWatermarkAnnot.rawValue == "PDWatermarkAnnot")
        #expect(PDFObjectType.pdWidgetAnnot.rawValue == "PDWidgetAnnot")
    }

    @Test("PD forms raw values are correct")
    func pdFormsRawValues() {
        #expect(PDFObjectType.pdAcroForm.rawValue == "PDAcroForm")
        #expect(PDFObjectType.pdFormField.rawValue == "PDFormField")
        #expect(PDFObjectType.pdTextField.rawValue == "PDTextField")
    }

    @Test("PD actions/destinations raw values are correct")
    func pdActionsRawValues() {
        #expect(PDFObjectType.pdAction.rawValue == "PDAction")
        #expect(PDFObjectType.pdAdditionalActions.rawValue == "PDAdditionalActions")
        #expect(PDFObjectType.pdDestination.rawValue == "PDDestination")
        #expect(PDFObjectType.pdGoToAction.rawValue == "PDGoToAction")
        #expect(PDFObjectType.pdNamedAction.rawValue == "PDNamedAction")
    }

    @Test("PD font raw values are correct")
    func pdFontRawValues() {
        #expect(PDFObjectType.pdFont.rawValue == "PDFont")
        #expect(PDFObjectType.pdSimpleFont.rawValue == "PDSimpleFont")
        #expect(PDFObjectType.pdType0Font.rawValue == "PDType0Font")
        #expect(PDFObjectType.pdType1Font.rawValue == "PDType1Font")
        #expect(PDFObjectType.pdTrueTypeFont.rawValue == "PDTrueTypeFont")
        #expect(PDFObjectType.pdCIDFont.rawValue == "PDCIDFont")
        #expect(PDFObjectType.pdCMap.rawValue == "PDCMap")
        #expect(PDFObjectType.pdReferencedCMap.rawValue == "PDReferencedCMap")
        #expect(PDFObjectType.cMapFile.rawValue == "CMapFile")
        #expect(PDFObjectType.glyph.rawValue == "Glyph")
    }

    @Test("PD color space raw values are correct")
    func pdColorSpaceRawValues() {
        #expect(PDFObjectType.pdDeviceGray.rawValue == "PDDeviceGray")
        #expect(PDFObjectType.pdDeviceRGB.rawValue == "PDDeviceRGB")
        #expect(PDFObjectType.pdDeviceCMYK.rawValue == "PDDeviceCMYK")
        #expect(PDFObjectType.pdDeviceN.rawValue == "PDDeviceN")
        #expect(PDFObjectType.pdICCBasedCMYK.rawValue == "PDICCBasedCMYK")
        #expect(PDFObjectType.pdSeparation.rawValue == "PDSeparation")
        #expect(PDFObjectType.transparencyColorSpace.rawValue == "TransparencyColorSpace")
    }

    @Test("PD graphics raw values are correct")
    func pdGraphicsRawValues() {
        #expect(PDFObjectType.pdExtGState.rawValue == "PDExtGState")
        #expect(PDFObjectType.pdGroup.rawValue == "PDGroup")
        #expect(PDFObjectType.pdHalftone.rawValue == "PDHalftone")
        #expect(PDFObjectType.pdXObject.rawValue == "PDXObject")
        #expect(PDFObjectType.pdXImage.rawValue == "PDXImage")
        #expect(PDFObjectType.pdXForm.rawValue == "PDXForm")
        #expect(PDFObjectType.pdMaskImage.rawValue == "PDMaskImage")
        #expect(PDFObjectType.pd3DStream.rawValue == "PD3DStream")
    }

    @Test("PD other raw values are correct")
    func pdOtherRawValues() {
        #expect(PDFObjectType.pdMediaClip.rawValue == "PDMediaClip")
        #expect(PDFObjectType.pdMetadata.rawValue == "PDMetadata")
        #expect(PDFObjectType.pdOCConfig.rawValue == "PDOCConfig")
        #expect(PDFObjectType.pdSigRef.rawValue == "PDSigRef")
        #expect(PDFObjectType.pdSignature.rawValue == "PDSignature")
        #expect(PDFObjectType.outputIntents.rawValue == "OutputIntents")
        #expect(PDFObjectType.embeddedFile.rawValue == "EmbeddedFile")
    }

    // MARK: - Operator Raw Values

    @Test("Operator raw values are correct")
    func operatorRawValues() {
        #expect(PDFObjectType.opUndefined.rawValue == "Op_Undefined")
        #expect(PDFObjectType.opQGsave.rawValue == "Op_q_gsave")
    }

    // MARK: - External Object Raw Values

    @Test("External object raw values are correct")
    func externalObjectRawValues() {
        #expect(PDFObjectType.iccProfile.rawValue == "ICCProfile")
        #expect(PDFObjectType.iccInputProfile.rawValue == "ICCInputProfile")
        #expect(PDFObjectType.iccOutputProfile.rawValue == "ICCOutputProfile")
        #expect(PDFObjectType.jpeg2000.rawValue == "JPEG2000")
        #expect(PDFObjectType.trueTypeFontProgram.rawValue == "TrueTypeFontProgram")
        #expect(PDFObjectType.pkcsDataObject.rawValue == "PKCSDataObject")
    }

    // MARK: - XMP Metadata Raw Values

    @Test("XMP metadata raw values are correct")
    func xmpMetadataRawValues() {
        #expect(PDFObjectType.xmpPackage.rawValue == "XMPPackage")
        #expect(PDFObjectType.xmpProperty.rawValue == "XMPProperty")
        #expect(PDFObjectType.xmpLangAlt.rawValue == "XMPLangAlt")
        #expect(PDFObjectType.extensionSchemaDefinition.rawValue == "ExtensionSchemaDefinition")
        #expect(PDFObjectType.extensionSchemaField.rawValue == "ExtensionSchemaField")
        #expect(PDFObjectType.extensionSchemaObject.rawValue == "ExtensionSchemaObject")
        #expect(PDFObjectType.extensionSchemaProperty.rawValue == "ExtensionSchemaProperty")
        #expect(PDFObjectType.extensionSchemaValueType.rawValue == "ExtensionSchemaValueType")
        #expect(PDFObjectType.extensionSchemasContainer.rawValue == "ExtensionSchemasContainer")
    }

    // MARK: - SE Layer Raw Values (spot checks for the 48 cases)

    @Test("SE layer raw values are correct for key structure elements")
    func seLayerRawValues() {
        #expect(PDFObjectType.seAnnot.rawValue == "SEAnnot")
        #expect(PDFObjectType.seArt.rawValue == "SEArt")
        #expect(PDFObjectType.seArtifact.rawValue == "SEArtifact")
        #expect(PDFObjectType.seDocument.rawValue == "SEDocument")
        #expect(PDFObjectType.seFigure.rawValue == "SEFigure")
        #expect(PDFObjectType.seH.rawValue == "SEH")
        #expect(PDFObjectType.seHn.rawValue == "SEHn")
        #expect(PDFObjectType.seL.rawValue == "SEL")
        #expect(PDFObjectType.seLI.rawValue == "SELI")
        #expect(PDFObjectType.seTable.rawValue == "SETable")
        #expect(PDFObjectType.seTD.rawValue == "SETD")
        #expect(PDFObjectType.seTH.rawValue == "SETH")
        #expect(PDFObjectType.seTR.rawValue == "SETR")
        #expect(PDFObjectType.seTOC.rawValue == "SETOC")
        #expect(PDFObjectType.seWarichu.rawValue == "SEWarichu")
        #expect(PDFObjectType.seCaption.rawValue == "SECaption")
        #expect(PDFObjectType.seCode.rawValue == "SECode")
        #expect(PDFObjectType.seDiv.rawValue == "SEDiv")
        #expect(PDFObjectType.seSect.rawValue == "SESect")
        #expect(PDFObjectType.seSpan.rawValue == "SESpan")
        #expect(PDFObjectType.seStrong.rawValue == "SEStrong")
        #expect(PDFObjectType.seEm.rawValue == "SEEm")
        #expect(PDFObjectType.seQuote.rawValue == "SEQuote")
        #expect(PDFObjectType.seBlockQuote.rawValue == "SEBlockQuote")
        #expect(PDFObjectType.seNote.rawValue == "SENote")
        #expect(PDFObjectType.seFENote.rawValue == "SEFENote")
        #expect(PDFObjectType.seForm.rawValue == "SEForm")
        #expect(PDFObjectType.seFormula.rawValue == "SEFormula")
        #expect(PDFObjectType.sePart.rawValue == "SEPart")
        #expect(PDFObjectType.seRuby.rawValue == "SERuby")
        #expect(PDFObjectType.seRB.rawValue == "SERB")
        #expect(PDFObjectType.seRP.rawValue == "SERP")
        #expect(PDFObjectType.seRT.rawValue == "SERT")
        #expect(PDFObjectType.seAside.rawValue == "SEAside")
        #expect(PDFObjectType.seBibEntry.rawValue == "SEBibEntry")
        #expect(PDFObjectType.seDocumentFragment.rawValue == "SEDocumentFragment")
        #expect(PDFObjectType.seGraphicContentItem.rawValue == "SEGraphicContentItem")
        #expect(PDFObjectType.seIndex.rawValue == "SEIndex")
        #expect(PDFObjectType.seLBody.rawValue == "SELBody")
        #expect(PDFObjectType.seMarkedContent.rawValue == "SEMarkedContent")
        #expect(PDFObjectType.seMathMLStructElem.rawValue == "SEMathMLStructElem")
        #expect(PDFObjectType.seMathMLStructureElement.rawValue == "SEMathMLStructureElement")
        #expect(PDFObjectType.seNonStandard.rawValue == "SENonStandard")
        #expect(PDFObjectType.seSimpleContentItem.rawValue == "SESimpleContentItem")
        #expect(PDFObjectType.seSub.rawValue == "SESub")
        #expect(PDFObjectType.seTBody.rawValue == "SETBody")
        #expect(PDFObjectType.seTFoot.rawValue == "SETFoot")
        #expect(PDFObjectType.seTHead.rawValue == "SETHead")
        #expect(PDFObjectType.seTOCI.rawValue == "SETOCI")
        #expect(PDFObjectType.seTableCell.rawValue == "SETableCell")
        #expect(PDFObjectType.seTextItem.rawValue == "SETextItem")
        #expect(PDFObjectType.seTitle.rawValue == "SETitle")
        #expect(PDFObjectType.seWP.rawValue == "SEWP")
        #expect(PDFObjectType.seWT.rawValue == "SEWT")
    }

    // MARK: - SA Layer Raw Values (27 cases)

    @Test("SA layer raw values are correct")
    func saLayerRawValues() {
        #expect(PDFObjectType.saCaption.rawValue == "SACaption")
        #expect(PDFObjectType.saFigure.rawValue == "SAFigure")
        #expect(PDFObjectType.saH.rawValue == "SAH")
        #expect(PDFObjectType.saHn.rawValue == "SAHn")
        #expect(PDFObjectType.saL.rawValue == "SAL")
        #expect(PDFObjectType.saLBody.rawValue == "SALBody")
        #expect(PDFObjectType.saLI.rawValue == "SALI")
        #expect(PDFObjectType.saLbl.rawValue == "SALbl")
        #expect(PDFObjectType.saLineArtChunk.rawValue == "SALineArtChunk")
        #expect(PDFObjectType.saLinkAnnotation.rawValue == "SALinkAnnotation")
        #expect(PDFObjectType.saListItem.rawValue == "SAListItem")
        #expect(PDFObjectType.saP.rawValue == "SAP")
        #expect(PDFObjectType.saRepeatedCharacters.rawValue == "SARepeatedCharacters")
        #expect(PDFObjectType.saSpan.rawValue == "SASpan")
        #expect(PDFObjectType.saStructElem.rawValue == "SAStructElem")
        #expect(PDFObjectType.saTBody.rawValue == "SATBody")
        #expect(PDFObjectType.saTD.rawValue == "SATD")
        #expect(PDFObjectType.saTFoot.rawValue == "SATFoot")
        #expect(PDFObjectType.saTH.rawValue == "SATH")
        #expect(PDFObjectType.saTHead.rawValue == "SATHead")
        #expect(PDFObjectType.saTOC.rawValue == "SATOC")
        #expect(PDFObjectType.saTOCI.rawValue == "SATOCI")
        #expect(PDFObjectType.saTR.rawValue == "SATR")
        #expect(PDFObjectType.saTable.rawValue == "SATable")
        #expect(PDFObjectType.saTableCell.rawValue == "SATableCell")
        #expect(PDFObjectType.saTextChunk.rawValue == "SATextChunk")
    }

    // MARK: - Round-trip from raw value

    @Test("All 188 cases can be constructed from raw values")
    func roundTripAllRawValues() {
        for objectType in PDFObjectType.allCases {
            let reconstructed = PDFObjectType(rawValue: objectType.rawValue)
            #expect(reconstructed == objectType, "Failed to round-trip \(objectType)")
        }
    }

    @Test("Invalid raw value returns nil")
    func invalidRawValue() {
        #expect(PDFObjectType(rawValue: "InvalidType") == nil)
        #expect(PDFObjectType(rawValue: "") == nil)
        #expect(PDFObjectType(rawValue: "cosarray") == nil) // case sensitive
    }

    // MARK: - Unique raw values

    @Test("All 188 raw values are unique")
    func uniqueRawValues() {
        let rawValues = PDFObjectType.allCases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)
        #expect(rawValues.count == uniqueRawValues.count)
    }

    // MARK: - Layer Classification

    @Test("COS layer objects are classified correctly")
    func cosLayerClassification() {
        let cosTypes: [PDFObjectType] = [
            .cosArray, .cosBBox, .cosBM, .cosDict, .cosDocument,
            .cosFileSpecification, .cosFilter, .cosIIFilter, .cosIndirect,
            .cosInfo, .cosInteger, .cosName, .cosReal, .cosRenderingIntent,
            .cosStream, .cosString, .cosTrailer, .cosUnicodeName, .cosXRef,
            .cosActualText, .cosAlt, .cosLang, .cosTextString
        ]
        for objectType in cosTypes {
            #expect(objectType.layer == .cos, "Expected \(objectType) to be in COS layer")
        }
        #expect(cosTypes.count == 23)
    }

    @Test("PD layer objects are classified correctly")
    func pdLayerClassification() {
        // Spot-check a few PD types
        #expect(PDFObjectType.pdDocument.layer == .pd)
        #expect(PDFObjectType.pdPage.layer == .pd)
        #expect(PDFObjectType.pdAnnot.layer == .pd)
        #expect(PDFObjectType.pdFont.layer == .pd)
        #expect(PDFObjectType.pdDeviceRGB.layer == .pd)
        #expect(PDFObjectType.pdStructTreeRoot.layer == .pd)
        #expect(PDFObjectType.pdStructElem.layer == .pd)
        #expect(PDFObjectType.pdAcroForm.layer == .pd)
        #expect(PDFObjectType.pdAction.layer == .pd)
        #expect(PDFObjectType.embeddedFile.layer == .pd)
        #expect(PDFObjectType.outputIntents.layer == .pd)
        #expect(PDFObjectType.pdfaIdentification.layer == .pd)
        #expect(PDFObjectType.mainXMPPackage.layer == .pd)
    }

    @Test("SE layer objects are classified correctly")
    func seLayerClassification() {
        let seTypes: [PDFObjectType] = [
            .seAnnot, .seArt, .seArtifact, .seAside, .seBibEntry, .seBlockQuote,
            .seCaption, .seCode, .seDiv, .seDocument, .seDocumentFragment, .seEm,
            .seFENote, .seFigure, .seForm, .seFormula, .seGraphicContentItem,
            .seH, .seHn, .seIndex, .seL, .seLBody, .seLI,
            .seMarkedContent, .seMathMLStructElem, .seMathMLStructureElement,
            .seNonStandard, .seNote, .sePart, .seQuote,
            .seRB, .seRP, .seRT, .seRuby, .seSect,
            .seSimpleContentItem, .seSpan, .seStrong, .seSub,
            .seTBody, .seTD, .seTFoot, .seTH, .seTHead,
            .seTOC, .seTOCI, .seTR, .seTable, .seTableCell,
            .seTextItem, .seTitle, .seWP, .seWT, .seWarichu
        ]
        for objectType in seTypes {
            #expect(objectType.layer == .se, "Expected \(objectType) to be in SE layer")
        }
        #expect(seTypes.count == 54)
    }

    @Test("SA layer objects are classified correctly")
    func saLayerClassification() {
        let saTypes: [PDFObjectType] = [
            .saCaption, .saFigure, .saH, .saHn, .saL, .saLBody, .saLI, .saLbl,
            .saLineArtChunk, .saLinkAnnotation, .saListItem, .saP,
            .saRepeatedCharacters, .saSpan, .saStructElem,
            .saTBody, .saTD, .saTFoot, .saTH, .saTHead,
            .saTOC, .saTOCI, .saTR, .saTable, .saTableCell, .saTextChunk
        ]
        for objectType in saTypes {
            #expect(objectType.layer == .sa, "Expected \(objectType) to be in SA layer")
        }
        #expect(saTypes.count == 26)
    }

    @Test("XMP metadata objects are classified correctly")
    func xmpLayerClassification() {
        let xmpTypes: [PDFObjectType] = [
            .xmpPackage, .xmpProperty, .xmpLangAlt,
            .extensionSchemaDefinition, .extensionSchemaField,
            .extensionSchemaObject, .extensionSchemaProperty,
            .extensionSchemaValueType, .extensionSchemasContainer
        ]
        for objectType in xmpTypes {
            #expect(objectType.layer == .xmp, "Expected \(objectType) to be in XMP layer")
        }
        #expect(xmpTypes.count == 9)
    }

    @Test("External objects are classified correctly")
    func externalLayerClassification() {
        let externalTypes: [PDFObjectType] = [
            .iccProfile, .iccInputProfile, .iccOutputProfile,
            .jpeg2000, .trueTypeFontProgram, .pkcsDataObject
        ]
        for objectType in externalTypes {
            #expect(objectType.layer == .external, "Expected \(objectType) to be in External layer")
        }
        #expect(externalTypes.count == 6)
    }

    @Test("Operators are classified correctly")
    func operatorsLayerClassification() {
        #expect(PDFObjectType.opUndefined.layer == .operators)
        #expect(PDFObjectType.opQGsave.layer == .operators)
    }

    @Test("Layer enum has correct number of cases")
    func layerCaseCount() {
        #expect(PDFObjectType.Layer.allCases.count == 7)
    }

    // MARK: - Layer coverage completeness

    @Test("Every case has a layer assignment")
    func everyTypeHasLayer() {
        for objectType in PDFObjectType.allCases {
            // This will not compile if any case is missing from the switch,
            // but we also verify at runtime
            let layer = objectType.layer
            #expect(PDFObjectType.Layer.allCases.contains(layer),
                    "Expected \(objectType) to have a valid layer, got \(layer)")
        }
    }

    // MARK: - Layer case counts add up

    @Test("Layer case counts sum to 188")
    func layerCaseCountsSum() {
        var counts: [PDFObjectType.Layer: Int] = [:]
        for objectType in PDFObjectType.allCases {
            counts[objectType.layer, default: 0] += 1
        }
        let total = counts.values.reduce(0, +)
        #expect(total == 188, "Expected layer counts to sum to 188, got \(total)")
    }
}
