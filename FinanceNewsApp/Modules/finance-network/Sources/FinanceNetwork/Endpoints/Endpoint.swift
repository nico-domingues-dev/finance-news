import Foundation

public enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
  case patch = "PATCH"
}

public protocol EndpointProtocol {
  var baseURL: URL { get }
  var path: String { get }
  var method: HTTPMethod { get } // e.g., "GET", "POST"
  var headers: [String: String]? { get }
  var queryItems: [URLQueryItem]? { get }
  var body: Data? { get }
}

public extension EndpointProtocol {
  var body: Data? { .none }
  var method: HTTPMethod { .get }
  
  func makeRequest() -> URLRequest {
    var url = baseURL.appendingPathComponent(path)
    if let queryItems = queryItems, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
      components.queryItems = queryItems
      url = components.url ?? url
    }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    request.httpBody = body
    return request
  }
}
