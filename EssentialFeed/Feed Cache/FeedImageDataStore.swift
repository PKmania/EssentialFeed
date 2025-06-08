//
//  Created by CN23 on 08/06/25.
//

import Foundation

public protocol FeedImageDataStore {
  typealias Result = Swift.Result<Data?, Error>
  typealias InsertionResult = Swift.Result<Void, Error>
  
  func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
  func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}
