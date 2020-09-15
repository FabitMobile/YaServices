import CoreLocation
import Foundation
import YandexMapKit

// swiftlint:disable line_length
// swiftlint:disable file_length
// swiftlint:disable type_body_length
public class YaMapManager: BaseMapManager {
    // MARK: - props

    var yaMapView: YMKMapView?
    var placemarkMapObjects: Set<YMKPlacemarkMapObject>
    var animatedPlacemarkMapObjects: Set<YMKPlacemarkMapObject>
    var polylineMapObjects: Set<YMKPolylineMapObject>
    var polygonMapObjects: Set<YMKPolygonMapObject>
    var circleMapObjects: Set<YMKCircleMapObject>

    var cameraListener: YaMapCameraListener
    var objectTapListener: YaMapObjectTapListener
    var tapListener: YaMapTapListener
    var userLocationObjectListener: YaUserLocationObjectListener
    var userLocationLayer: YMKUserLocationLayer?
    var customLayers: [YaMapLayerData]
    let mercator: YMKProjection! = YMKCreateWgs84Mercator()

    // MARK: - life cicle

    public init(userLocationSettings: YaUserLocationSettings) {
        cameraListener = YaMapCameraListener()
        objectTapListener = YaMapObjectTapListener()
        tapListener = YaMapTapListener()
        userLocationObjectListener = YaUserLocationObjectListener()

        userLocationObjectListener.settings = userLocationSettings

        placemarkMapObjects = []
        animatedPlacemarkMapObjects = []
        polylineMapObjects = []
        polygonMapObjects = []
        circleMapObjects = []
        customLayers = []

        super.init()

        configureTapListener()
    }

    override public func register(apiKey: String) {
        YMKMapKit.setApiKey(apiKey)
    }

    override func resetCache() {
        super.resetCache()

        placemarkMapObjects = []
        animatedPlacemarkMapObjects = []
        polylineMapObjects = []
        polygonMapObjects = []
        circleMapObjects = []
    }

    override public func worldToXY(withGeoPoint geoPoint: CLLocationCoordinate2D,
                                   zoom: Int) -> (x: Double, y: Double)? {
        guard let merhator = YMKCreateWgs84Mercator() else { return nil }
        let point = merhator.worldToXY(withGeoPoint: YMKPoint(latitude: geoPoint.latitude,
                                                              longitude: geoPoint.longitude),
                                       zoom: zoom)
        return (x: point.x, y: point.y)
    }

    override public func xyToWorld(x: Double, y: Double, zoom: Int) -> CLLocationCoordinate2D? {
        guard let merhator = YMKCreateWgs84Mercator() else { return nil }
        let point = YMKXYPoint.xYPointWith(x: x, y: y)

        let mapKitPoint = merhator.xyToWorld(with: point, zoom: zoom)
        return CLLocationCoordinate2D(latitude: mapKitPoint.latitude,
                                      longitude: mapKitPoint.longitude)
    }

