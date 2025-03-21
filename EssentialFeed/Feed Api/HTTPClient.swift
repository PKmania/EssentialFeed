//
//  Created by CN23 on 22/01/25.
// Add Comment

import Foundation

public enum HTTPClientResponse {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}
public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
