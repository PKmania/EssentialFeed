//
//  Created by CN23 on 08/05/25.
//

import UIKit
import EssentialFeedIOS

extension FeedViewController {
  
  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }
  
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      prepareForFirstAppearance()
    }
    
    beginAppearanceTransition(true, animated: false)
    endAppearanceTransition()
  }
  
  private func prepareForFirstAppearance() {
    setSmallFrameToPreventRenderingCells()
    replaceRefreshControlWithFakeForiOS17Support()
  }
  
  private func setSmallFrameToPreventRenderingCells() {
    tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
  }
  func replaceRefreshControlWithFakeForiOS17Support() {
       let fake = FakeUIRefreshControl()
       
       refreshControl?.allTargets.forEach { target in
           refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
               fake.addTarget(target, action: Selector(action), for: .valueChanged)
           }
       }

       refreshControl = fake
   }
  private class FakeUIRefreshControl: UIRefreshControl {
      private var _isRefreshing = false
      
      override var isRefreshing: Bool { _isRefreshing }
      
      override func beginRefreshing() {
        _isRefreshing = true
      }
      
      override func endRefreshing() {
        _isRefreshing = false
      }
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
  
  @discardableResult
  func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell?{
    let view = simulateFeedImageViewVisible(at: row)
    
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    return view
  }
  func numberOfRenderedFeedImageViews() -> Int {
    return tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  var errorMessage: String? {
    return errorView?.message
  }
  
  private var feedImagesSection: Int {
    return 0
  }
  
}



