// swiftlint:disable file_length
private func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

private func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}

// MARK: - AutoEquatable for classes, protocols, structs

// MARK: - PointOfInterest AutoEquatable

extension PointOfInterest: Equatable {}
public func == (lhs: PointOfInterest, rhs: PointOfInterest) -> Bool {
    guard lhs.title == rhs.title else { return false }
    guard lhs.latitude == rhs.latitude else { return false }
    guard lhs.longitude == rhs.longitude else { return false }
    guard compareOptionals(lhs: lhs.address, rhs: rhs.address, compare: ==) else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
