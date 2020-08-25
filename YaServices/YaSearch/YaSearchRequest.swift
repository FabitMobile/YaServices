import Foundation

public struct YaSearchRequest {
    public var searchingText: String
    public var searchBounds: SearchBounds
    public var poiPrefixes: [String]
    public var maxDistanceForSearch: Double

    public init(searchingText: String,
                searchBounds: SearchBounds,
                poiPrefixes: [String],
                maxDistanceForSearch: Double) {
        self.searchingText = searchingText
        self.searchBounds = searchBounds
        self.poiPrefixes = poiPrefixes
        self.maxDistanceForSearch = maxDistanceForSearch
    }
}
