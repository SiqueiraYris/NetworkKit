import NetworkKit

enum SomeServiceRoute: NetworkRouteProtocol {
    case prepare

    var config: RequestConfigProtocol {
        switch self {
        case .prepare:
            return configureRequest()
        }
    }

    private func configureRequest() -> RequestConfigProtocol {
        return RequestConfig(host: "aquele-mock.herokuapp.com",
                             path: "/some-data",
                             method: .get,
                             debugMode: true) /// The default is false, but when enabled shows the curl text in console
    }
}
