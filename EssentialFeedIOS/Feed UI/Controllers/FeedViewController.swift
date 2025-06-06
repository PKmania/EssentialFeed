//
//  Created by CN23 on 01/05/25.
//

import UIKit

protocol FeedViewControllerDelegate {
  func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?
  
  @IBOutlet private(set) public var errorView: ErrorView?
  
  var tableModel = [FeedImageCellController]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  var delegate: FeedViewControllerDelegate?
  public override func viewDidLoad() {
    super.viewDidLoad()
    onViewIsAppearing = { vc in
      
      vc.refresh()
      vc.onViewIsAppearing = nil
      vc.setUpTableViewFooter()
    }
    refresh()
    
  }
  
  @IBAction private func refresh() {
    delegate?.didRequestFeedRefresh()
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    onViewIsAppearing?(self)
  }
  private func setUpTableViewFooter() {
    tableView.tableFooterView = .none
  }
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    tableView.sizeTableHeaderToFit()
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view(in: tableView)
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
extension FeedViewController: FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
}

extension FeedViewController: FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel) {
    errorView?.message = viewModel.message
  }
}
