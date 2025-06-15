import Foundation

struct TrendingNewsEndpoint: EndpointProtocol {
  let baseURL: URL
  let path: String
  let headers: [String : String]?
  let queryItems: [URLQueryItem]?
  
  init(
    secretProvider: any SecretProvider = Bundle.main,
    since: Date? = nil,
    until: Date? = nil,
    limit: Int = 20
  ) throws {
    let host = try secretProvider.secret(for: .financeAPIHost)
    let apiKey = try secretProvider.secret(for: .financeAPIKey)
    guard let baseURL = URL(string: "https://" + host) else {
      throw URLError(.badURL)
    }
    self.baseURL = baseURL
    self.path = "/news/v2/list-trending"
    self.headers = [
      "x-rapidapi-key": apiKey,
      "x-rapidapi-host": host
    ]
    var queryItems = [URLQueryItem(name: "limit", value: String(limit))]
    if let since = since {
      queryItems.append(URLQueryItem(name: "since", value: String(since.timeIntervalSince1970)))
    }
    if let until = until {
      queryItems.append(URLQueryItem(name: "until", value: String(until.timeIntervalSince1970)))
    }
    self.queryItems = queryItems
  }
}
