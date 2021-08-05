import Foundation

public final class NetworkManager {
    private let session: URLSessionProtocol
    private var queue: DispatchQueue
    private let decoder: JSONDecoderProtocol

    public init(queue: DispatchQueue = DispatchQueue.main,
                networkServiceType: NSURLRequest.NetworkServiceType = .responsiveData,
                session: URLSessionProtocol = URLSession(configuration: .default),
                decoder: JSONDecoderProtocol = JSONDecoder()) {
        self.session = session
        self.session.configuration.networkServiceType = networkServiceType
        self.queue = queue
        self.decoder = decoder
    }

    private func validateStatusCode(with code: Int) throws {
        switch code {
        case 200...299:
            break

        case 400:
            throw NetworkErrors.HTTPErrors.badRequest

        case 401:
            throw NetworkErrors.HTTPErrors.unauthorized

        case 403:
            throw NetworkErrors.HTTPErrors.forbidden

        case 404:
            throw NetworkErrors.HTTPErrors.notFound

        case 408:
            throw NetworkErrors.HTTPErrors.timeOut

        case 500:
            throw NetworkErrors.HTTPErrors.internalServerError

        default:
            throw NetworkErrors.decoderFailure
        }
    }
}

extension NetworkManager: NetworkManagerProtocol {
    public func request<T: Decodable, H: Decodable>(with config: RequestConfigProtocol,
                                                    completion: @escaping (Result<(object: T, header: H?), ErrorHandler>) -> Void) {
        networkRequest(with: config, completion: completion)
    }

    private func networkRequest<T: Decodable, H: Decodable>(with config: RequestConfigProtocol, completion: @escaping (Result<(object: T, header: H?), ErrorHandler>) -> Void) {
        guard let urlRequest = config.createUrlRequest() else {
            completion(.failure(ErrorHandler(defaultError: NetworkErrors.malformedUrl)))
            return
        }

        var objectHeader: H?

        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            self.queue.async {
                do {
                    if let error = error {
                        try self.checkErrorCodeWith(error)
                    } else if let response = response as? HTTPURLResponse {
                        try self.validateStatusCode(with: response.statusCode)

                        objectHeader = try? self.decodeHeaderWith(object: H.self, data: response.allHeaderFields)

                        guard let data = data else {
                            throw NetworkErrors.noData
                        }

                        if let dateDecodingStrategy = config.dateDecodeStrategy {
                            self.decoder.dateDecodingStrategy = dateDecodingStrategy
                        }

                        let object = try self.decoder.decode(T.self, from: data.value)
                        self.checkPrintDebugData(title: "Decoding",
                                                 debug: config.debugMode,
                                                 url: urlRequest.url?.absoluteString,
                                                 data: data,
                                                 curl: urlRequest.curlString)
                        completion(.success((object: object, header: objectHeader)))
                    } else {
                        throw NetworkErrors.unknownFailure
                    }
                } catch let error as NetworkErrors {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: error, config: config, completion: completion)
                } catch let error as NetworkErrors.HTTPErrors {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: error, config: config, completion: completion)
                } catch is DecodingError {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: NetworkErrors.decoderFailure, config: config, completion: completion)
                } catch {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: NetworkErrors.unknownFailure, config: config, completion: completion)
                }
            }
        }

        task.resume()
    }

    private func decodeHeaderWith<H: Decodable>(object: H.Type, data: [AnyHashable: Any]) throws -> H? {
        return try? self.decoder.decode(H.self, from: JSONSerialization.data(withJSONObject: data))
    }
}

extension NetworkManager {
    private func checkPrintDebugData(title: String, debug: Bool, url: String?, data: Data?, curl: String?) {
        if debug {
            printDebugData(title: title, url: url, data: data, curl: curl)
        }
    }

    private func checkErrorCodeWith(_ error: Error) throws {
        switch error._code {
        case NetworkErrors.connectionLost.code:
            throw NetworkErrors.connectionLost

        case NetworkErrors.notConnected.code:
            throw NetworkErrors.notConnected

        default:
            throw NetworkErrors.requestFailure
        }
    }

    private func genericCatchError<T, R>(urlRequest: URLRequest,
                                         data: Data?, error: R,
                                         config: RequestConfigProtocol,
                                         completion: @escaping (Result<T, ErrorHandler>) -> Void) where R: NetworkErrorsProtocol {
        if config.debugMode {
            printDebugData(title: String(describing: R.self),
                           url: urlRequest.url?.absoluteString,
                           data: data,
                           curl: urlRequest.curlString)
        }
        completion(.failure(ErrorHandler(statusCode: error.code,
                                         data: data,
                                         defaultError: error)))
    }
}

/// With this code you can get curl and put this code in postman to test
extension NetworkManager {
    func printDebugData(title: String, url: String?, data: Data?, curl: String?) {
        print("---------------------------------------------------------------")
        print("🔬 - DEBUG MODE ON FOR: \(title) - 🔬")
        print("📡 URL: \(url ?? "No URL passaed")")
        print(data?.toString() ?? "No Data passed")
        print(curl ?? "No curl command passed")
        print("---------------------------------------------------------------")
    }
}
