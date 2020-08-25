import Foundation
import YandexMapKit

public class MapStorageManager {
    public init() {}

    public func clearCache(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let instance = YMKMapKit.sharedInstance()
            instance.storageManager.clear {
                completion()
            }
        }
    }
}
