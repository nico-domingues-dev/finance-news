import Foundation
@testable import FinanceNetwork

final class BundleMock: Bundle, @unchecked Sendable {
  var stubbedDictionary: [String: Any] = [:]
  
  override var infoDictionary: [String : Any]? {
    stubbedDictionary
  }
}
