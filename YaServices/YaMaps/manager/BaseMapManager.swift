import CoreLocation
import UIKit

public class BaseMapManager: MapManager {
    // MARK: - props

    public weak var delegate: MapManagerDelegate?
    public weak var mapManagerAnimatedMarkerProcessingDelegate: MapManagerAnimatedMarkerProcessingDelegate?

    var cachedMapElements: Set<BaseMapElement>
    var cachedMapMarkers: Set<MapMarker> {
        // swiftlint:disable:next force_cast
        cachedMapElements.filter { $0 is MapMarker } as! Set<MapMarker>
    }

    var cachedMapAnimatedMarkers: Set<MapAnimatedMarker> {
        // swiftlint:disable:next force_cast
        cachedMapElements.filter { $0 is MapAnimatedMarker } as! Set<MapAnimatedMarker>
    }

    var cachedMapPolylines: Set<MapPolyline> {
        // swiftlint:disable:next force_cast
        cachedMapElements.filter { $0 is MapPolyline } as! Set<MapPolyline>
    }

    var cachedMapPolygons: Set<MapPolygon> {
        // swiftlint:disable:next force_cast
        cachedMapElements.filter { $0 is MapPolygon } as! Set<MapPolygon>
    }

    var cachedMapCircles: Set<MapCircle> {
        // swiftlint:disable:next force_cast
        cachedMapElements.filter { $0 is MapCircle } as! Set<MapCircle>
    }

    var centeringInsets: UIEdgeInsets

    // MARK: - life cicle

    init() {
        centeringInsets = .zero
        cachedMapElements = []
    }

    public func register(apiKey _: String) {
        fatalError("not implemented")
    }

    func resetCache() {
        centeringInsets = .zero
        cachedMapElements = []
    }

    // MARK: - updateMapElements

    public func updateMapElements(_ mapElements: [BaseMapElement], _ completion: MapManagerCompletion?) {
        let cachedMapElements = self.cachedMapElements
        let mapElementsSet = Set(mapElements)

        let mapElementsToUpdate = mapElementsSet.intersection(cachedMapElements)

        let mapElementsToRemove = cachedMapElements.subtracting(mapElementsToUpdate)
        let mapElementsToAdd = mapElementsSet.subtracting(mapElementsToUpdate)

        self.cachedMapElements = mapElementsSet

        DispatchQueue.main.async { [weak self] in
            guard let __self = self else { return }
            __self.updateMapElements(toAdd: Array(mapElementsToAdd),
                                     toRemove: Array(mapElementsToRemove),
                                     toUpdate: Array(mapElementsToUpdate)) {
                if let completion = completion {
                    completion()
                }
            }
        }
    }

    public func updateMapElements(toAdd mapElementsToAdd: [BaseMapElement],
                                  toRemove mapElementsToRemove: [BaseMapElement],
                                  toUpdate mapElementsToUpdate: [BaseMapElement],
                                  _ completion: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    // MARK: - region

    public func setCenteringInsets(_: CGFloat, _: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    public func centerAtCoordinate(_: CLLocationCoordinate2D, _: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    public func centerAtCoordinate(_: CLLocationCoordinate2D, _: Float, _: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    public func centerAtMe(_: MapManagerErrorCompletion?) {
        fatalError("not implemented")
    }

    public func centerAtMe(zoom _: Float, _: MapManagerErrorCompletion?) {
        fatalError("not implemented")
    }

    public func zoomIn(_: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    public func zoomIn(_: Float, completion _: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    public func zoomInRegion(_: MapRegion, completion _: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    public func zoomOut(_: MapManagerCompletion?) {
        fatalError("not implemented")
    }

    public func visibleRegion(changingZoom zoom: Float) -> MapRegion {
        fatalError("not implemented")
    }

    // MARK: - selection

    public func selectMarker(_ markerIdentifier: String, deselectingCurrent shouldDeselectCurrent: Bool) {
        guard let marker = cachedMapMarkers.first(where: { $0.identifier == markerIdentifier }) else { return }
        selectMarker(marker, deselectingCurrent: shouldDeselectCurrent)
    }

    func selectMarker(_ marker: MapMarker, deselectingCurrent shouldDeselectCurrent: Bool) {
        guard marker.state != .selected else { return }
        if shouldDeselectCurrent {
            deselectAllMarkers()
        }
        changeMarkerState(marker: marker, state: .selected, updatingStateGroup: true)
    }

    public func deselectMarker(_ markerIdentifier: String) {
        guard let marker = cachedMapMarkers.first(where: { $0.identifier == markerIdentifier }) else { return }
        deselectMarker(marker)
    }

    func deselectMarker(_ marker: MapMarker) {
        changeMarkerState(marker: marker, state: .normal, updatingStateGroup: true)
    }

    public func deselectAllMarkers() {
        deselectAllMarkers(nil)
    }

    public func deselectAllMarkers(_ completion: (() -> Void)?) {
        if let selectedMarker = selectedMarker() {
            deselectMarker(selectedMarker)
        }
        if let completion = completion {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func changeMarkerState(marker _: MapMarker,
                           state _: MapElementState,
                           updatingStateGroup _: Bool = true) {
        fatalError("not implemented")
    }

    // MARK: - map view

    public func mapView() -> UIView {
        fatalError("not implemented")
    }

    public func invalidateMapView() {
        fatalError("not implemented")
    }

    public func observeMapRegionChange(_: MapRegionObserverMode) {
        fatalError("not implemented")
    }

    public func mapCoordinateOfScreenPoint(_: CGPoint) -> CLLocationCoordinate2D? {
        fatalError("not implemented")
    }

    // MARK: - markers

    public func selectedMarker() -> MapMarker? {
        cachedMapMarkers.first(where: { $0.state == .selected })
    }

    public func marker(withIdentifier identifier: String) -> MapMarker? {
        cachedMapMarkers.first(where: { $0.identifier == identifier })
    }

    // MARK: - geojson

    public func isCustomTiledLayerDisplayed(layerId: String) -> Bool {
        fatalError("not implemented")
    }

    public func invalidateLayer(layerId: String, withVersion version: String) {
        fatalError("not implemented")
    }

    public func addCustomTiledLayer(version: String,
                                    layerId: String,
                                    styles: [MapGeoJsonStyle],
                                    generator: TileInRegionGenerator,
                                    keyStorage: DisplayedTilesQuadKeyStorage) {
        fatalError("not implemented")
    }

    public func removeCustomLayer(_ layerId: String) {
        fatalError("not implemented")
    }

    public func xyToWorld(x: Double, y: Double, zoom: Int) -> CLLocationCoordinate2D? {
        fatalError("not implemented")
    }

    public func worldToXY(withGeoPoint geoPoint: CLLocationCoordinate2D, zoom: Int) -> (x: Double, y: Double)? {
        fatalError("not implemented")
    }

    public func setStyle(lightness: Double, saturation: Double) throws {
        fatalError("not implemented")
    }
}
