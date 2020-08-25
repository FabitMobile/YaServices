import Foundation

public struct MapRegionObserverMode: OptionSet {
    public let rawValue: Int

    public static let onStart = MapRegionObserverMode(rawValue: 1 << 0)
    public static let onChange = MapRegionObserverMode(rawValue: 1 << 1)
    public static let onEnd = MapRegionObserverMode(rawValue: 1 << 2)

    public static let all: MapRegionObserverMode = [.onStart, .onChange, .onEnd]
    public static let onStartEnd: MapRegionObserverMode = [.onStart, .onEnd]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
