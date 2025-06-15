import Foundation

extension Bundle: SecretProvider {
  public func secret(for key: SecretsKey) throws -> String {
    guard let value = infoDictionary?[key.rawValue] else {
      throw BundleError.missingSecret(key.rawValue)
    }
    guard let secret = value as? String else {
      throw BundleError.wrongSecretType(key.rawValue)
    }
    return secret
  }
  
  enum BundleError: Error {
    case missingSecret(String)
    case wrongSecretType(String)
  }
}
