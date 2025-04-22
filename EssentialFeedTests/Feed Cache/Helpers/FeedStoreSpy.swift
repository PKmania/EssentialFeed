//
//  Created by P K Gumbal on 07/04/25.
//

import EssentialFeed


class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(iems: [LocalFeedImage], timestamp: Date)
        case retrieve
    }
    var receivedMessages = [ReceivedMessage]()
    var insertions = [(items: [FeedImage], timestamp: Date)]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error:NSError, at index:Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index:Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(iems: feed, timestamp: timestamp))
    }
    
    func completeInsertion(with error:NSError, at index:Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertionCompletions[index](.success(()))
    }
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error:NSError, at index:Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    func completeRetrievalWithEmptyCache(at index:Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
}

