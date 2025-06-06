//
//  Created by CN23 on 13/05/25.
//

import UIKit

extension UITableView {
  func dequeReuseableCell<T: UITableViewCell>() -> T {
    return dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
  }
}

extension UITableView {
  func sizeTableHeaderToFit() {
    guard let header = tableHeaderView else { return }

    let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

    let needsFrameUpdate = header.frame.height != size.height
    if needsFrameUpdate {
      header.frame.size.height = size.height
      tableHeaderView = header
    }
  }
}
