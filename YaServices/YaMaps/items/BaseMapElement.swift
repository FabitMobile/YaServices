import Foundation

public enum MapElementState {
    case normal
    case selected
}

open class BaseMapElement: Hashable {
    public var identifier: String

    public var state: MapElementState
    public var stateGroupIdentifier: String? // if one element from group changes state - the other change

    public var userInfo: Any?

    public init(identifier: String) {
        self.identifier = identifier
        state = .normal
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier.hashValue)
    }

    public static func == (lhs: BaseMapElement, rhs: BaseMapElement) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
