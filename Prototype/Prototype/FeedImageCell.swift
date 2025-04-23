//
//  FeedImageCell.swift
//  Prototype
//
//  Created by CN23 on 23/04/25.
//

import UIKit

final class FeedImageCell: UITableViewCell {

  @IBOutlet weak var locationContainer: UIStackView!
  
  @IBOutlet weak var feedImageView: UIImageView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    feedImageView.alpha = 0

  }
  override func prepareForReuse() {
    super.prepareForReuse()
    feedImageView.alpha = 0
  }
  func fadeIn(_ image: UIImage?) {
    feedImageView.image = image
    UIView.animate(withDuration: 0.3, delay: 0.3) {
      self.feedImageView.alpha = 1
    }
  }
}
