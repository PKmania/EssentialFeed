//
//  Created by CN23 on 06/03/25.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
  private let session: URLSession
  public init(session: URLSession = .shared) {
    self.session = session
  }
  private struct UnexpectedValueRepresentation: Error {}
  public func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
    session.dataTask(with: url) { data, response, error in
      if let er = error {
        completion(.failure(er))
      }else if let data = data, let response = response as? HTTPURLResponse {
        completion(.success(data, response))
      }else {
        completion(.failure(UnexpectedValueRepresentation()))
      }
    }.resume()
  }
}
