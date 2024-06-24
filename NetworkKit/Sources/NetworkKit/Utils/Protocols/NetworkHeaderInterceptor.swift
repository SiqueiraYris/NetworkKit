public protocol NetworkHeaderInterceptor {
    func intercept(headers: [AnyHashable: Any])
}
