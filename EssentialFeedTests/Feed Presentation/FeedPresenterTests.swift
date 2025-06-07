//
//  Created by CN23 on 07/06/25.
//

import XCTest
import EssentialFeed

struct FeedViewModel {
  let feed: [FeedImage]
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}
struct FeedLoadingViewModel {
  let isLoading: Bool
}
protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}
struct FeedErrorViewModel {
  let message: String?
  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: nil)
  }
}
protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}
final class FeedPresenter {
  private let feedView: FeedView
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView
  init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
    self.feedView = feedView
    self.loadingView = loadingView
    self.errorView = errorView
  }
  func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(.init(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(.init(isLoading: false))
  }
}
class FeedPresenterTests: XCTestCase {
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
  
  //MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
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

