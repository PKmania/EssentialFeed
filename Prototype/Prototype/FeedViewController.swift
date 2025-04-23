//
//  Created by CN23 on 23/04/25.
//

import UIKit

final class FeedViewController: UITableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
  }
}
