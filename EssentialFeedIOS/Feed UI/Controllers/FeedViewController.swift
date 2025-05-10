//
//  Created by CN23 on 01/05/25.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  public var refreshController: FeedRefreshViewController?
  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?
  var tableModel = [FeedImageCellController]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  convenience init(refreshController: FeedRefreshViewController) {
    self.init()
    self.refreshController = refreshController
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = self.refreshController?.view
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
    cancelCellControllerLoad(forRowAt: indexPath)
  }
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelCellControllerLoad)
  }
  
  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    return tableModel[indexPath.item]

  }
  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancelLoad()
  }
}
