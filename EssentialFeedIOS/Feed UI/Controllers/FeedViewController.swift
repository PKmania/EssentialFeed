//
//  Created by CN23 on 01/05/25.
//

import EssentialFeed
import UIKit


public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  public var refreshController: FeedRefreshViewController?
  private var imageLoader: FeedImageDataLoader?
  private var cellControllers = [IndexPath: FeedImageCellController]()
  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?
  private var tableModel = [FeedImage]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    self.init()
    self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    self.imageLoader = imageLoader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = self.refreshController?.view
    refreshController?.onRefresh = { [weak self] feed in
      self?.tableModel = feed
    }
    tableView.prefetchDataSource = self
    refreshController?.refresh()
  }
  
  @objc private func refresh() {
    refreshControl?.beginRefreshing()
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view()
  }
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    removeCellController(forRowAt: indexPath)
  }
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(removeCellController)
  }
  
  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    let cellModel = tableModel[indexPath.item]
    let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
    cellControllers[indexPath] = cellController
    return  cellController
  }
  private func removeCellController(forRowAt indexPath: IndexPath) {
    cellControllers[indexPath] = nil
    }
}