    func configureTapListener() {
        objectTapListener.onPlacemarkTap = { [weak self] placemark in
            guard let __self = self else { return }

            // -- search tapped
            guard let marker = __self.marker(forPlacemark: placemark) else { return }
            __self.delegate?.mapManager(__self, didTapMarker: marker)
        }
        objectTapListener.onShapeTap = { [weak self] object, point in
            guard let __self = self else { return }

            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: point.latitude,
                                                                            longitude: point.longitude)

            var shape: BaseMapElement?

            switch object {
            case _ where object is YMKPolylineMapObject:
                guard let polyline = __self.polyline(forPolylineMapObject: object as? YMKPolylineMapObject)
                else { break }
                shape = polyline
            case _ where object is YMKPolygonMapObject:
                guard let polygon = __self.polygon(forPolygonMapObject: object as? YMKPolygonMapObject) else { break }
                shape = polygon
            case _ where object is YMKCircleMapObject:
                guard let circle = __self.circle(forCircleMapObject: object as? YMKCircleMapObject) else { break }
                shape = circle
            default:
                break
            }

            guard let argShape = shape else { return }

            __self.delegate?.mapManager(__self, didTapShape: argShape, withCoordinate: coordinate)
        }
        tapListener.onTap = { [weak self] point in
            guard let __self = self else { return }
            __self.delegate?.mapManager(__self, didTapMap: point)
        }
    }

    // MARK: - region

    override public func setCenteringInsets(_ bottomOffset: CGFloat, _ completion: MapManagerCompletion?) {
        guard let yaMapView = yaMapView else {
            completion?()
            return
        }

        let bounds = yaMapView.bounds
        let scale = UIScreen.main.scale
        let topLeft = YMKScreenPoint(x: 0, y: 0)
        let bottomRight = YMKScreenPoint(x: Float(bounds.width * scale),
                                         y: Float((bounds.height - bottomOffset) * scale))

        let zeroTopLeft = YMKScreenPoint(x: Float(0), y: Float(0))
        let zeroBottomRight = YMKScreenPoint(x: Float(bounds.width * scale),
                                             y: Float(bounds.height * scale))

        let currentFocus = yaMapView.mapWindow.focusRect ?? YMKScreenRect(topLeft: zeroTopLeft,
                                                                          bottomRight: zeroBottomRight)
        let numOfParts = 25
        let step = (bottomRight.y - currentFocus.bottomRight.y) / Float(numOfParts)
        let timePart = 0.25 / Double(numOfParts)

        var i = 0
        while i < numOfParts {
            let stepNo = i

            var bottomRightOnStepX = currentFocus.bottomRight.x
            if bottomRightOnStepX > zeroBottomRight.x {
                bottomRightOnStepX = zeroBottomRight.x
            }

            var bottomRightOnStepY = currentFocus.bottomRight.y + step * Float(stepNo + 1)
            if bottomRightOnStepY > zeroBottomRight.y {
                bottomRightOnStepY = zeroBottomRight.y
            }
            let bottomRightOnStep = YMKScreenPoint(x: bottomRightOnStepX, y: bottomRightOnStepY)
            let stepRect = YMKScreenRect(topLeft: topLeft,
                                         bottomRight: bottomRightOnStep)
            DispatchQueue.main.asyncAfter(deadline: .now() + timePart * Double(stepNo)) { [weak self] in
                guard let __self = self else { return }
                guard let yaMapView = __self.yaMapView else { return }
                yaMapView.mapWindow.focusRect = stepRect
            }
            i += 1
        }
    }

    override public func centerAtCoordinate(_ coordinate: CLLocationCoordinate2D,
                                            _ completion: MapManagerCompletion?) {
        guard let map = yaMapView?.mapWindow.map else {
            completion?()
            return
        }

        let cameraPosition = map.cameraPosition.changing(target: YMKPoint(latitude: coordinate.latitude,
                                                                          longitude: coordinate.longitude))
        map.move(with: cameraPosition,
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?()
        }
    }

    override public func centerAtCoordinate(_ coordinate: CLLocationCoordinate2D,
                                            _ zoom: Float,
                                            _ completion: MapManagerCompletion?) {
        guard let map = yaMapView?.mapWindow.map else {
            completion?()
            return
        }

        let point = YMKPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let cameraPosition = map.cameraPosition.changing(target: point).changing(zoom: zoom)

        map.move(with: cameraPosition,
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?()
        }
    }

    override public func centerAtMe(_ completion: MapManagerErrorCompletion?) {
        guard let map = yaMapView?.mapWindow.map,
            let cameraPosition = userLocationLayer?.cameraPosition() else {
            completion?(MapError())
            return
        }

        map.move(with: cameraPosition,
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?(nil)
        }
    }

    override public func centerAtMe(zoom: Float, _ completion: MapManagerErrorCompletion?) {
        guard let map = yaMapView?.mapWindow.map,
            let cameraPosition = userLocationLayer?.cameraPosition() else {
            completion?(MapError())
            return
        }

        map.move(with: cameraPosition.changing(zoom: zoom),
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?(nil)
        }
    }

    override public func zoomIn(_ completion: MapManagerCompletion?) {
        guard let map = yaMapView?.mapWindow.map else {
            completion?()
            return
        }

        let cameraPosition = map.cameraPosition.changing(zoom: map.cameraPosition.zoom + 1)
        map.move(with: cameraPosition,
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?()
        }
    }

    override public func zoomIn(_ zoom: Float, completion: MapManagerCompletion?) {
        guard let map = yaMapView?.mapWindow.map else {
            completion?()
            return
        }

        let cameraPosition = map.cameraPosition.changing(zoom: zoom)
        map.move(with: cameraPosition,
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?()
        }
    }

    override public func zoomInRegion(_ mapRegion: MapRegion, completion: MapManagerCompletion?) {
        guard let map = yaMapView?.mapWindow.map else {
            completion?()
            return
        }

        let southWest = YMKPoint(latitude: mapRegion.maxLat, longitude: mapRegion.maxLon)
        let northEast = YMKPoint(latitude: mapRegion.minLat, longitude: mapRegion.minLon)
        let cameraPosition = map.cameraPosition(with: YMKBoundingBox(southWest: southWest, northEast: northEast))
        map.move(with: cameraPosition,
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?()
        }
    }

    override public func zoomOut(_ completion: MapManagerCompletion?) {
        guard let map = yaMapView?.mapWindow.map else {
            completion?()
            return
        }

        let cameraPosition = map.cameraPosition.changing(zoom: map.cameraPosition.zoom - 1)
        map.move(with: cameraPosition,
                 animationType: YMKAnimation(type: .smooth, duration: 0.25)) { _ in
            completion?()
        }
    }

    override public func visibleRegion(changingZoom zoom: Float) -> MapRegion {
        guard let map = yaMapView?.mapWindow.map else {
            return MapRegion(minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)
        }
        let cameraPosition = map.cameraPosition.changing(zoom: zoom)
        return map.visibleRegion(with: cameraPosition).makeMapRegion()
    }

    // MARK: - updateMapElements

    override public func updateMapElements(toAdd mapElementsToAdd: [BaseMapElement],
                                           toRemove mapElementsToRemove: [BaseMapElement],
                                           toUpdate mapElementsToUpdate: [BaseMapElement],
                                           _ completion: MapManagerCompletion?) {
        defer {
            if let completion = completion {
                completion()
            }
        }
        guard let mapView = yaMapView else { return }

        let collection = mapView.mapWindow.map.mapObjects
        removeMapElements(mapElementsToRemove, collection: collection)
        updateMapElements(mapElementsToUpdate, collection: collection)
        addMapElements(mapElementsToAdd, collection: collection)
    }

    // MARK: add/remove

    fileprivate func addMapElements(_ mapElements: [BaseMapElement], collection: YMKMapObjectCollection) {
        // swiftlint:disable force_cast

        addMapElements(mapElements.filter { $0 is MapMarker } as! [MapMarker],
                       collection: collection)
        addMapElements(mapElements.filter { $0 is MapPolyline } as! [MapPolyline],
                       collection: collection)
        addMapElements(mapElements.filter { $0 is MapPolygon } as! [MapPolygon],
                       collection: collection)
        addMapElements(mapElements.filter { $0 is MapCircle } as! [MapCircle],
                       collection: collection)
        addMapElements(mapElements.filter { $0 is MapAnimatedMarker } as! [MapAnimatedMarker],
                       collection: collection)

        // swiftlint:enable force_cast
    }

    fileprivate func removeMapElements(_ mapElements: [BaseMapElement], collection: YMKMapObjectCollection) {
        // swiftlint:disable force_cast

        removeMapElements(mapElements.filter { $0 is MapMarker } as! [MapMarker],
                          collection: collection)
        removeMapElements(mapElements.filter { $0 is MapPolyline } as! [MapPolyline],
                          collection: collection)
        removeMapElements(mapElements.filter { $0 is MapPolygon } as! [MapPolygon],
                          collection: collection)
        removeMapElements(mapElements.filter { $0 is MapCircle } as! [MapCircle],
                          collection: collection)
        removeMapElements(mapElements.filter { $0 is MapAnimatedMarker } as! [MapAnimatedMarker],
                          collection: collection)

        // swiftlint:enable force_cast
    }

    fileprivate func updateMapElements(_ mapElements: [BaseMapElement], collection: YMKMapObjectCollection) {
        // swiftlint:disable force_cast

        updateMapElements(mapElements.filter { $0 is MapMarker } as! [MapMarker],
                          collection: collection)
        updateMapElements(mapElements.filter { $0 is MapPolyline } as! [MapPolyline],
                          collection: collection)
        updateMapElements(mapElements.filter { $0 is MapPolygon } as! [MapPolygon],
                          collection: collection)
        updateMapElements(mapElements.filter { $0 is MapCircle } as! [MapCircle],
                          collection: collection)
        updateMapElements(mapElements.filter { $0 is MapAnimatedMarker } as! [MapAnimatedMarker],
                          collection: collection)

        // swiftlint:enable force_cast
    }

    // MARK: marker

    fileprivate func addMapElements(_ markers: [MapMarker], collection: YMKMapObjectCollection) {
        for item in markers {
            let placemark = makePlacemarkMapObject(from: item, collection: collection)
            placemarkMapObjects.insert(placemark)
            cachedMapElements.insert(item)
        }
    }

    fileprivate func removeMapElements(_ markers: [MapMarker], collection: YMKMapObjectCollection) {
        for item in markers {
            if let placemark = placemarkMapObject(forMarker: item) {
                collection.remove(with: placemark)
                placemarkMapObjects.remove(placemark)
                cachedMapElements.remove(item)
            }
        }
    }

    fileprivate func updateMapElements(_ markers: [MapMarker], collection: YMKMapObjectCollection) {
        for marker in markers {
            if let placemark = placemarkMapObject(forMarker: marker) {
                if let image = marker.images[marker.state]?.image {
                    placemark.setIconWith(image)
                    if marker.images[marker.state]?.anchorPoint != .zero {
                        let anchor = marker.images[marker.state]?.anchorPoint as NSValue?
                        placemark.setIconStyleWith(YMKIconStyle(anchor: anchor,
                                                                rotationType: nil,
                                                                zIndex: nil,
                                                                flat: nil,
                                                                visible: nil,
                                                                scale: nil,
                                                                tappableArea: nil))
                    }

                } else if let image = marker.images[.normal]?.image {
                    placemark.setIconWith(image)
                }
            }
        }
    }

    // MARK: animatedMarker

    fileprivate func addMapElements(_ markers: [MapAnimatedMarker], collection: YMKMapObjectCollection) {
        for item in markers {
            if let placemark = makeAnimatedPlacemarkMapObject(from: item, collection: collection) {
                animatedPlacemarkMapObjects.insert(placemark)
                placemark.zIndex = 10
                cachedMapElements.insert(item)
            }
        }
    }

    fileprivate func removeMapElements(_ markers: [MapAnimatedMarker], collection: YMKMapObjectCollection) {
        for item in markers {
            if let placemark = animatedPlacemarkMapObject(forMarker: item) {
                guard mapManagerAnimatedMarkerProcessingDelegate?.map(shouldDeleteAnimatedMarker: item) ?? true
                else { continue }

                if let emptyAnimatedImageProvider = makeEmptyAnimatedImageProvider() {
                    let icon = placemark.useAnimation()
                    icon.setIconWithImage(emptyAnimatedImageProvider,
                                          style: YMKIconStyle(),
                                          callback: { [weak self, weak placemark] in
                                              guard let __self = self,
                                                  let __placemark = placemark else { return }
                                              collection.remove(with: __placemark)
                                              __self.animatedPlacemarkMapObjects.remove(__placemark)
                                              __self.cachedMapElements.remove(item)
                                          })
                } else {
                    collection.remove(with: placemark)
                    animatedPlacemarkMapObjects.remove(placemark)
                    cachedMapElements.remove(item)
                }
            }
        }
    }

    fileprivate func updateMapElements(_ markers: [MapAnimatedMarker], collection: YMKMapObjectCollection) {
        for marker in markers {
            if let placemark = animatedPlacemarkMapObject(forMarker: marker),
                let animation = animation(for: marker),
                makeAnimatedImageProvider(from: animation) != nil {
                if let oldMarker = animatedMarker(forAnimatedPlacemark: placemark),
                    let oldAnimation = self.animation(for: oldMarker) {
                    let zipArray = Array(zip(animation.frames, oldAnimation.frames))
                    // swiftlint:disable:next reduce_boolean
                    let shouldUpdateAnimation = zipArray.reduce(false) { $0 && ($1.0.image === $1.1.image &&
                            $1.0.duration == $1.1.duration) }

                    guard shouldUpdateAnimation, marker.animationState != .isAnimating else { return }

                    setAnimation(for: placemark, from: marker)
                }
            }
        }
    }

    // MARK: polyline

    fileprivate func addMapElements(_ polylines: [MapPolyline], collection: YMKMapObjectCollection) {
        for item in polylines {
            let polylineMO = makePolylineMapObject(from: item, collection: collection)
            polylineMapObjects.insert(polylineMO)
            cachedMapElements.insert(item)
        }
    }

    fileprivate func removeMapElements(_ polylines: [MapPolyline], collection: YMKMapObjectCollection) {
        for item in polylines {
            if let polylineMO = polylineMapObject(forPolyline: item) {
                collection.remove(with: polylineMO)
                polylineMapObjects.remove(polylineMO)
                cachedMapElements.remove(item)
            }
        }
    }

    fileprivate func updateMapElements(_ polylines: [MapPolyline], collection: YMKMapObjectCollection) {
        for polyline in polylines {
            if let polylineMO = polylineMapObject(forPolyline: polyline) {
                if let color = polyline.lineColors[polyline.state] {
                    polylineMO.strokeColor = color

                } else if let color = polyline.lineColors[.normal] {
                    polylineMO.strokeColor = color
                }
            }
        }
    }

    // MARK: polygon

    fileprivate func addMapElements(_ polygons: [MapPolygon], collection: YMKMapObjectCollection) {
        for item in polygons {
            let polygonMO = makePolygonMapObject(from: item, collection: collection)
            polygonMapObjects.insert(polygonMO)
            cachedMapElements.insert(item)
        }
    }

    fileprivate func removeMapElements(_ polygons: [MapPolygon], collection: YMKMapObjectCollection) {
        for item in polygons {
            if let polygonMO = polygonMapObject(forPolygon: item) {
                collection.remove(with: polygonMO)
                polygonMapObjects.remove(polygonMO)
                cachedMapElements.remove(item)
            }
        }
    }

    fileprivate func updateMapElements(_ polygons: [MapPolygon], collection: YMKMapObjectCollection) {
        for polygon in polygons {
            if let polygonMO = polygonMapObject(forPolygon: polygon) {
                if let color = polygon.lineColors[polygon.state] {
                    polygonMO.strokeColor = color

                } else if let color = polygon.lineColors[.normal] {
                    polygonMO.strokeColor = color
                }

                if let fillColor = polygon.fillColors[polygon.state] {
                    polygonMO.fillColor = fillColor

                } else if let fillColor = polygon.fillColors[.normal] {
                    polygonMO.fillColor = fillColor
                }
            }
        }
    }

    // MARK: circle

    fileprivate func addMapElements(_ circles: [MapCircle], collection: YMKMapObjectCollection) {
        for item in circles {
            guard let circleMO = makeCircleMapObject(from: item,
                                                     collection: collection) else { continue }
            circleMapObjects.insert(circleMO)
            cachedMapElements.insert(item)
        }
    }

    fileprivate func removeMapElements(_ circles: [MapCircle], collection: YMKMapObjectCollection) {
        for item in circles {
            if let circleMO = circleMapObject(forCircle: item) {
                collection.remove(with: circleMO)
                circleMapObjects.remove(circleMO)
                cachedMapElements.remove(item)
            }
        }
    }

    fileprivate func updateMapElements(_ circles: [MapCircle], collection: YMKMapObjectCollection) {
        for circle in circles {
            if let circleMO = circleMapObject(forCircle: circle) {
                if let color = circle.colors[circle.state] {
                    circleMO.strokeColor = color
                    circleMO.fillColor = color

                } else if let color = circle.colors[.normal] {
                    circleMO.strokeColor = color
                    circleMO.fillColor = color
                }
            }
        }
    }

    // MARK: - map view

    override public func mapView() -> UIView {
        invalidateMapView()
        
        let view = YMKMapView()

        let map = view.mapWindow.map
        map.addCameraListener(with: cameraListener)
        map.addInputListener(with: tapListener)

        let mapKit = YMKMapKit.sharedInstance()
        userLocationLayer = mapKit.createUserLocationLayer(with: view.mapWindow)

        userLocationLayer?.setVisibleWithOn(true)
        userLocationLayer?.isHeadingEnabled = true
        userLocationLayer?.setObjectListenerWith(userLocationObjectListener)

        map.isRotateGesturesEnabled = false
        map.isTiltGesturesEnabled = false

        yaMapView = view
        return view
    }

    override public func invalidateMapView() {
        userLocationLayer?.setVisibleWithOn(false)
        userLocationLayer?.isHeadingEnabled = false
        userLocationLayer?.setObjectListenerWith(nil)
        userLocationLayer = nil

        customLayers.forEach { data in
            removeCustomLayer(data.layerId)
        }

        yaMapView?.mapWindow.map.removeCameraListener(with: cameraListener)
        yaMapView?.mapWindow.map.removeInputListener(with: tapListener)

        yaMapView = nil
        resetCache()
    }

    override public func observeMapRegionChange(_ mode: MapRegionObserverMode) {
        if mode.contains(.onStart) {
            cameraListener.onStart = { [weak self] region, zoom in
                guard let __self = self else { return }
                __self.delegate?.mapManager(__self, didBeginChangingRegion: region, atZoom: zoom)
            }
        }
        if mode.contains(.onChange) {
            cameraListener.onChange = { [weak self] region, zoom in
                guard let __self = self else { return }
                __self.delegate?.mapManager(__self, didChangeRegion: region, atZoom: zoom)
            }
        }
        if mode.contains(.onEnd) {
            cameraListener.onEnd = { [weak self] region, zoom in
                guard let __self = self else { return }
                __self.delegate?.mapManager(__self, didEndChangingRegion: region, atZoom: zoom)
            }
        }
    }

    override public func mapCoordinateOfScreenPoint(_ screenPoint: CGPoint) -> CLLocationCoordinate2D? {
        let scale = UIScreen.main.scale
        guard let window = yaMapView?.mapWindow,
            let point = window.screenToWorld(with: YMKScreenPoint(x: Float(screenPoint.x * scale),
                                                                  y: Float(screenPoint.y * scale))) else { return nil }
        return CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
    }

    public struct MapSetStyleFailed: Error {}
    
    override public func setStyle(lightness: Double, saturation: Double) throws {
        guard let map = yaMapView?.mapWindow?.map else { return }
        let style =
            """
            [
                {
                    "stylers" : {
                        "saturation" : \(saturation),
                        "lightness" : \(lightness)
                    }
                }
            ]
            """
        let result = map.setMapStyleWithStyle(style)
        if !result { throw MapSetStyleFailed() }
    }

    // MARK: - marker

    override func changeMarkerState(marker: MapMarker,
                                    state: MapElementState,
                                    updatingStateGroup: Bool = true) {
        guard let placemark = placemarkMapObject(forMarker: marker) else { return }
        changeMarkerState(marker: marker,
                          placemark: placemark,
                          state: state,
                          updatingStateGroup: updatingStateGroup)
    }

    func changeMarkerState(marker: MapMarker,
                           placemark: YMKPlacemarkMapObject,
                           state: MapElementState,
                           updatingStateGroup: Bool = true) {
        marker.state = state
        if let icon = marker.images[state]?.image {
            placemark.setIconWith(icon)
        }

        if state == .normal {
            placemark.zIndex = 0
        } else {
            placemark.zIndex = 1
        }

        if updatingStateGroup {
            let groupElements = cachedMapElements
                .filter {
                    guard let group = $0.stateGroupIdentifier else { return false }
                    return group == marker.stateGroupIdentifier
                }
                .subtracting([marker] as Set<BaseMapElement>)

            for item in groupElements {
                if let marker = item as? MapMarker,
                    let placemarkMapObject = placemarkMapObject(forMarker: marker) {
                    changeMarkerState(marker: marker,
                                      placemark: placemarkMapObject,
                                      state: state,
                                      updatingStateGroup: false)

                } else if let polyline = item as? MapPolyline,
                    let polylineMapObject = polylineMapObject(forPolyline: polyline) {
                    changePolylineState(polyline: polyline,
                                        polylineMapObject: polylineMapObject,
                                        state: state)

                } else if let polygon = item as? MapPolygon,
                    let polygonMapObject = polygonMapObject(forPolygon: polygon) {
                    changePolygonState(polygon: polygon,
                                       polygonMapObject: polygonMapObject,
                                       state: state)
                }
            }
        }
    }

    func changePolylineState(polyline: MapPolyline,
                             polylineMapObject: YMKPolylineMapObject,
                             state: MapElementState) {
        polyline.state = state
        if let color = polyline.lineColors[state] {
            polylineMapObject.strokeColor = color
        }

        if state == .normal {
            polylineMapObject.zIndex = 0
        } else {
            polylineMapObject.zIndex = 1
        }
    }

    func changePolygonState(polygon: MapPolygon,
                            polygonMapObject: YMKPolygonMapObject,
                            state: MapElementState) {
        polygon.state = state
        if let color = polygon.lineColors[state] {
            polygonMapObject.strokeColor = color
        }
        if let fillColor = polygon.fillColors[state] {
            polygonMapObject.fillColor = fillColor
        }

        if state == .normal {
            polygonMapObject.zIndex = 0
        } else {
            polygonMapObject.zIndex = 1
        }
    }

    // MARK: - placemarks

    fileprivate func makePlacemarkMapObject(from marker: MapMarker,
                                            collection: YMKMapObjectCollection) -> YMKPlacemarkMapObject {
        let point = YMKPoint(latitude: marker.coordinate.latitude,
                             longitude: marker.coordinate.longitude)
        let placemark = collection.addPlacemark(with: point)
        placemark.userData = marker.identifier

        if let image = marker.images[marker.state]?.image {
            placemark.setIconWith(image)

        } else if let image = marker.images[.normal]?.image {
            placemark.setIconWith(image)
        }

        placemark.addTapListener(with: objectTapListener)
        return placemark
    }

    fileprivate func placemarkMapObject(forMarker marker: MapMarker) -> YMKPlacemarkMapObject? {
        placemarkMapObjects.first(where: {
            guard $0.isValid,
                let placemarkId = $0.userData as? String else { return false }
            return placemarkId == marker.identifier
        })
    }

    fileprivate func marker(forPlacemark placemark: YMKPlacemarkMapObject) -> MapMarker? {
        guard let placemarkId = placemark.userData as? String else { return nil }
        return cachedMapMarkers.first(where: { $0.identifier == placemarkId })
    }

    // MARK: - animatedPlacemarks

    fileprivate func makeAnimatedPlacemarkMapObject(from marker: MapAnimatedMarker,
                                                    collection: YMKMapObjectCollection) -> YMKPlacemarkMapObject? {
        let point = YMKPoint(latitude: marker.coordinate.latitude,
                             longitude: marker.coordinate.longitude)

        if let animation = animation(for: marker),
            let emptyAnimatedImageProvider = makeEmptyAnimatedImageProvider(),
            makeAnimatedImageProvider(from: animation) != nil {
            let placemark = collection.addPlacemark(with: point,
                                                    animatedImage: emptyAnimatedImageProvider,
                                                    style: YMKIconStyle())
            placemark.userData = marker.identifier
            setAnimation(for: placemark, from: marker)

            return placemark
        }
        return nil
    }

    fileprivate func animatedPlacemarkMapObject(forMarker marker: MapAnimatedMarker) -> YMKPlacemarkMapObject? {
        animatedPlacemarkMapObjects.first(where: {
            guard $0.isValid,
                let placemarkId = $0.userData as? String else { return false }
            return placemarkId == marker.identifier
        })
    }

    fileprivate func animatedMarker(forAnimatedPlacemark placemark: YMKPlacemarkMapObject) -> MapAnimatedMarker? {
        guard let placemarkId = placemark.userData as? String else { return nil }
        return cachedMapAnimatedMarkers.first(where: { $0.identifier == placemarkId })
    }

    // MARK: - polyline

    fileprivate func makePolylineMapObject(from polyline: MapPolyline,
                                           collection: YMKMapObjectCollection) -> YMKPolylineMapObject {
        var points: [YMKPoint] = []
        for coordinate in polyline.coordinates {
            points.append(YMKPoint(latitude: coordinate.latitude,
                                   longitude: coordinate.longitude))
        }
        let line = YMKPolyline(points: points)
        let polylineMapObject = collection.addPolyline(with: line)
        polylineMapObject.userData = polyline.identifier
        if let color = polyline.lineColors[polyline.state] {
            polylineMapObject.strokeColor = color

        } else if let color = polyline.lineColors[.normal] {
            polylineMapObject.strokeColor = color
        }
        polylineMapObject.addTapListener(with: objectTapListener)
        return polylineMapObject
    }

    fileprivate func polylineMapObject(forPolyline polyline: MapPolyline) -> YMKPolylineMapObject? {
        polylineMapObjects.first(where: {
            guard $0.isValid,
                let polylineId = $0.userData as? String else { return false }
            return polylineId == polyline.identifier
        })
    }

    fileprivate func polyline(forPolylineMapObject polyline: YMKPolylineMapObject?) -> MapPolyline? {
        guard let polylineId = polyline?.userData as? String else { return nil }
        return cachedMapPolylines.first(where: { $0.identifier == polylineId })
    }

    // MARK: - polygon

    fileprivate func makePolygonMapObject(from polygon: MapPolygon,
                                          collection: YMKMapObjectCollection) -> YMKPolygonMapObject {
        var points: [YMKPoint] = []
        for coordinate in polygon.coordinates {
            points.append(YMKPoint(latitude: coordinate.latitude,
                                   longitude: coordinate.longitude))
        }
        let outerRing = YMKLinearRing(points: points)
        let gon = YMKPolygon(outerRing: outerRing, innerRings: [])
        let polygonMapObject = collection.addPolygon(with: gon)
        polygonMapObject.userData = polygon.identifier
        if let color = polygon.lineColors[polygon.state] {
            polygonMapObject.strokeColor = color

        } else if let color = polygon.lineColors[.normal] {
            polygonMapObject.strokeColor = color
        }

        if let fillColor = polygon.fillColors[polygon.state] {
            polygonMapObject.fillColor = fillColor

        } else if let fillColor = polygon.fillColors[.normal] {
            polygonMapObject.fillColor = fillColor
        }
        polygonMapObject.addTapListener(with: objectTapListener)
        return polygonMapObject
    }

    fileprivate func polygonMapObject(forPolygon polygon: MapPolygon) -> YMKPolygonMapObject? {
        polygonMapObjects.first(where: {
            guard $0.isValid,
                let polygonId = $0.userData as? String else { return false }
            return polygonId == polygon.identifier
        })
    }

    fileprivate func polygon(forPolygonMapObject polygon: YMKPolygonMapObject?) -> MapPolygon? {
        guard let polygonId = polygon?.userData as? String else { return nil }
        return cachedMapPolygons.first(where: { $0.identifier == polygonId })
    }

    // MARK: - circle

    fileprivate func makeCircleMapObject(from mapCircle: MapCircle,
                                         collection: YMKMapObjectCollection) -> YMKCircleMapObject? {
        let ymkpoint: YMKPoint = YMKPoint(latitude: mapCircle.centrCoordinate.latitude,
                                          longitude: mapCircle.centrCoordinate.longitude)
        let circle = YMKCircle(center: ymkpoint, radius: Float(mapCircle.circleDiameter))
        if let color = mapCircle.colors[.normal] {
            let circleMO = collection.addCircle(with: circle,
                                                stroke: color,
                                                strokeWidth: circle.radius,
                                                fill: color)
            circleMO.userData = mapCircle.identifier

            if let color = mapCircle.colors[mapCircle.state] {
                circleMO.strokeColor = color
                circleMO.fillColor = color

            } else if let color = mapCircle.colors[.normal] {
                circleMO.strokeColor = color
                circleMO.fillColor = color
            }

            circleMO.addTapListener(with: objectTapListener)
            return circleMO
        }
        return nil
    }

    fileprivate func circleMapObject(forCircle circle: MapCircle) -> YMKCircleMapObject? {
        circleMapObjects.first(where: {
            guard $0.isValid,
                let circleId = $0.userData as? String else { return false }
            return circleId == circle.identifier
        })
    }

    fileprivate func circle(forCircleMapObject circle: YMKCircleMapObject?) -> MapCircle? {
        guard let circleId = circle?.userData as? String else { return nil }
        return cachedMapCircles.first(where: { $0.identifier == circleId })
    }

    // MARK: - Geojson

    override public func isCustomTiledLayerDisplayed(layerId: String) -> Bool {
        customLayers.contains(where: { $0.layerId == layerId })
    }

    override public func invalidateLayer(layerId: String, withVersion version: String) {
        guard let data = customLayers.first(where: { $0.layerId == layerId }) else {
            assertionFailure("layer with id: \(layerId) is not presented")
            return
        }
        data.tileProvider.version = version
        data.layer.invalidate(withVersion: version)
        data.layer.activateWith(on: true)
    }

    override public func addCustomTiledLayer(version: String,
                                             layerId: String,
                                             styles: [MapGeoJsonStyle],
                                             generator: TileInRegionGenerator,
                                             keyStorage: DisplayedTilesQuadKeyStorage) {
        guard let map = yaMapView?.mapWindow.map else {
            assertionFailure("map was not set correclty")
            return
        }
        guard !isCustomTiledLayerDisplayed(layerId: layerId) else {
            assertionFailure("layer with id: \(layerId) already displayed")
            return
        }

        let tileGenerator = YaTilesGenerator(generator: generator, projection: mercator)
        let tileProvider = YaTilesProvider(version: version,
                                           generator: tileGenerator,
                                           keyStorage: keyStorage)

        let options = YMKLayerOptions()
        options.animateOnActivation = false
        options.cacheable = true
        options.overzoomMode = .enabled

        let styles = styles.compactMap { $0.asString() }.joined(separator: ",")
        let style = "[\(styles)]"

        let layer = map.addGeoJSONLayer(withLayerId: layerId,
                                        style: style,
                                        layerOptions: options,
                                        tileProvider: tileProvider,
                                        imageUrlProvider: tileProvider,
                                        projection: mercator,
                                        zoomRanges: [])

        layer.invalidate(withVersion: version)

        layer.activateWith(on: true)

        if let lastVersion = keyStorage.lastVersion(), lastVersion != version {
            layer.clear()
        }

        let data = YaMapLayerData(layerId: layerId,
                                  layer: layer,
                                  tileProvider: tileProvider)

        customLayers.append(data)
    }

    override public func removeCustomLayer(_ layerId: String) {
        guard let index = customLayers.firstIndex(where: { $0.layerId == layerId }) else {
            return
        }

        let data = customLayers.remove(at: index)
        data.layer.remove()
    }

    // MARK: - private

    fileprivate func setAnimation(for placemark: YMKPlacemarkMapObject?, from marker: MapAnimatedMarker) {
        guard let placemark = placemark else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + marker.delay) { [weak self, weak placemark, weak marker] in
            guard let __self = self,
                let __placemark = placemark,
                __placemark.isValid,
                let __marker = marker,
                __self.mapManagerAnimatedMarkerProcessingDelegate?.map(shouldShowAnimatedMarker: __marker) ?? true,
                let animation = __self.animation(for: __marker),
                let emptyAnimatedImageProvider = __self.makeEmptyAnimatedImageProvider(),
                let provider = __self.makeAnimatedImageProvider(from: animation) else { return }

            __marker.animationState = .isAnimating

            let icon = __placemark.useAnimation()
            icon.setIconWithImage(provider, style: YMKIconStyle()) { [weak placemark, weak marker] in
                guard let __marker = marker,
                    let icon = placemark?.useAnimation() else { return }

                let onAnimationFinish = { [weak placemark, weak icon] in
                    guard let __placemark = placemark,
                        __placemark.isValid,
                        let __icon = icon,
                        __icon.isValid else {
                        __marker.animationState = .didAnimate
                        return
                    }

                    if __icon.isValid {
                        __icon.stop()
                        __icon.setIconWithImage(emptyAnimatedImageProvider, style: YMKIconStyle())
                    }

                    __marker.animationState = .didAnimate
                }

                icon.play(callback: onAnimationFinish)
            }
        }
    }

    fileprivate func animation(for marker: MapAnimatedMarker) -> MapAnimatedMarkerAnimation? {
        let _: [MapAnimationFrame] = []

        if let animation = marker.animations[marker.state], !animation.frames.isEmpty {
            return animation
        } else if let animation = marker.animations[.normal], !animation.frames.isEmpty {
            return animation
        }

        return nil
    }

    fileprivate func makeAnimatedImageProvider(from animation: MapAnimatedMarkerAnimation) -> YRTAnimatedImageProvider? {
        let markerFrames: [MapAnimationFrame] = animation.frames
        let visionTime: TimeInterval = animation.duration

        let animationDuration = markerFrames.map { $0.duration }.reduce(0, +)
        let loopCount = Int32(visionTime / animationDuration)

        let animatedImage = YRTAnimatedImage(loopCount: loopCount)

        for frame in markerFrames {
            animatedImage?.addFrame(with: frame.image, duration: frame.duration)
        }

        return YRTAnimatedImageProviderFactory.fromAnimatedImage(animatedImage) as? YRTAnimatedImageProvider
    }

    func makeEmptyAnimatedImageProvider() -> YRTAnimatedImageProvider? {
        let animatedImage = YRTAnimatedImage()
        return YRTAnimatedImageProviderFactory.fromAnimatedImage(animatedImage) as? YRTAnimatedImageProvider
    }
}
