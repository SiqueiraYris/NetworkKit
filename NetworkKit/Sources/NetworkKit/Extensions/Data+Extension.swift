import Foundation

public extension Data {
    var value: Data {
        guard self.isEmpty,
            let data = "{}".data(using: .utf8) else {
            return self
        }
        return data
    }

    func toString() -> String? {
        return (String(data: self, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: ""))
    }
}
