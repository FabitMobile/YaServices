import PromiseKit

public protocol TileInRegionGenerator {
    func tile(in region: MapRegion) -> Promise<Data>
}
