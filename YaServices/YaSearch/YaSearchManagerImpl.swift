import CoreLocation
import Foundation
import PromiseKit
import YandexMapKitSearch

struct NilSelfError: Error {}

public class YaSearchManagerImpl: YaSearchManager {
    var searchSession: YMKSearchSession?
    var suggestSession: YMKSearchSuggestSession?
    var pointsOfInterestManager: YMKSearchManager?
    let searchOptions: YMKSearchOptions

    public init() {
        pointsOfInterestManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
        suggestSession = pointsOfInterestManager?.createSuggestSession()

        searchOptions = YMKSearchOptions()
        searchOptions.resultPageSize = NSNumber(value: 100)
    }

    // MARK: - public

    public func search(_ request: YaSearchRequest) -> Promise<[PointOfInterest]> {
        remotePointsOfInterest(request)
            .then { [weak self] pois -> Promise<[PointOfInterest]> in
                guard let __self = self else { throw NilSelfError() }
                return pois.isEmpty ? __self.remoteSuggest(request) : .value(pois)
            }
    }

    // MARK: - private

    func remoteSuggest(_ request: YaSearchRequest) -> Promise<[PointOfInterest]> {
        convert(request: request)
            .then { (searchAreaCenter, searchBounds) -> Promise<[PointOfInterest]> in
                Promise<[PointOfInterest]>(resolver: { [weak self] seal in
                    guard let __self = self else { return }

                    let suggestHandler = { (items: [YMKSuggestItem]?, error: Error?) -> Void in
                        if let items = items {
                            var objects: [PointOfInterest] = []

                            for item in items where item.uri != nil {
                                guard var title = item.displayText,
                                    let uri = item.uri,
                                    let poiLocation = __self.makeCoordinate(from: uri) else { continue }

                                let distance = poiLocation.distance(from: searchAreaCenter)

                                guard distance < request.maxDistanceForSearch else { continue }

                                var adress = ""
                                for prefix in request.poiPrefixes where title.contains(prefix) {
                                    title = title.replacingByRegExp(of: prefix, with: "")
                                    adress = prefix
                                }

                                objects.append(PointOfInterest(title: title,
                                                               latitude: poiLocation.coordinate.latitude,
                                                               longitude: poiLocation.coordinate.longitude,
                                                               adress: adress))
                            }
                            seal.fulfill(objects)
                        } else if let error = error {
                            seal.reject(error)
                        }
                    }

                    DispatchQueue.main.async { [weak self] in
                        guard let __self = self else { return }

                        __self.suggestSession?.suggest(withText: request.searchingText,
                                                       window: searchBounds,
                                                       suggestOptions: YMKSuggestOptions(),
                                                       responseHandler: suggestHandler)
                    }
                })
            }
    }

    func remotePointsOfInterest(_ request: YaSearchRequest) -> Promise<[PointOfInterest]> {
        convert(request: request)
            .then { (searchAreaCenter, searchBounds) -> Promise<[PointOfInterest]> in
                Promise(resolver: { [weak self] seal in

                    let responseHandler = { (response: YMKSearchResponse?, error: Error?) -> Void in
                        if let response = response {
                            var objects: [PointOfInterest] = []

                            for result in response.collection.children where result.obj?.geometry.first?.point != nil {
                                let point = result.obj?.geometry.first?.point
                                guard let title = result.obj?.name,
                                    let latitude = point?.latitude,
                                    let longitude = point?.longitude else { continue }

                                let poiLocation = CLLocation(latitude: latitude, longitude: longitude)
                                let distance = poiLocation.distance(from: searchAreaCenter)

                                guard distance < request.maxDistanceForSearch else { continue }

                                objects.append(PointOfInterest(title: title,
                                                               latitude: latitude,
                                                               longitude: longitude,
                                                               adress: result.obj?.descriptionText))
                            }
                            seal.fulfill(objects)
                        } else if let error = error {
                            seal.reject(error)
                        }
                    }
                    let geometry: YMKGeometry = YMKGeometry(boundingBox: searchBounds)

                    DispatchQueue.main.async { [weak self] in
                        guard let __self = self else { return }
                        let searchOptions = __self.searchOptions
                        __self.searchSession = __self.pointsOfInterestManager?.submit(withText: request.searchingText,
                                                                                      geometry: geometry,
                                                                                      searchOptions: searchOptions,
                                                                                      responseHandler: responseHandler)
                    }
                })
            }
    }

    // MARK: - utility

    func convert(request: YaSearchRequest) -> Promise<(CLLocation, YMKBoundingBox)> {
        Promise<(CLLocation, YMKBoundingBox)> { seal in
            let northEastCoordinate = request.searchBounds.northEast
            let southWestCoordinate = request.searchBounds.southWest

            let centerLatitude = (northEastCoordinate.latitude + southWestCoordinate.latitude) / 2
            let centerLongitude = (northEastCoordinate.longitude + southWestCoordinate.longitude) / 2

            let searchAreaCenter = CLLocation(latitude: centerLatitude,
                                              longitude: centerLongitude)

            let searchBounds = YMKBoundingBox(
                southWest: YMKPoint(latitude: request.searchBounds.southWest.latitude,
                                    longitude: request.searchBounds.southWest.longitude),
                northEast: YMKPoint(latitude: request.searchBounds.northEast.latitude,
                                    longitude: request.searchBounds.northEast.longitude)
            )

            seal.fulfill((searchAreaCenter, searchBounds))
        }
    }

    func makeCoordinate(from uri: String) -> CLLocation? {
        let optLatitude = Double(uri.replacingByRegExp(of: ".*(ll)=(\\d{1,2}).(\\d{1,6}).*$", with: "$2.$3"))
        let optLongitude = Double(uri.replacingByRegExp(of: ".*(2C)(\\d{1,2}).(\\d{1,6})(&spn).*$", with: "$2.$3"))

        guard let latitude = optLatitude,
            let longitude = optLongitude else { return nil }

        return CLLocation(latitude: longitude, longitude: latitude)
    }
}
