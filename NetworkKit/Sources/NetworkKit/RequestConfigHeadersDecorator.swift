public final class RequestConfigHeadersDecorator {
    private var instance: RequestConfig

    // MARK: - Initialization

    public init(_ instance: RequestConfig) {
        self.instance = instance
    }
}

extension RequestConfigHeadersDecorator: NetworkRouteProtocol {
    public var config: RequestConfigProtocol {
        instance.headers["header"] = "some-header" /// you can add some JWT for example
        return instance
    }
}
