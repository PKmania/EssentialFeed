//
//  Created by P K Gumbal on 26/03/25.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed {[unowned self] (error) in
            completion(error)
            if error == nil {
                self.store.insert(items: items, timestamp: self.currentDate())
            }
        }
    }
}
class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(iems: [FeedItem], timestamp: Date)
    }
    var receivedMessages = [ReceivedMessage]()
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    private var deletionCompletions = [DeletionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    func completeDeletion(with error:NSError, at index:Int = 0) {
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index:Int = 0) {
        deletionCompletions[index](nil)
    }
    func insert(items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insert(iems: items, timestamp: timestamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (store,_) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    func test_save_requestCacheDeletion() {
        let (store,sut) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        sut.save(items) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
        
    }
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (store,sut) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (store,sut) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(),uniqueItem()]
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(iems: items, timestamp: timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (store,sut) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStore, sut: LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store,file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store,sut)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any.com")!
    }
    
    private func anyNSError() -> NSError {
      return NSError(domain: "any error", code: 0)
    }
}
