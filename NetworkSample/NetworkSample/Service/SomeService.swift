import NetworkKit

typealias SomeResult = (Result<(object: SomeResponse, header: ResponseHeader?), ErrorHandler>)

protocol SomeServiceProtocol: AnyObject {
    func request(_ route: SomeServiceRoute, completion: @escaping(SomeResult) -> Void)
}

final class SomeService {
    private let networkManager: NetworkManagerProtocol

    public init(networking: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networking
    }
}

extension SomeService: SomeServiceProtocol {
    func request(_ route: SomeServiceRoute, completion: @escaping(SomeResult) -> Void) {
        networkManager.request(with: route.config, completion: completion)
    }
}
