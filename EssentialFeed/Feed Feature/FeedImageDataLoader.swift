//
//  Created by CN23 on 08/05/25.
//

import Foundation

public protocol FeedImageDataLoaderTask  {
  func cancel()
}

public protocol FeedImageDataLoader  {
  typealias Result = Swift.Result<Data, Error>
  
  func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
