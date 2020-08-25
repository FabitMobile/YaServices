import Foundation
import PromiseKit

public protocol YaSearchManager {
    func search(_ request: YaSearchRequest) -> Promise<[PointOfInterest]>
}
