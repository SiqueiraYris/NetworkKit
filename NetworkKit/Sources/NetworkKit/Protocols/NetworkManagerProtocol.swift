import Foundation

public protocol NetworkManagerProtocol: AnyObject {
    func request<T: Decodable, H: Decodable>(with config: RequestConfigProtocol,
                                             completion: @escaping (Result<(object: T, header: H?), ErrorHandler>) -> Void)
    @discardableResult
    func receive(on queue: DispatchQueue) -> Self
}
