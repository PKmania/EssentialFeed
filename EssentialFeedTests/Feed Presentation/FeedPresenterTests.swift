//
//  Created by CN23 on 07/06/25.
//

import XCTest
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
  private let errorView: FeedErrorView
  init(errorView: FeedErrorView) {
    self.errorView = errorView
  }
  func didStartLoadingFeed() {
    errorView.display(.noError)
  }
}
class FeedPresenterTests: XCTestCase {
  func test_init_doesNotSendMessagesToView() {
    let (_,viewSpy) = makeSUT()
    
    XCTAssertTrue(viewSpy.messages.isEmpty, "Expected no view messages")
  }
  
  func test_didStartLoadFeed_dispalaysNoerrorMessage() {
    let (sut,viewSpy) = makeSUT()
    
    sut.didStartLoadingFeed()
    
    XCTAssertEqual(viewSpy.messages, [.display(errorMessage: .none)])
  }
  
  //MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let viewSpy = ViewSpy()
    let sut = FeedPresenter(errorView: viewSpy)
    trackForMemoryLeaks(viewSpy, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, viewSpy)
  }
  
  private class ViewSpy: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
      messages.append(.display(errorMessage: viewModel.message))
    }
    
    enum Message: Equatable {
      case display(errorMessage: String?)
    }
    private(set) var messages = [Message]()
    
  }
}

