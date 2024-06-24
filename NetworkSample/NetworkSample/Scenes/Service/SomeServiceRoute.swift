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
        let config = RequestConfig(scheme: "https",
                                   host: "mocki.io",
                                   path: "/v1/3699ab5c-a693-4bb5-87bc-6de218bdca12",
                                   port: nil,
                                   method: .get,
                                   debugMode: true) /// The default is false, but when enabled shows the curl text in console

        return RequestConfigHeadersDecorator(config).config /// The decorator is optional, use it when it's necessary to add some header
    }
}
