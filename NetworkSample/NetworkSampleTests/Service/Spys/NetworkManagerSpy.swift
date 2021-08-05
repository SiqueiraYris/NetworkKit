import NetworkKit
@testable import NetworkSample

final class NetworkManagerSpy: NetworkManagerProtocol {
    var completionPassed: ((SomeResult) -> Void)?

    enum Message: Equatable {
        case request(result: SomeResult)
    }

    var receivedMessages = [Message]()

    func completeWithSuccess(result: SomeResult) {
        completionPassed?(result)
    }

    func completeWithError(error: ErrorHandler) {
        completionPassed?(.failure(error))
    }

    func request<T>(with config: RequestConfigProtocol, completion: @escaping (Result<(T), ErrorHandler>) -> Void) where T : Decodable {
        completionPassed = { [weak self] response in
            self?.receivedMessages.append(.request(result: response))
        }
    }
}
