//
//  Created by CN23 on 07/06/25.
//

import XCTest

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
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView
  init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
    self.loadingView = loadingView
    self.errorView = errorView
  }
  func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(.init(isLoading: true))
  }
}
class FeedPresenterTests: XCTestCase {
  func test_init_doesNotSendMessagesToView() {
    let (_,viewSpy) = makeSUT()
    
    XCTAssertTrue(viewSpy.messages.isEmpty, "Expected no view messages")
  }
  
  func test_didStartLoadFeed_dispalaysNoerrorMessageAndStartLoading() {
    let (sut,viewSpy) = makeSUT()
    
    sut.didStartLoadingFeed()
    
    XCTAssertEqual(viewSpy.messages, [
                                      .display(errorMessage: .none),
                                      .display(isLoading: true)
                                      ])
  }
  
  //MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(loadingView: view, errorView: view)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }
  
  private class ViewSpy: FeedLoadingView,FeedErrorView {
    enum Message: Hashable {
      case display(errorMessage: String?)
      case display(isLoading: Bool)
    }
    private(set) var messages = Set<Message>()
    
    func display(_ viewModel: FeedLoadingViewModel) {
      messages.insert(.display(isLoading: viewModel.isLoading))
    }
    
    func display(_ viewModel: FeedErrorViewModel) {
      messages.insert(.display(errorMessage: viewModel.message))
    }
  }
}

