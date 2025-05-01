//
//  Created by CN23 on 25/04/25.
//

import XCTest
import UIKit
import EssentialFeed
final class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  private var onViewIsAppearing: ((FeedViewController) -> Void)?
  
  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    onViewIsAppearing = { vc in
      vc.refresh()
      vc.refreshControl?.addTarget(vc, action: #selector(vc.refresh), for: .valueChanged)
      vc.onViewIsAppearing = nil
    }
    load()
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    onViewIsAppearing?(self)
  }
  
  @objc private func load() {
    loader?.load { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    }
  }
  
  @objc private func refresh() {
    refreshControl?.beginRefreshing()
  }
  
}


final class FeedViewControllerTests: XCTestCase {
  
  func test_loadFeedActions_requestFeedFromFeedLoader() {
    let (sut, loader) = makeSUT()
    
    XCTAssertEqual(loader.loadLabelCount, 0)
    
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadLabelCount, 1)
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadLabelCount, 2)
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadLabelCount, 3)
  }

  
  func test_viewDidLoad_showLoadingIndicator() {
    let (sut, loader) = makeSUT()
    
    sut.replaceRefreshControlWithFakeForIOS17Support()
    
    XCTAssertTrue(sut.isShowingLoadingIndicator)
    
    loader.completeFeedLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator)
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator)
    
    loader.completeFeedLoading(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator)
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
    private var completions = [(FeedLoader.Result) -> Void]()
    var loadLabelCount: Int {
      completions.count
    }
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completions.append(completion)
    }
    func completeFeedLoading(at index: Int) {
      completions[index](.success([]))
    }
    
  }
}

private class FakeRefrehControl: UIRefreshControl {
  private var _isRefreshing: Bool = false
  override var isRefreshing: Bool { _isRefreshing }
  override func beginRefreshing() {
    _isRefreshing = true
  }
  override func endRefreshing() {
    _isRefreshing = false
  }
}


private extension FeedViewController {
  
  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }
  
  func replaceRefreshControlWithFakeForIOS17Support() {
    let fake = FakeRefrehControl()
    refreshControl?.allTargets.forEach({ target in
      refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
        fake.addTarget(target, action: Selector(action), for: .valueChanged)
      })
    })
    refreshControl = fake
    self.beginAppearanceTransition(true, animated: false)
    self.endAppearanceTransition()
  }
  
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach({ target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    })
  }
}
