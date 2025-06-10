//
//  Created by CN23 on 08/05/25.
//

import UIKit
import EssentialFeedIOS

extension FeedImageCell {
  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }
  
  var locationText: String? {
    return locationLabel.text
  }
  var descriptionText: String? {
    return descriptionLabel.text
  }
  var isShowingImageLoadingIndicator: Bool {
    return feedImageContainer.isShimmering
  }
  var renderedImage: Data? {
    return feedImageView.image?.pngData()
  }
  var isShowingRetryAction: Bool {
    return !feedImageRetryButton.isHidden
  }
  func simulateRetryAction() {
    feedImageRetryButton.simulateTap()
  }
}
