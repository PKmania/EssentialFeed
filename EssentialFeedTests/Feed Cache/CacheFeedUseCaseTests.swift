//
//  Created by P K Gumbal on 26/03/25.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}
class FeedStore {
    var deleteCachedFeedCallCount = 0
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (store,_) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    func test_save_requestCacheDeletion() {
        let (store,sut) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (store: FeedStore, sut: LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (store,sut)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any.com")!
    }
}
