import Foundation

protocol SectionLocation: Location {
  var sectionID: BrightDigitSite.SectionID { get }
}

extension Section: SectionLocation where Site == BrightDigitSite {
  var sectionID: BrightDigitSite.SectionID {
    id
  }
}

extension Item: SectionLocation where Site == BrightDigitSite {}
