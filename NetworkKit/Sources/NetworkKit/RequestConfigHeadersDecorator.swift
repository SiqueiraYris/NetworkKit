import Foundation

public final class RequestConfigHeadersDecorator {
    private var instance: RequestConfig
//    private let userManager: UserManagerProtocol

    // MARK: - Initialization

    public init(_ instance: RequestConfig/*, userManager: UserManagerProtocol = UserManager()*/) {
        self.instance = instance
//        self.userManager = userManager
    }
}

extension RequestConfigHeadersDecorator: NetworkRouteProtocol {
    public var config: RequestConfigProtocol {
//        if let jwt = userManager.retrieveJWT() {
            instance.headers["header"] = "some-header" /// you can add jwt for example
//        }

        return instance
    }
}
