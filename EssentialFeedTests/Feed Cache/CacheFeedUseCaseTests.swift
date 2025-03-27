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
        store.deleteCachedFeed {[weak self] (error) in
            guard let self = self else { return }
            if error == nil {
                self.store.insert(items: items, timestamp: self.currentDate()) { [weak self] (error) in
                    guard self != nil else {return}
                    completion(error)
                }
            }else {
                completion(error)
            }
        }
    }
}
protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
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
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (store,sut) = makeSUT()
        let insertionError = anyNSError()
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succedsOnSuccessfulCacheInsertion() {
        let (store,sut) = makeSUT()
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocted() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResult = [Error?]()
        sut?.save([uniqueItem()], completion: { (error) in
            receivedResult.append(error)
        })
        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocted() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResult = [Error?]()
        sut?.save([uniqueItem()], completion: { (error) in
            receivedResult.append(error)
        })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    
    //MARK: - Helpers
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store,file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store,sut)
    }
    
    private class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert(iems: [FeedItem], timestamp: Date)
        }
        var receivedMessages = [ReceivedMessage]()
        var insertions = [(items: [FeedItem], timestamp: Date)]()
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
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
        func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(iems: items, timestamp: timestamp))
        }
        
        func completeInsertion(with error:NSError, at index:Int = 0) {
            insertionCompletions[index](error)
        }
        func completeInsertionSuccessfully(at index:Int = 0) {
            insertionCompletions[index](nil)
        }
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
