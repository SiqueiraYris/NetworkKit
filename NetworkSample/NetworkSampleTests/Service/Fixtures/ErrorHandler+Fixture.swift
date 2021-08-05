import Foundation
import NetworkKit
@testable import NetworkSample

extension ErrorHandler {
    public static func fixture(statusCode: Int = 500,
                               data: Data? = nil,
                               defaultError: NetworkErrors.HTTPErrors = .internalServerError) -> ErrorHandler {
        return ErrorHandler(statusCode: statusCode,
                            data: data,
                            defaultError: .internalServerError)
    }
}
