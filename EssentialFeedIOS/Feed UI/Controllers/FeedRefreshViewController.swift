//
//  Created by CN23 on 08/05/25.
//

import UIKit


public final class FeedRefreshViewController: NSObject {
  public lazy var view: UIRefreshControl = binded(UIRefreshControl())
  
  private let viewModel: FeedViewModel
  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
  }
  @objc func refresh() {
    viewModel.laodFeed()
  }
  
  private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    viewModel.onChange = { [weak self] viewModel in
      if viewModel.isLoading {
        self?.view.beginRefreshing()
      }else {
        self?.view.endRefreshing()
      }
    }
    view.addTarget(self, action: #selector (refresh), for: .valueChanged)
    return view
  }
}
