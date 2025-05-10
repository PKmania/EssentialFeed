//
//  Created by CN23 on 10/05/25.
//

import EssentialFeed

public final class FeedViewModel {
  typealias Observer<T> = (T) -> Void
  private let feedLoader: FeedLoader
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  

  var onLoadinfStateChange: Observer<Bool>?
  var onFeedLoad: Observer<[FeedImage]>?
  

  func loadFeed() {
    self.onLoadinfStateChange?(true)
    
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoad?(feed)
      }
      self?.onLoadinfStateChange?(false)
    }
  }
}
