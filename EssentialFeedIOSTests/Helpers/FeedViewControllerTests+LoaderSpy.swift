//
//  Created by CN23 on 08/05/25.
//

import Foundation
import EssentialFeed
import EssentialFeedIOS

extension FeedViewControllerTests {
  class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    //MARK: FeedLoader
    
    private var feedRequests = [(FeedLoader.Result) -> Void]()
    
    var loadFeedCallCount: Int {
      feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      feedRequests.append(completion)
    }
    func completeFeedLoading(with feed:[FeedImage] = [], at index: Int) {
      feedRequests[index](.success(feed))
    }
    func completeFeedLoadingWithError(at index: Int) {
      let error = NSError(domain: "any error", code: 0)
      feedRequests[index](.failure(error))
      
    }
    //MARK: FeedImageDataLoader
    
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
      return imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs = [URL]()
    private struct TaskSpy: FeedImageDataLoaderTask {
      let cancelCallback: () -> Void
      func cancel() {
        cancelCallback()
      }
    }
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
      imageRequests.append((url, completion))
      return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
      imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an error", code: 0)
      imageRequests[index].completion(.failure(error))
    }
    
  }
  
}
