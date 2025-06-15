import XCTest
import Combine
import Foundation
@testable import FinanceNetwork

final class NetworkSessionTests: XCTestCase {
  var cancellables: Set<AnyCancellable> = []
  var sut: NetworkSession!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    sut = NetworkSession(session: session)
  }
  
  override func tearDownWithError() throws {
    sut = .none
    MockURLProtocol.stub = nil
    try super.tearDownWithError()
  }
  
  func testDataPublisherFailsForNonHTTPURLResponse() {
    let expectedError = URLError(.badServerResponse) as NSError
    let data = Data.anyData
    let request = URLRequest.anyURLRequest
    let response = URLResponse.anyURLResponse
    
    MockURLProtocol.stubSuccess(data: data, response: response)
    
    let expectation = self.expectation(description: "NetworkSession returns data")
    
    sut.dataPublisher(for: request)
      .sink(receiveCompletion: { completion in
        guard case .failure(let error as NSError) = completion else {
          XCTFail("Expected \(expectedError), got \(completion)")
          return
        }
        XCTAssertEqual(error.code, expectedError.code)
        expectation.fulfill()
      }, receiveValue: { result in
        XCTFail("Expected \(expectedError), got \(result)")
      })
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testDataPublisherSuccess() {
    let expectedData = Data.anyData
    let request = URLRequest.anyURLRequest
    let response = URLResponse.anyHTTPURLResponse(statusCode: 200)
    
    MockURLProtocol.stubSuccess(data: expectedData, response: response)
    
    let expectation = self.expectation(description: "NetworkSession returns data")
    
    sut.dataPublisher(for: request)
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          XCTFail("Expected \(expectedData), got \(error)")
        }
      }, receiveValue: { result in
        XCTAssertEqual(result.data, expectedData)
        XCTAssertEqual(result.response.statusCode, response.statusCode)
        expectation.fulfill()
      })
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testDataPublisherFailure() {
    
    let url = URL(string: "https://example.com")!
    let request = URLRequest(url: url)
    let error = URLError(.timedOut)
    
    MockURLProtocol.stubFailure(error: error)
    
    let expectation = self.expectation(description: "NetworkSession returns error")
    
    sut.dataPublisher(for: request)
      .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
          XCTAssertEqual((err as? URLError)?.code, .timedOut)
          expectation.fulfill()
        }
      }, receiveValue: { _ in
        XCTFail("Expected failure, got value")
      })
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1)
  }
}
