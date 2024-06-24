import SystemConfiguration
import Foundation

public protocol ReachabilityProtocol {
    var allowsCellularConnection: Bool { get set }
    var connection: Reachability.Connection { get }
}

public extension Notification.Name {
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
}

public final class Reachability: ReachabilityProtocol {
    typealias NetworkReachable = (Reachability) -> ()
    typealias NetworkUnreachable = (Reachability) -> ()

    public enum Connection: CustomStringConvertible {
        case none, wifi, cellular
        public var description: String {
            switch self {
            case .cellular: return "Cellular"
            case .wifi: return "WiFi"
            case .none: return "No Connection"
            }
        }
    }

    public var allowsCellularConnection: Bool = true
    public var notificationCenter: NotificationCenter = NotificationCenter.default

    public var connection: Connection {
        if flags == nil {
            try? setReachabilityFlags()
        }

        switch flags?.connection {
        case .none?, nil:
            return .none
        case .cellular?:
            return allowsCellularConnection ? .cellular : .none
        case .wifi?:
            return .wifi
        }
    }

    private var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
            return false
        #else
            return true
        #endif
    }()

    private var description: String {
        guard let flags = flags else { return "unavailable flags" }
        let W = isRunningOnDevice ? (flags.isOnWWANFlagSet ? "W" : "-") : "X"
        let R = flags.isReachableFlagSet ? "R" : "-"
        let c = flags.isConnectionRequiredFlagSet ? "c" : "-"
        let t = flags.isTransientConnectionFlagSet ? "t" : "-"
        let i = flags.isInterventionRequiredFlagSet ? "i" : "-"
        let C = flags.isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = flags.isConnectionOnDemandFlagSet ? "D" : "-"
        let l = flags.isLocalAddressFlagSet ? "l" : "-"
        let d = flags.isDirectFlagSet ? "d" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }

    private var whenReachable: NetworkReachable?
    private var whenUnreachable: NetworkUnreachable?
    private var notifierRunning = false
    private let reachabilityRef: SCNetworkReachability?
    private let reachabilitySerialQueue: DispatchQueue
    private(set) var flags: SCNetworkReachabilityFlags? {
        didSet {
            guard flags != oldValue else { return }
            reachabilityChanged()
        }
    }

    public init(queueQoS: DispatchQoS = .default, targetQueue: DispatchQueue? = nil) {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)

        reachabilityRef = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress)
        reachabilitySerialQueue = DispatchQueue(
            label: "reachability",
            qos: queueQoS,
            target: targetQueue
        )
        try? startNotifier()
    }

    deinit {
        stopNotifier()
    }

    private func startNotifier() throws {
        guard !notifierRunning, let reachabilityReference = reachabilityRef else { return }

        let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
            guard let info = info else { return }

            let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
            reachability.flags = flags
        }

        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        if !SCNetworkReachabilitySetCallback(reachabilityReference, callback, &context) {
            stopNotifier()
            throw ReachabilityError.UnableToSetCallback
        }

        if !SCNetworkReachabilitySetDispatchQueue(reachabilityReference, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.UnableToSetDispatchQueue
        }

        try setReachabilityFlags()

        notifierRunning = true
    }

    private func stopNotifier() {
        defer { notifierRunning = false }
        guard let reachabilityReference = reachabilityRef else { return }

        SCNetworkReachabilitySetCallback(reachabilityReference, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityReference, nil)
    }

    private func setReachabilityFlags() throws {
        try reachabilitySerialQueue.sync { [weak self] in
            guard let self = self, let reachabilityReference = reachabilityRef else { return }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(reachabilityReference, &flags) {
                self.stopNotifier()
                throw ReachabilityError.UnableToGetInitialFlags
            }

            self.flags = flags
        }
    }

    private func reachabilityChanged() {
        let block = connection != .none ? whenReachable : whenUnreachable

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            block?(self)
            self.notificationCenter.post(name: .reachabilityChanged, object: self)
        }
    }
}
