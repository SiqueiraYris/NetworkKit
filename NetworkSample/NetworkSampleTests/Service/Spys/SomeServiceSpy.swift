import NetworkKit
@testable import NetworkSample

final class SomeServiceSpy: SomeServiceProtocol {
    var completionPassed: ((SomeResult) -> Void)?

    enum Message: Equatable {
        case success(object: SomeResponse, route: SomeServiceRoute)
        case failure(error: ErrorHandler, route: SomeServiceRoute)
    }

    var receivedMessages = [Message]()

    func completeWithSuccess(object: SomeResponse) {
        completionPassed?(.success((object: object, header: nil)))
    }

    func completeWithError(error: ErrorHandler = ErrorHandler(statusCode: 500,
                                                              data: nil,
                                                              defaultError: .internalServerError)) {
        completionPassed?(.failure(error))
    }

    func request(_ route: SomeServiceRoute, completion: @escaping (SomeResult) -> Void) {
        completionPassed = { [weak self] res in
            switch res {
            case .success(let object):
                self?.receivedMessages.append(.success(object: object.object, route: route))

            case .failure(let error):
                self?.receivedMessages.append(.failure(error: error, route: route))
            }

        }
    }
}
