import XCTest
import Foundation
@testable import FinanceNetwork

final class TrendingNewsEndpointTests: XCTestCase {
  
  func testInit_DefaultValues() throws {
    let mockSecretProvider = BundleMock()
    mockSecretProvider.stubbedDictionary = [
      SecretsKey.financeAPIHost.rawValue: "mockhost.com",
      SecretsKey.financeAPIKey.rawValue: "mockapikey"
    ]
    let endpoint = try TrendingNewsEndpoint(secretProvider: mockSecretProvider)
    XCTAssertEqual(endpoint.baseURL.absoluteString, "https://mockhost.com")
    XCTAssertEqual(endpoint.path, "/news/v2/list-trending")
    XCTAssertEqual(endpoint.headers?["x-rapidapi-key"], "mockapikey")
    XCTAssertEqual(endpoint.headers?["x-rapidapi-host"], "mockhost.com")
    XCTAssertTrue(endpoint.queryItems?.contains(where: { $0.name == "limit" && $0.value == "20" }) ?? false)
  }
  
  func testInit_WithSinceAndUntil() throws {
    let since = Date(timeIntervalSince1970: 1000)
    let until = Date(timeIntervalSince1970: 2000)
    var mockSecretProvider = MockSecretProvider()
    mockSecretProvider.value = "someSecretValue"
    let endpoint = try TrendingNewsEndpoint(
      secretProvider: mockSecretProvider,
      since: since,
      until: until,
      limit: 10
    )
    XCTAssertTrue(endpoint.queryItems?.contains(where: { $0.name == "since" && $0.value == "1000.0" }) ?? false)
    XCTAssertTrue(endpoint.queryItems?.contains(where: { $0.name == "until" && $0.value == "2000.0" }) ?? false)
    XCTAssertTrue(endpoint.queryItems?.contains(where: { $0.name == "limit" && $0.value == "10" }) ?? false)
  }
  
  func testInit_InvalidHostThrows() {
    do {
      var mockSecretProvider = MockSecretProvider()
      mockSecretProvider.value = ":::"
      _ = try TrendingNewsEndpoint(secretProvider: mockSecretProvider)
    } catch URLError.badURL {
      XCTAssertTrue(true)
    } catch {
      XCTFail("Expected URLError.badURL, but got \(error)")
    }
  }
  
  func testMakeURLRequest() throws {
    let mockSecretProvider = BundleMock()
    mockSecretProvider.stubbedDictionary = [
      SecretsKey.financeAPIHost.rawValue: "mockhost.com",
      SecretsKey.financeAPIKey.rawValue: "mockapikey"
    ]
    
    let since = Date(timeIntervalSince1970: 1000)
    let until = Date(timeIntervalSince1970: 2000)
    let endpoint = try TrendingNewsEndpoint(
      secretProvider: mockSecretProvider,
      since: since,
      until: until,
      limit: 10
    )
    
    let request = endpoint.makeRequest()
    XCTAssertEqual(request.httpBody, endpoint.body)
    XCTAssertEqual(request.allHTTPHeaderFields, endpoint.headers)
    XCTAssertEqual(request.httpMethod, endpoint.method.rawValue)
    let url = try XCTUnwrap(request.url)
    let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
    XCTAssertEqual(urlComponents?.scheme, "https")
    XCTAssertEqual(urlComponents?.host, "mockhost.com")
    XCTAssertEqual(urlComponents?.path, "/news/v2/list-trending")
    XCTAssertEqual(urlComponents?.queryItems?.count, 3)
    XCTAssertTrue(urlComponents?.queryItems?.contains(where: { $0.name == "since" && $0.value == "1000.0" }) ?? false)
    XCTAssertTrue(urlComponents?.queryItems?.contains(where: { $0.name == "until" && $0.value == "2000.0" }) ?? false)
    XCTAssertTrue(urlComponents?.queryItems?.contains(where: { $0.name == "limit" && $0.value == "10" }) ?? false)
  }
}
