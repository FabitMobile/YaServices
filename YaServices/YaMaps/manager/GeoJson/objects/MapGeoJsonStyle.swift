import UIKit

// ref type cause styles a lot less then lines itself
public class MapGeoJsonStyle {
    var tag: String
    var color: UIColor
    var width: Double

    public init(tag: String,
                color: UIColor,
                width: Double) {
        self.tag = tag
        self.color = color
        self.width = width
    }

    func asString() -> String? {
        guard let hex = color.toHex(alpha: false) else {
            return nil
        }

        let result = """
        {
          "tags": { "all": "\(tag)" },
          "style": {
            "line-color": "\(hex)",
            "line-width": \(width)
          }
        }
        """
        return result
    }
}

extension MapGeoJsonStyle: Equatable {
    public static func == (lhs: MapGeoJsonStyle, rhs: MapGeoJsonStyle) -> Bool {
        lhs.tag == rhs.tag
    }
}
