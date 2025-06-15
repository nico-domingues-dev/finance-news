import Foundation

final class MockURLProtocol: URLProtocol {
  
  enum Stub {
    case success(data: Data, response: URLResponse)
    case failure(Error)
  }
  
  static let queue = DispatchQueue(label: "MockURLProtocolQueue")
  
  nonisolated(unsafe)
  private static var _stub: Stub?
  
  static var stub: Stub? {
    get { queue.sync { _stub } }
    set { queue.sync { _stub = newValue } }
  }
  
  static func stubSuccess(data: Data, response: URLResponse) {
    _stub = .success(data: data, response: response)
  }
  
  static func stubFailure(error: Error) {
    _stub = .failure(error)
  }
  
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    switch MockURLProtocol.stub {
      case .success(let data, let response):
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
    case .failure(let error):
      client?.urlProtocol(self, didFailWithError: error)
    case .none:
      client?.urlProtocol(self, didFailWithError: NSError(domain: "Stub not found", code: 0))
    }
    client?.urlProtocolDidFinishLoading(self)
  }
  
  override func stopLoading() {}
}
