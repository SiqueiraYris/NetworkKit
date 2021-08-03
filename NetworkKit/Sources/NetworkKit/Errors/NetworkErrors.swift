import Foundation

public enum NetworkErrors: NSInteger, LocalizedError, NetworkErrorsProtocol {
    case decoderFailure = -1001
    case malformedUrl = -1002
    case noData = -1003
    case requestFailure = -1004
    case connectionLost = -1005
    case unknownFailure = -1006
    case notConnected = -1009

    public var code: Int {
        return rawValue
    }

    public var errorDescription: String? {
        switch self {
        case .connectionLost:
            return "Houve perda de conexão. Caso você tenha feito alguma transação, consulte o extrato para saber se ela foi concluída. Caso contrário, tente novamente mais tarde."

        case .decoderFailure, .requestFailure:
            return "Desculpe, algo deu errado. Tente novamente ou entre em contato com nossa equipe de ajuda."

        case .noData, .unknownFailure:
            return "Ocorreu um erro desconhecido"

        case .malformedUrl:
            return "O serviço solicitado não está disponível."

        case .notConnected:
            return "Por favor, verifique sua conexão!"
        }
    }

    public enum HTTPErrors: Int, LocalizedError, NetworkErrorsProtocol {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case timeOut = 408
        case internalServerError = 500
        public var code: Int {
            return rawValue
        }

        public var errorDescription: String? {
            switch self {
            case .unauthorized, .badRequest:
                return "Serviço solicitado incorreto."

            case .notFound:
                return "Serviço solicitado não pode ser encontrado."

            case .internalServerError:
                return "Serviço solicitado encontrou uma condição inesperada."

            case .timeOut:
                return "Serviço solicitado não recebeu resposta."

            case .forbidden:
                return "Serviço solicitado foi recusado."
            }
        }
    }
}
