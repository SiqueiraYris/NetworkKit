import Foundation

/// This class receives infos in response header
public struct ResponseHeader: Decodable, Equatable {
    public let userInfo: String?
    public let contentType: String?
    public let contentLength: String?

    public init(dictionary: [AnyHashable: Any]) throws {
        self = try JSONDecoder().decode(ResponseHeader.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }

    // MARK: - CodingKeys

    public enum CodingKeys: String, CodingKey {
        case userInfo = "user-info"
        case contentType = "Content-Type"
        case contentLength = "Content-Length"
    }
}
