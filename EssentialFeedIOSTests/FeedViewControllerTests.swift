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
    let (_, loader) = makeSUT()
    
    XCTAssertEqual(loader.loadLabelCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadLabelCount, 1)
  }
  
  //MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }
  
  class LoaderSpy: FeedLoader {
    private(set) var loadLabelCount:Int = 0
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadLabelCount += 1
    }
  }
}

