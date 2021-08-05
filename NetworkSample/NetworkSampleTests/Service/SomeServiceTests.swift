import XCTest
import NetworkKit
@testable import NetworkSample

class SomeServiceTests: XCTestCase {
    
    func test_request_shouldReceiveSuccess() {
        let (sut, manager) = makeSUT()
        let response = SomeResponse.fixture()
        let result: SomeResult = .success(response)
        
        sut.request(SomeServiceRoute.prepare) { _ in }
        manager.completeWithSuccess(result: result)
        
        XCTAssertEqual(manager.receivedMessages, [.request(result: result)])
    }
    
    func test_request_shouldReceiveFailure() {
        let (sut, manager) = makeSUT()
        let error = ErrorHandler.fixture()
        let result: SomeResult = .failure(error)
        
        sut.request(SomeServiceRoute.prepare) { _ in }
        manager.completeWithError(error: error)
        
        XCTAssertEqual(manager.receivedMessages, [.request(result: result)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: SomeService,
                               networkManager: NetworkManagerSpy) {
        let spy = NetworkManagerSpy()
        let sut = SomeService(networking: spy)
        
        return (sut, spy)
    }
}
