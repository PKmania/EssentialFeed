//
//  Created by CN23 on 07/06/25.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
  
  func test_title_isLocalized() {
    XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
  }
  func test_init_doesNotSendMessagesToView() {
    let (_,viewSpy) = makeSUT()
    
    XCTAssertTrue(viewSpy.messages.isEmpty, "Expected no view messages")
  }
  
  func test_didStartLoadFeed_displaysNoerrorMessageAndStartLoading() {
    let (sut,viewSpy) = makeSUT()
    
    sut.didStartLoadingFeed()
    
    XCTAssertEqual(viewSpy.messages, [
      .display(errorMessage: .none),
      .display(isLoading: true)
    ])
  }
  
  func test_didFinishLoadingFeed_displayFeedAndStopLoading() {
    let (sut,viewSpy) = makeSUT()
    let feed = uniqueImageFeed().models
    sut.didFinishLoadingFeed(with: feed)
    
    XCTAssertEqual(viewSpy.messages, [
      .display(feed: feed),
      .display(isLoading: false)
    ])
  }
  
  func test_didFinishLoadingFeedWithError_displayLocalizedErrorMessageAndStopLoading() {
    let (sut,viewSpy) = makeSUT()
    sut.didFinishLoadingFeed(with: anyNSError())
    
    XCTAssertEqual(viewSpy.messages, [
      .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
      .display(isLoading: false)
    ])
  }
  
  //MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }
  
  private   func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
    }
    return value
  }
  
  private class ViewSpy: FeedView ,FeedLoadingView,FeedErrorView {
    private(set) var messages = Set<Message>()
    
    enum Message: Hashable {
      case display(errorMessage: String?)
      case display(isLoading: Bool)
      case display(feed: [FeedImage])
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
      messages.insert(.display(isLoading: viewModel.isLoading))
    }
    
    func display(_ viewModel: FeedErrorViewModel) {
      messages.insert(.display(errorMessage: viewModel.message))
    }
    
    func display(_ viewModel: FeedViewModel) {
      messages.insert(.display(feed: viewModel.feed))
    }
  }
}

