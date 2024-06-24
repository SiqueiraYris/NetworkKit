import Foundation

public protocol NetworkErrorsProtocol {
    var code: Int { get }
    var errorDescription: String? { get }
}
