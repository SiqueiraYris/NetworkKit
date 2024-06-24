import Foundation

public protocol RequestConfigProtocol {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var port: Int? { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any] { get set }
    var headers: [String: String] { get }
    var parametersEncoding: ParameterEncoding { get }
    var headerInterceptor: NetworkHeaderInterceptor? { get set }
    var debugMode: Bool { get }
}

extension RequestConfigProtocol {
    func createUrlRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.port = port

        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "\(method)"

        var httpBody: Data?

        if parameters.isEmpty == false {
            switch parametersEncoding {
            case .url:
                urlComponents.setQueryItems(with: parameters)
                request.url = urlComponents.url
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

            case .body:
                httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        if let body = httpBody {
            request.httpBody = body
        }

        request.allHTTPHeaderFields = headers

        return request
    }
}
