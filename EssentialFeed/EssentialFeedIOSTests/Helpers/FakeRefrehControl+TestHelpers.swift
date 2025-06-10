//
//  Created by CN23 on 08/05/25.
//

import UIKit

class FakeRefreshControl: UIRefreshControl {
  private var _isRefreshing: Bool = false
  override var isRefreshing: Bool { _isRefreshing }
  override func beginRefreshing() {
    _isRefreshing = true
  }
  override func endRefreshing() {
    _isRefreshing = false
  }
}
