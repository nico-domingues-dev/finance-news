import Foundation

public protocol SecretProvider {
  func secret(for key: SecretsKey) throws -> String
}
