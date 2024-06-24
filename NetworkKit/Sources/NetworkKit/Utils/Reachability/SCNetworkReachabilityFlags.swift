import SystemConfiguration

extension SCNetworkReachabilityFlags {
    typealias Connection = Reachability.Connection

    var connection: Connection {
        guard isReachableFlagSet else { return .none }

        /// If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        #if targetEnvironment(simulator)
            return .wifi
        #else
            var connection = Connection.none

            if !isConnectionRequiredFlagSet {
                connection = .wifi
            }

            if isConnectionOnTrafficOrDemandFlagSet {
                if !isInterventionRequiredFlagSet {
                    connection = .wifi
                }
            }

            if isOnWWANFlagSet {
                connection = .cellular
            }

            return connection
        #endif
    }

    var isOnWWANFlagSet: Bool {
        #if os(iOS)
            return contains(.isWWAN)
        #else
            return false
        #endif
    }

    var isReachableFlagSet: Bool {
        return contains(.reachable)
    }

    var isConnectionRequiredFlagSet: Bool {
        return contains(.connectionRequired)
    }

    var isInterventionRequiredFlagSet: Bool {
        return contains(.interventionRequired)
    }

    var isConnectionOnTrafficFlagSet: Bool {
        return contains(.connectionOnTraffic)
    }

    var isConnectionOnDemandFlagSet: Bool {
        return contains(.connectionOnDemand)
    }

    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }

    var isTransientConnectionFlagSet: Bool {
        return contains(.transientConnection)
    }

    var isLocalAddressFlagSet: Bool {
        return contains(.isLocalAddress)
    }

    var isDirectFlagSet: Bool {
        return contains(.isDirect)
    }

    var isConnectionRequiredAndTransientFlagSet: Bool {
        return intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }
}
