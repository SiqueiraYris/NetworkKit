import Foundation

public protocol NetworkManagerProtocol: AnyObject {
    func request<T: Decodable>(with config: RequestConfigProtocol,
                               completion: @escaping (Result<(T), ResponseError>) -> Void)
}
