import Foundation
@testable import NetworkSample

extension SomeResponse {
    public static func fixture(someString: String = "any-string") -> SomeResponse {
        return SomeResponse(someString: someString)
    }
}
