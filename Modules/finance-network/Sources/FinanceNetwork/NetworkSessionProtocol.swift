import Combine
import Foundation

public protocol NetworkSessionProtocol {
  typealias Response = (data: Data, response: HTTPURLResponse)
  func dataPublisher(for request: URLRequest) -> AnyPublisher<Response, Error>
}
