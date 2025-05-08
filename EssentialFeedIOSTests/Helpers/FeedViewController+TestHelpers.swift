//
//  Created by CN23 on 08/05/25.
//

import UIKit
import EssentialFeedIOS

extension FeedViewController {
  
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
  func simulateFeedImageViewNearVisible(at row: Int) {
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView(tableView, prefetchRowsAt: [index])
  }
  func simulateFeedImageViewNotNearVisible(at row: Int) {
    simulateFeedImageViewNearVisible(at: row)
    
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
  }
  
  @discardableResult
  func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
    return feedImageView(at: index) as? FeedImageCell
  }
  
  func simulateFeedImageViewNotVisible(at row: Int) {
    let view = simulateFeedImageViewVisible(at: row)
    
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
  }
  func numberOfRenderedFeedImageViews() -> Int {
    return tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  private var feedImagesSection: Int {
    return 0
  }
  
}



