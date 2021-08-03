import Foundation

public struct ErrorHandler: LocalizedError, Equatable {
    var message: String
    public var errorCode: String?
    public var code: Int?
    public var errorDescription: String? {
        return message
    }
    private static let defaultErrorMessage = "ERROR"

    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: Error) {
        self.code = statusCode
        self.message = defaultError.localizedDescription

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.localizedDescription
        }
    }

    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: NetworkErrors.HTTPErrors = .badRequest) {
        self.code = statusCode
        self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage
        }
    }

    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: NetworkErrors = .decoderFailure) {
        self.code = statusCode
        self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage
        }
    }

    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: NetworkErrorsProtocol = NetworkErrors.decoderFailure) {
        self.code = statusCode
        self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage
        }
    }

    public init(statusCode: Int? = nil, message: String) {
        self.code = statusCode
        self.message = message
    }
}
