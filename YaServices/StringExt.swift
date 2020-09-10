public extension String {
    func replacingByRegExp(of: String, with: String) -> String {
        replacingOccurrences(of: of,
                             with: with,
                             options: String.CompareOptions.regularExpression,
                             range: startIndex ..< endIndex)
    }
}
