import Combine
import Foundation

public final class NetworkSession: NetworkSessionProtocol {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    
    self.session = session
  }
  
  public func dataPublisher(for request: URLRequest) -> AnyPublisher<Response, Error> {
    session.dataTaskPublisher(for: request)
      .tryMap { output in
        guard let httpResponse = output.response as? HTTPURLResponse else {
          throw URLError(.badServerResponse)
        }
        return (data: output.data, response: httpResponse)
      }
      .mapError { $0 as Error }
      .eraseToAnyPublisher()
  }
}
