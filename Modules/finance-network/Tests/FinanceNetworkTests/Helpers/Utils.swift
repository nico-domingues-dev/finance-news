import Foundation

extension URL {
  static let anyURL = URL(string: "https://any-url.com")!
}

extension URLRequest {
  static let anyURLRequest = URLRequest(url: .anyURL)
}

extension Data {
  static let anyData = Data("any data".utf8)
}

extension URLResponse {
  static let anyURLResponse = URLResponse(
    url: .anyURL,
    mimeType: .none,
    expectedContentLength: 0,
    textEncodingName: .none
  )
  
  static func anyHTTPURLResponse(statusCode: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(
      url: .anyURL,
      statusCode: statusCode,
      httpVersion: .none,
      headerFields: .none
    )!
  }
}
