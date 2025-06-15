import Foundation
import XCTest
@testable import FinanceNetwork

final class TrendingNewsTests: XCTestCase {
  
  func testTrendingNewsDecodes() throws {
    let url = try XCTUnwrap(Bundle.module.url(forResource: "TrendingNews", withExtension: "json"))
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    XCTAssertNoThrow(try decoder.decode(TrendingNew.self, from: data))
  }
}
