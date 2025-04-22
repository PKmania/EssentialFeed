//
//  Created by P K Gumbal on 11/04/25.
//

import Foundation

final class FeedCachePolicy {
    private init() {}
    private static let calender = Calendar(identifier: .gregorian)
    private static var maxCachedAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
