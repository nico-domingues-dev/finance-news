import Combine
import Foundation

public protocol GetTrendingNewsProvider {
  func getTrendingNews(_ since: Date?, until: Date?, limit: Int) -> AnyPublisher<[TrendingNew], Error>
}

public final class GetTrendingNewsUseCase: GetTrendingNewsProvider {
  private let networkSession: any NetworkSessionProtocol
  private let secretProvider: any SecretProvider
  private let decoder: JSONDecoder
  
  public init(
    networkSession: any NetworkSessionProtocol = NetworkSession(),
    secretProvider: any SecretProvider = Bundle.main,
    decoder: JSONDecoder = JSONDecoder()
  ) {
    self.networkSession = networkSession
    self.secretProvider = secretProvider
    self.decoder = decoder
  }
  
  public func getTrendingNews(_ since: Date?, until: Date?, limit: Int) -> AnyPublisher<[TrendingNew], any Error> {
    do {
      let request = try TrendingNewsEndpoint(secretProvider: secretProvider, since: since, until: until, limit: limit).makeRequest()
      return networkSession.dataPublisher(for: request)
        .tryMap {
          guard $0.response.statusCode == 200 else {
            throw URLError(.badServerResponse)
          }
          return $0.data
        }
        .decode(type: APIResponse<[TrendingNew]>.self, decoder: decoder)
        .map(\.data)
        .eraseToAnyPublisher()
    } catch {
      return Fail(error: error)
        .eraseToAnyPublisher()
    }
  }
}

