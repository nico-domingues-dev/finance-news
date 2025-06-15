import Foundation
import XCTest
@testable import FinanceNetwork

final class SecretProviderTests: XCTestCase {
  var sut: BundleMock!
  
  override func setUp() {
    super.setUp()
    sut = BundleMock()
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  
  func testSecretsSuceeds() throws {
    let expectedHost = "mock.host"
    let expectedKey = "mock.key"
    
    sut.stubbedDictionary = [
      SecretsKey.financeAPIHost.rawValue: expectedHost,
      SecretsKey.financeAPIKey.rawValue: expectedKey
    ]
    let host = try sut.secret(for: .financeAPIHost)
    let key = try sut.secret(for: .financeAPIKey)
    XCTAssertEqual(host, expectedHost)
    XCTAssertEqual(key, expectedKey)
  }
  
  func testThrowsMissingSecretError() throws {
    let secrets: [SecretsKey] = [.financeAPIHost, .financeAPIKey]
    try secrets.forEach { secret in
      XCTAssertThrowsError(try sut.secret(for: secret)) { error in
        XCTAssertEqual(error as NSError, Bundle.BundleError.missingSecret(secret.rawValue) as NSError)
      }
    }
  }
  
  func testThrowsWrongSecretTypeError() throws {
    sut.stubbedDictionary = [
      SecretsKey.financeAPIHost.rawValue: 1,
      SecretsKey.financeAPIKey.rawValue: 2
    ]
    
    let secrets: [SecretsKey] = [.financeAPIHost, .financeAPIKey]
    try secrets.forEach { secret in
      XCTAssertThrowsError(try sut.secret(for: secret)) { error in
        XCTAssertEqual(error as NSError, Bundle.BundleError.wrongSecretType(secret.rawValue) as NSError)
      }
    }
  }
}
