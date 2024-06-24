import Foundation
import NetworkKit
@testable import NetworkSample

extension ResponseError {
    public static func fixture(statusCode: Int = 500,
                               data: Data? = nil,
                               defaultError: NetworkErrors.HTTPErrors = .internalServerError) -> ResponseError {
        return ResponseError(statusCode: statusCode,
                            data: data,
                            defaultError: .internalServerError)
    }
}
