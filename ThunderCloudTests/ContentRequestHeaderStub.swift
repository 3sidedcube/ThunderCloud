//
//  ContentRequestHeaderStub.swift
//  ThunderCloudTests
//
//  Copyright © 2026 threesidedcube. All rights reserved.
//

import Foundation
import ObjectiveC

/// A `URLProtocol` which intercepts the requests made by `ContentController` so tests can inspect
/// the headers that were actually sent, and reply with canned responses.
///
/// `RequestController` builds its own `URLSession` objects internally, so registering this class with
/// `URLProtocol.registerClass(_:)` is not enough to intercept them. Instead `install()` swizzles
/// `URLSessionConfiguration.default` so every default configuration created from that point on has this
/// protocol at the front of its `protocolClasses`. It only actually intercepts anything while `isEnabled`
/// is true, so tests which don't opt in are unaffected.
///
/// - Note: Background sessions cannot use a custom `URLProtocol`, so anything under test which downloads
/// must do so with `inBackground` set to false.
class ContentRequestHeaderStub: URLProtocol {

    /// A canned response for the stub to reply with
    struct Stubbed {

        /// The HTTP status code to respond with
        let statusCode: Int

        /// The body to respond with
        let body: Data

        /// When set, the stub responds with a redirect to this url instead of a body
        let redirectTo: URL?

        init(statusCode: Int, body: Data = Data("{}".utf8), redirectTo: URL? = nil) {
            self.statusCode = statusCode
            self.body = body
            self.redirectTo = redirectTo
        }
    }

    /// Guards the static state below, which is touched from the URL loading system's threads
    private static let lock = NSLock()

    /// Whether the stub should intercept requests
    private static var _isEnabled = false

    /// The responses to reply with, in order. The last one is repeated once they have all been used
    private static var _stubbedResponses: [Stubbed] = []

    /// Every request the stub has intercepted, in the order they were made
    private static var _requests: [URLRequest] = []

    /// Called on every intercepted request, so tests can wait for a given number of requests
    private static var _onRequest: ((URLRequest) -> Void)?

    /// The requests the stub has intercepted, in the order they were made
    static var requests: [URLRequest] {
        lock.lock()
        defer { lock.unlock() }
        return _requests
    }

    /// Starts intercepting requests, replying with the given responses in order
    /// - Parameters:
    ///   - responses: The responses to reply with. The last is repeated once they have all been used
    ///   - onRequest: Called with each intercepted request
    static func start(responding responses: [Stubbed], onRequest: ((URLRequest) -> Void)? = nil) {
        install()
        lock.lock()
        _isEnabled = true
        _stubbedResponses = responses
        _requests = []
        _onRequest = onRequest
        lock.unlock()
    }

    /// Stops intercepting requests and throws away everything recorded
    static func stop() {
        lock.lock()
        _isEnabled = false
        _stubbedResponses = []
        _requests = []
        _onRequest = nil
        lock.unlock()
    }

    /// Swizzles `URLSessionConfiguration.default` so default configurations pick up this protocol.
    /// Only has an effect the first time it is called.
    private static var installed = false
    static func install() {
        lock.lock()
        defer { lock.unlock() }
        guard !installed else { return }
        installed = true

        guard let original = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default)),
              let replacement = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.thunderCloudTests_stubbedDefault)) else {
            return
        }
        method_exchangeImplementations(original, replacement)
    }

    //MARK: - URLProtocol -

    override class func canInit(with request: URLRequest) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isEnabled
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {

        ContentRequestHeaderStub.lock.lock()
        ContentRequestHeaderStub._requests.append(request)
        let stubbed: Stubbed
        if ContentRequestHeaderStub._stubbedResponses.count > 1 {
            stubbed = ContentRequestHeaderStub._stubbedResponses.removeFirst()
        } else {
            stubbed = ContentRequestHeaderStub._stubbedResponses.first ?? Stubbed(statusCode: 200)
        }
        let onRequest = ContentRequestHeaderStub._onRequest
        ContentRequestHeaderStub.lock.unlock()

        guard let url = request.url,
              let response = HTTPURLResponse(
                url: url,
                statusCode: stubbed.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: stubbed.redirectTo.map({ ["Location": $0.absoluteString] }) ?? ["Content-Type": "application/json"]
              ) else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        if let redirectTo = stubbed.redirectTo {

            // `URLSession` carries the headers of the request being redirected over to the request it
            // sends to the redirect's target, so the stub has to do the same for this to be a fair test
            var redirectedRequest = URLRequest(url: redirectTo)
            redirectedRequest.allHTTPHeaderFields = request.allHTTPHeaderFields

            client?.urlProtocol(self, wasRedirectedTo: redirectedRequest, redirectResponse: response)
            onRequest?(request)
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stubbed.body)
        client?.urlProtocolDidFinishLoading(self)

        onRequest?(request)
    }

    override func stopLoading() {

    }
}

private extension URLSessionConfiguration {

    /// Swapped with `URLSessionConfiguration.default` by `ContentRequestHeaderStub.install()`. The call
    /// to itself below resolves to the original implementation once the two have been exchanged.
    @objc(thunderCloudTests_stubbedDefault) class func thunderCloudTests_stubbedDefault() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.thunderCloudTests_stubbedDefault()
        var protocolClasses = configuration.protocolClasses ?? []
        protocolClasses.insert(ContentRequestHeaderStub.self, at: 0)
        configuration.protocolClasses = protocolClasses
        return configuration
    }
}
