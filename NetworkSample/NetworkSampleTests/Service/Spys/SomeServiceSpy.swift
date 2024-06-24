import NetworkKit
@testable import NetworkSample

final class SomeServiceSpy: SomeServiceProtocol {
    var completionPassed: ((SomeResult) -> Void)?

    enum Message: Equatable {
        case request(result: SomeResult)
//        case success(object: SomeResponse, route: SomeServiceRoute)
//        case failure(error: ErrorHandler, route: SomeServiceRoute)
    }

    var receivedMessages = [Message]()

    func completeWithSuccess(object: SomeResponse) {
        completionPassed?(.success(object))
    }

    func completeWithError(error: ResponseError) {
        completionPassed?(.failure(error))
    }

    func request(_ route: SomeServiceRoute, completion: @escaping (SomeResult) -> Void) {
        completionPassed = { [weak self] response in
            self?.receivedMessages.append(.request(result: response))
//            switch response {
//            case .success(let object):
//                self?.receivedMessages.append(.success(object: object, route: route))
//
//            case .failure(let error):
//                self?.receivedMessages.append(.failure(error: error, route: route))
//            }
        }
    }
}
