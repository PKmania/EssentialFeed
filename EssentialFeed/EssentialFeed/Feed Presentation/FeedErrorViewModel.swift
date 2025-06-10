//
//  Created by CN23 on 07/06/25.
//

import Foundation

public struct FeedErrorViewModel {
  public let message: String?
  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: nil)
  }
  
  static func error(message: String) -> FeedErrorViewModel {
    return FeedErrorViewModel(message: message)
  }
}
