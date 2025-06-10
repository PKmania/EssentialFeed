//
//  Created by CN23 on 06/06/25.
//

import UIKit

extension UIRefreshControl {
  func update(isRefreshing: Bool) {
    isRefreshing ? beginRefreshing() : endRefreshing()
  }
}
