//
//  Created by CN23 on 10/05/25.
//

import EssentialFeed

public final class FeedViewModel {
  
  private let feedLoader: FeedLoader
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  

  var onChange: ((FeedViewModel) -> Void)?
  var onFeedLoad: (([FeedImage]) -> Void)?

  private(set) var isLoading: Bool = false {
    didSet {
      onChange?(self)
    }
  }
  

  func laodFeed() {
    isLoading = true
    
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoad?(feed)
      }
      self?.isLoading = false
    }
  }
}
