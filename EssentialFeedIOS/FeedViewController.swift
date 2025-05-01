//
//  Created by CN23 on 01/05/25.
//

import EssentialFeed
import UIKit

public protocol FeedImageDataLoader  {
  func loadImageData(from url: URL)
}
final public class FeedViewController: UITableViewController {
  private var feedLoader: FeedLoader?
  private var imageLoader: FeedImageDataLoader?

  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?
  private var tableModel = [FeedImage]()
  
  public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    self.init()
    self.feedLoader = feedLoader
    self.imageLoader = imageLoader
  }
  
  public override func viewDidLoad() {
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
    feedLoader?.load { [weak self] result in
      if let feed = try? result.get() {
        self?.tableModel = feed
        self?.tableView.reloadData()
      }
      self?.refreshControl?.endRefreshing()
    }
  }
  
  @objc private func refresh() {
    refreshControl?.beginRefreshing()
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = tableModel[indexPath.row]
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = (model.location == nil)
    cell.locationLabel.text = model.location
    cell.descriptionLabel.text = model.description
    imageLoader?.loadImageData(from: model.url)
    return cell
  }
}
