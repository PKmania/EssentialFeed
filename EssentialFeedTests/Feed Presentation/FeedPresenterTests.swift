//
//  Created by CN23 on 07/06/25.
//

import XCTest
final class FeedPresenter {
  init(view: Any) {
    
  }
}
class FeedPresenterTests: XCTestCase {
  func test_init_doesNotSendMessagesToView() {
    let (_,viewSpy) = makeSUT()
    
    XCTAssertTrue(viewSpy.messages.isEmpty, "Expected no view messages")
  }
  
  
  //MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let viewSpy = ViewSpy()
    let sut = FeedPresenter(view: viewSpy)
    trackForMemoryLeaks(viewSpy, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, viewSpy)
  }
  
  private class ViewSpy {
    let messages = [Any]()
  }
}

