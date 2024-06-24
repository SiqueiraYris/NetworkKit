import Foundation
import CommonCrypto

public final class NetworkPinner: NSObject, URLSessionDelegate {
    static let publicHashKeys = [
        "yVRkHI8k2D9F3twDkoU5/Tu8NVp4kxtZxRfqdnbnTnc="
    ]

    private let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition,
                                                         URLCredential?) -> Void) {
        if SecurityEnabler.isSecurityEnabled {
            guard let serverTrust = challenge.protectionSpace.serverTrust,
                  let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
                  let serverPublicKey = SecCertificateCopyKey(certificate),
                  let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            let data = serverPublicKeyData as Data

            pinCertificate(serverTrust: serverTrust, data: data) { disposition, credential in
                completionHandler(disposition, credential)
            }
        }

        completionHandler(.performDefaultHandling, nil)
        return
    }

    private func sha256(data: Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }

    private func pinCertificate(serverTrust: SecTrust,
                                data: Data,
                                completionHandler: @escaping (URLSession.AuthChallengeDisposition,
                                                              URLCredential?) -> Void) {
        let serverHashKey = sha256(data: data)
        let publicKeysLocal = type(of: self).publicHashKeys

        var hasPinnedSuccessfully = false

        publicKeysLocal.forEach { key in
            if serverHashKey == key {
                hasPinnedSuccessfully = true
            }
        }

        if hasPinnedSuccessfully {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
