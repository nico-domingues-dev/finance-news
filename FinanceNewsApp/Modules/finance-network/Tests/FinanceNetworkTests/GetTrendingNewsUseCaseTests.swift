import XCTest
@testable import FinanceNetwork
import Combine

final class GetTrendingNewsUseCaseTests: XCTestCase {
  var sut: GetTrendingNewsUseCase!
  var mockSession: NetworkSession!
  var mockSecretProvider: BundleMock!
  
  private(set) var cancellables = Set<AnyCancellable>()
  
  override func setUp() {
    super.setUp()
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    mockSession = NetworkSession(session:  URLSession(configuration: config))
    mockSecretProvider = BundleMock()
    sut = GetTrendingNewsUseCase(
      networkSession: mockSession,
      secretProvider: mockSecretProvider
    )
  }
  
  override func tearDown() {
    sut = nil
    mockSession = nil
    mockSecretProvider = nil
    MockURLProtocol.stub = nil
    super.tearDown()
  }
  
  func testGetTrendingNewsSuccess() throws {
    let url = try XCTUnwrap(Bundle.module.url(forResource: "TrendingNewsList", withExtension: "json"))
    let data = try Data(contentsOf: url)
    let response: URLResponse = .anyHTTPURLResponse()
    MockURLProtocol.stubSuccess(data: data, response: response)
    mockSecretProvider.stubbedDictionary = [
      SecretsKey.financeAPIHost.rawValue: "mock.host",
      SecretsKey.financeAPIKey.rawValue: "mock.key"
    ]
    let expectation = self.expectation(description: "GetTrendingNewsUseCase returns trending news")
    sut.getTrendingNews(since: nil, until: nil, limit: 20)
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          XCTFail("Expected success, got \(error)")
        }
      }, receiveValue: { trendingNews in
        XCTAssertEqual(trendingNews.count, 1)
        XCTAssertEqual(trendingNews.first?.id, "000001")
        XCTAssertEqual(trendingNews.first?.title, "Mock Title")
        expectation.fulfill()
      })
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testGetTrendingNewsFailsForInvalidRequest() throws {
    let expectedError = URLError(.badURL) as NSError
    let url = try XCTUnwrap(Bundle.module.url(forResource: "TrendingNewsList", withExtension: "json"))
    let data = try Data(contentsOf: url)
    let response: URLResponse = .anyHTTPURLResponse()
    MockURLProtocol.stubSuccess(data: data, response: response)
    mockSecretProvider.stubbedDictionary = [
      SecretsKey.financeAPIHost.rawValue: ":::",
      SecretsKey.financeAPIKey.rawValue: "mock.key"
    ]
    let expectation = self.expectation(description: "GetTrendingNewsUseCase returns trending news")
    sut.getTrendingNews(since: nil, until: nil, limit: 20)
      .sink(receiveCompletion: { completion in
        if case .failure(let error as NSError) = completion {
          XCTAssertEqual(error, expectedError)
          expectation.fulfill()
        }
      }, receiveValue: { trendingNews in
        XCTFail("Expected failure, got \(trendingNews)")
      })
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testGetTrendingNewsFailsForNon200StatusCode() throws {
    let expectedError = URLError(.badServerResponse) as NSError
    let url = try XCTUnwrap(Bundle.module.url(forResource: "TrendingNewsList", withExtension: "json"))
    let data = try Data(contentsOf: url)
    let response: URLResponse = .anyHTTPURLResponse(statusCode: 201)
    MockURLProtocol.stubSuccess(data: data, response: response)
    mockSecretProvider.stubbedDictionary = [
      SecretsKey.financeAPIHost.rawValue: "mock.host",
      SecretsKey.financeAPIKey.rawValue: "mock.key"
    ]
    let expectation = self.expectation(description: "GetTrendingNewsUseCase returns trending news")
    sut.getTrendingNews(since: nil, until: nil, limit: 20)
      .sink(receiveCompletion: { completion in
        if case .failure(let error as NSError) = completion {
          XCTAssertEqual(error, expectedError)
          expectation.fulfill()
        }
      }, receiveValue: { trendingNews in
        XCTFail("Expected failure, got \(trendingNews)")
      })
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1)
  }
}

