import XCTest
import NetworkKit
@testable import NetworkSample

class ViewControllerTests: XCTestCase {

    func test_init_shouldFetchDataWithSuccess() {
        let response = SomeResponse.fixture()
        let result: SomeResult = .success(response)
        let (sut, service) = makeSUT()

        _ = sut.view
        service.completeWithSuccess(object: response)

        XCTAssertEqual(service.receivedMessages, [.request(result: result)])
//        XCTAssertEqual(service.receivedMessages, [.success(object: response, route: SomeServiceRoute.prepare)])
    }

    func test_init_shouldNotFetchData() {
        let (sut, service) = makeSUT()
        let error = ErrorHandler.fixture()
        let result: SomeResult = .failure(error)

        _ = sut.view
        service.completeWithError(error: error)

        XCTAssertEqual(service.receivedMessages, [.request(result: result)])
//        XCTAssertEqual(service.receivedMessages, [.failure(error: error, route: SomeServiceRoute.prepare)])
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: ViewController, service: SomeServiceSpy)  {
        let serviceSpy = SomeServiceSpy()
        let viewController = ViewController()
        viewController.service = serviceSpy

        return (viewController, serviceSpy)
    }
}
