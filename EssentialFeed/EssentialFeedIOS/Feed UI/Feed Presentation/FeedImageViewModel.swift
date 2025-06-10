//
//  Created by CN23 on 10/05/25.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
  let description: String?
  let location: String?
  let image: Image?
  let isLoading: Bool
  let shouldRetry: Bool
  
  var hasLocation: Bool {
    return location != nil
  }
}
