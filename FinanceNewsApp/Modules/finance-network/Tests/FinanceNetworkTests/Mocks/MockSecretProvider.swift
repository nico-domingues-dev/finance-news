import Foundation
@testable import FinanceNetwork

struct MockSecretProvider: SecretProvider {
  var value: String?
  var error: Error?
  
  func secret(for key: SecretsKey) throws -> String {
    if let error = error {
      throw error
    }
    guard let value = value else {
      throw NSError(domain: "MockSecretProviderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No secret value provided"])
    }
    return value
  }
}
