
import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let (_,client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_load_requestsDataFromURL() {
    let url = URL(string: "hhtp://abc-given.com")!
    let (sut,client) = makeSUT(url: url)
    sut.load { _ in }
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "hhtp://abc-given.com")!
    let (sut,client) = makeSUT(url: url)
    sut.load { _ in }
    sut.load { _ in }
    XCTAssertEqual(client.requestedURLs, [url,url])
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut,client) = makeSUT()
    expect(sut, toCompleteWith: failure(.connectivity)) {
      let clientError = NSError(domain: "test", code: 0)
      client.complete(with: clientError)
    }
  }
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut,client) = makeSUT()
    let samples = [199,201,300,400,500]
    samples.enumerated().forEach { (index, code) in
      expect(sut, toCompleteWith: failure(.invalidData)) {
        let json = makeItemJSON([])
        client.complete(withStatusCode: code, data: json, at: index)
      }
    }
  }
  
  func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut,client) = makeSUT()
    expect(sut, toCompleteWith: failure(.invalidData)) {
      let invalidJSON = Data("Invalidjson".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut,client) = makeSUT()
    expect(sut, toCompleteWith: .success([])) {
      let emptyJSONList = makeItemJSON([])
      client.complete(withStatusCode: 200, data: emptyJSONList)
    }
  }
  
  func test_load_deliversItemsOn200HTTPResponsewithJSONList() {
    let item1 = makeItem(
      id: UUID(),
      imageURL: URL(string: "https://a-given.com")!)
    //----
    let item2 = makeItem(
      id: UUID(),
      description: "a description",
      location: "a location",
      imageURL: URL(string: "https://another-given.com")!)
    //----
    let (sut,client) = makeSUT()
    expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
      let json = makeItemJSON([item1.json, item2.json])
      client.complete(withStatusCode: 200, data: json)
    }
  }
  
  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let url = URL(string: "hhtps://abc-given.com")!
    let client = HTTPClientSpy()
    var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
    var capturedResults = [RemoteFeedLoader.Result]()
    sut?.load { error in
      capturedResults.append(error)
    }
    sut = nil
    client.complete(withStatusCode: 200, data: makeItemJSON([]))
    XCTAssertTrue(capturedResults.isEmpty)
  }
  
  //MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "hhtp://abc.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(client: client, url: url)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(client)
    return (sut,client)
  }
  
  private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
    return .failure(error)
  }
  private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem,json: [String: Any]) {
    let item = FeedItem(
      id: id,
      description: description,
      location: location,
      imageURL: imageURL)
    let json = [
      "id": item.id.uuidString,
      "description": item.description,
      "location": item.location,
      "image": item.imageURL.absoluteString
    ].reduce(into: [String: Any]()) { (acc, e) in
      if let value = e.value { acc[e.key] = value }
    }
    return (item,json)
  }
  private func makeItemJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
  }
  private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "wait for laod completion")
    sut.load { receivedResult in
      switch (receivedResult,expectedResult) {
      case let (.success(receivedItem), .success(expectedItem)):
        XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)
      case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      default:
        XCTFail("Expected Result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    action()
    wait(for: [exp], timeout: 1.0)
    
  }
  private class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClientResponse) -> Void)]()
    var requestedURLs: [URL] {
      return messages.map {$0.url}
    }
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
      messages.append((url,completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success(data,response))
    }
  }
}
