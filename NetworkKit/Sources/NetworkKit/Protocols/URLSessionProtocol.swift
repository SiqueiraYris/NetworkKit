import Foundation

public protocol URLSessionProtocol: AnyObject {
    var configuration: URLSessionConfiguration { get }
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
