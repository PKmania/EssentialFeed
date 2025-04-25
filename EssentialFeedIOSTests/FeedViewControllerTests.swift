//
//  Created by CN23 on 25/04/25.
//

import XCTest
import UIKit
import EssentialFeed
final class FeedViewController: UIViewController {
  private var loader: FeedLoader?
  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    loader?.load { _ in }
  }
}
final class FeedViewControllerTests: XCTestCase {
  
  func test_init_didNotTestLoadFeed() {
    let laoder = LoaderSpy()
    let _ = FeedViewController(loader: laoder)
    
    XCTAssertEqual(laoder.loadLabelCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let laoder = LoaderSpy()
    let sut = FeedViewController(loader: laoder)
    sut.loadViewIfNeeded()
    XCTAssertEqual(laoder.loadLabelCount, 1)
  }
  
  //MARK: - Helpers
  class LoaderSpy: FeedLoader {
    private(set) var loadLabelCount:Int = 0
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadLabelCount += 1
    }
  }
}

