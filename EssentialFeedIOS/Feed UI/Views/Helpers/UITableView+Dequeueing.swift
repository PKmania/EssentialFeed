//
//  Created by CN23 on 13/05/25.
//

import UIKit

extension UITableView {
  func dequeReuseableCell<T: UITableViewCell>() -> T {
    return dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
  }
}
