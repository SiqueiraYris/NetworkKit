import Foundation

public protocol DispatchQueueProtocol {
    func async(execute work: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueProtocol {
    public func async(execute work: @escaping () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}
