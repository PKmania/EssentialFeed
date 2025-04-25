//
//  Created by CN23 on 25/04/25.
//

import XCTest
final class FeedViewController {
  init(loader: FeedViewControllerTests.LoaderSpy) {
    print(loader.loadLabelCount)

  }
}
final class FeedViewControllerTests: XCTestCase {
  
  func test_init_didNotTestLoadFeed() {
    let laoder = LoaderSpy()
    let _ = FeedViewController(loader: laoder)
    
    XCTAssertEqual(laoder.loadLabelCount, 0)
  }
  
  //MARK: - Helpers
  class LoaderSpy {
    private(set) var loadLabelCount:Int = 0
  }
}

