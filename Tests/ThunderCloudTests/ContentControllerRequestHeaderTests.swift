//
//  ContentControllerRequestHeaderTests.swift
//  ThunderCloudTests
//
//  Copyright © 2026 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

/// Covers `ContentController.contentRequestHeaderProvider` and `ContentController.contentAuthFailureHandler`
class ContentControllerRequestHeaderTests: XCTestCase {

    private let updateURL = URL(string: "https://stub.thundercloud.test/latest/apps/1/update")!
    private let deltaURL = URL(string: "https://cdn.stub.thundercloud.test/bundles/delta.tar.gz")!
    private let bundleURL = URL(string: "https://cdn.stub.thundercloud.test/bundles/bundle.tar.gz")!

    private var contentController: ContentController {
        return ContentController.shared
    }

    private var destinationDirectory: URL!

    /// `deltaDirectory` is a property of the shared controller, so whatever it was has to be put back
    private var originalDeltaDirectory: URL?

    override func setUp() {
        super.setUp()

        originalDeltaDirectory = contentController.deltaDirectory

        // Make sure the request controllers are rebuilt against our stub base url, and after the
        // stub has swizzled `URLSessionConfiguration.default`
        ContentRequestHeaderStub.start(responding: [ContentRequestHeaderStub.Stubbed(statusCode: 200)])

        contentController.requestController = nil
        contentController.downloadRequestController = nil
        contentController.baseURL = updateURL
        contentController.configureBaseURL()

        contentController.contentRequestHeaderProvider = nil
        contentController.contentAuthFailureHandler = nil

        destinationDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("ContentControllerRequestHeaderTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {

        // `ContentController` is a singleton whose progress handlers are shared, so a request still in
        // flight when a test ends would deliver its outcome to whichever test runs next. Cancelling has
        // to happen while the provider is still set, as that is what decides which session was used.
        contentController.cancelDownloadRequest()

        // Let the cancelled requests report back before the next test registers anything of its own
        waitForQuiet()

        contentController.contentRequestHeaderProvider = nil
        contentController.contentAuthFailureHandler = nil
        contentController.requestController = nil
        contentController.downloadRequestController = nil
        contentController.backgroundDownloadCompletionHandler = nil
        contentController.deltaDirectory = originalDeltaDirectory
        originalDeltaDirectory = nil
        ContentRequestHeaderStub.stop()

        try? FileManager.default.removeItem(at: destinationDirectory)
        destinationDirectory = nil

        super.tearDown()
    }

    //MARK: - Helpers -

    /// Runs `work` and waits until the stub has intercepted `count` requests
    private func waitForRequests(_ count: Int, timeout: TimeInterval = 5, work: () -> Void) {

        let expectation = self.expectation(description: "\(count) request(s) intercepted")
        expectation.expectedFulfillmentCount = count
        expectation.assertForOverFulfill = false

        ContentRequestHeaderStub.start(responding: stubbedResponses) { _ in
            expectation.fulfill()
        }

        work()

        wait(for: [expectation], timeout: timeout)
    }

    /// The responses the next `waitForRequests(_:work:)` should reply with
    private var stubbedResponses: [ContentRequestHeaderStub.Stubbed] = [ContentRequestHeaderStub.Stubbed(statusCode: 200)]

    /// Waits a short while so any request which shouldn't have been made has a chance to arrive
    private func waitForQuiet() {
        let expectation = self.expectation(description: "settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    //MARK: - Provider headers are sent -

    func testUpdateCheckSendsProviderHeaders() {

        contentController.contentRequestHeaderProvider = { _ in
            return ["x-stub-key": "update-check-key"]
        }

        waitForRequests(1) {
            contentController.checkForUpdates(withTimestamp: 0)
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "x-stub-key"), "update-check-key")
    }

    func testDeltaDownloadSendsProviderHeaders() {

        contentController.contentRequestHeaderProvider = { _ in
            return ["x-stub-key": "delta-download-key"]
        }

        waitForRequests(1) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                progressHandler: nil
            )
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.url, deltaURL)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "x-stub-key"), "delta-download-key")
    }

    /// `downloadFullBundle(buildTimestamp:with:)` builds its url from `Storm.API`, which is read from
    /// `Bundle.main` and so is not available to this test bundle. It downloads through
    /// `downloadPackage(fromURL:destinationDirectory:...)` with `setAsInitialBundle` set, which is what
    /// this covers.
    func testFullBundleDownloadSendsProviderHeaders() {

        contentController.contentRequestHeaderProvider = { _ in
            return ["x-stub-key": "full-bundle-key"]
        }

        waitForRequests(1) {
            contentController.downloadPackage(
                fromURL: bundleURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                setAsInitialBundle: true,
                progressHandler: nil
            )
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.url, bundleURL)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "x-stub-key"), "full-bundle-key")
    }

    func testProviderIsGivenTheUrlTheRequestIsSentTo() {

        var providedURLs: [URL] = []
        contentController.contentRequestHeaderProvider = { url in
            providedURLs.append(url)
            return ["x-stub-key": "key"]
        }

        waitForRequests(1) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                progressHandler: nil
            )
        }

        XCTAssertEqual(providedURLs, [deltaURL])
    }

    func testProviderIsGivenTheUpdateCheckUrl() {

        var providedURLs: [URL] = []
        contentController.contentRequestHeaderProvider = { url in
            providedURLs.append(url)
            return ["x-stub-key": "key"]
        }

        waitForRequests(1) {
            contentController.checkForUpdates(withTimestamp: 0)
        }

        XCTAssertEqual(providedURLs.count, 1)
        XCTAssertEqual(providedURLs.first?.host, updateURL.host)
        XCTAssertEqual(ContentRequestHeaderStub.requests.first?.url?.host, updateURL.host)
    }

    //MARK: - Auth failure retries -

    func testUpdateCheckRetriesOnceOn401() {
        assertRetriesOnce(statusCode: 401) {
            contentController.checkForUpdates(withTimestamp: 0)
        }
    }

    func testUpdateCheckRetriesOnceOn403() {
        assertRetriesOnce(statusCode: 403) {
            contentController.checkForUpdates(withTimestamp: 0)
        }
    }

    func testDownloadRetriesOnceOn401() {
        assertRetriesOnce(statusCode: 401) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                progressHandler: nil
            )
        }
    }

    func testDownloadRetriesOnceOn403() {
        assertRetriesOnce(statusCode: 403) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                progressHandler: nil
            )
        }
    }

    /// Asserts that a request which comes back with `statusCode` every time causes exactly one refresh
    /// and one re-sent request, carrying the refreshed header
    private func assertRetriesOnce(statusCode: Int, work: () -> Void) {

        var refreshCount = 0
        var key = "stale-key"

        contentController.contentRequestHeaderProvider = { _ in
            return ["x-stub-key": key]
        }
        contentController.contentAuthFailureHandler = { failedStatusCode, completion in
            XCTAssertEqual(failedStatusCode, statusCode)
            refreshCount += 1
            key = "refreshed-key"
            completion(true)
        }

        // Every response is unauthorised, so a handler which looped would keep re-sending forever
        stubbedResponses = [ContentRequestHeaderStub.Stubbed(statusCode: statusCode)]

        waitForRequests(2, work: work)
        waitForQuiet()

        XCTAssertEqual(refreshCount, 1)

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "x-stub-key"), "stale-key")
        XCTAssertEqual(requests.last?.value(forHTTPHeaderField: "x-stub-key"), "refreshed-key")
    }

    func testRequestIsNotRetriedWhenHandlerDeclines() {

        var refreshCount = 0
        contentController.contentRequestHeaderProvider = { _ in
            return ["x-stub-key": "key"]
        }
        contentController.contentAuthFailureHandler = { _, completion in
            refreshCount += 1
            completion(false)
        }

        stubbedResponses = [ContentRequestHeaderStub.Stubbed(statusCode: 403)]

        waitForRequests(1) {
            contentController.checkForUpdates(withTimestamp: 0)
        }
        waitForQuiet()

        XCTAssertEqual(refreshCount, 1)
        XCTAssertEqual(ContentRequestHeaderStub.requests.count, 1)
    }

    func testHandlerIsNotCalledForOtherStatusCodes() {

        var refreshCount = 0
        contentController.contentAuthFailureHandler = { _, completion in
            refreshCount += 1
            completion(true)
        }

        stubbedResponses = [ContentRequestHeaderStub.Stubbed(statusCode: 500)]

        waitForRequests(1) {
            contentController.checkForUpdates(withTimestamp: 0)
        }
        waitForQuiet()

        XCTAssertEqual(refreshCount, 0)
        XCTAssertEqual(ContentRequestHeaderStub.requests.count, 1)
    }

    //MARK: - Redirect target scoping -

    /// The provider only vouches for the api host and the cdn, exactly as an app scoping a key to the
    /// hosts it trusts would
    private func allowlistingProvider() -> ContentController.ContentRequestHeaderProvider {
        return { url in
            let allowedHosts = ["stub.thundercloud.test", "cdn.stub.thundercloud.test"]
            guard let host = url.host, allowedHosts.contains(host) else { return [:] }
            return ["x-stub-key": "key-for-\(host)"]
        }
    }

    func testHeaderIsNotCarriedToANonAllowlistedRedirectTarget() {

        let elsewhere = URL(string: "https://elsewhere.example.test/bundle.tar.gz")!

        contentController.contentRequestHeaderProvider = allowlistingProvider()

        stubbedResponses = [
            ContentRequestHeaderStub.Stubbed(statusCode: 303, redirectTo: elsewhere),
            ContentRequestHeaderStub.Stubbed(statusCode: 200)
        ]

        waitForRequests(2) {
            contentController.checkForUpdates(withTimestamp: 0)
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 2)

        // The request to the api carries the key
        XCTAssertEqual(requests.first?.url?.host, updateURL.host)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "x-stub-key"), "key-for-stub.thundercloud.test")

        // The request the redirect sends us to does not
        XCTAssertEqual(requests.last?.url?.host, elsewhere.host)
        XCTAssertNil(requests.last?.value(forHTTPHeaderField: "x-stub-key"))
    }

    func testHeaderIsCarriedToAnAllowlistedRedirectTarget() {

        let cdn = URL(string: "https://cdn.stub.thundercloud.test/bundle.tar.gz")!

        contentController.contentRequestHeaderProvider = allowlistingProvider()

        stubbedResponses = [
            ContentRequestHeaderStub.Stubbed(statusCode: 303, redirectTo: cdn),
            ContentRequestHeaderStub.Stubbed(statusCode: 200)
        ]

        waitForRequests(2) {
            contentController.checkForUpdates(withTimestamp: 0)
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 2)

        XCTAssertEqual(requests.last?.url?.host, cdn.host)
        XCTAssertEqual(requests.last?.value(forHTTPHeaderField: "x-stub-key"), "key-for-cdn.stub.thundercloud.test")
    }

    func testDownloadHeaderIsNotCarriedToANonAllowlistedRedirectTarget() {

        let elsewhere = URL(string: "https://elsewhere.example.test/bundle.tar.gz")!

        contentController.contentRequestHeaderProvider = allowlistingProvider()

        stubbedResponses = [
            ContentRequestHeaderStub.Stubbed(statusCode: 303, redirectTo: elsewhere),
            ContentRequestHeaderStub.Stubbed(statusCode: 200)
        ]

        waitForRequests(2) {
            contentController.downloadPackage(
                fromURL: bundleURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                progressHandler: nil
            )
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "x-stub-key"), "key-for-cdn.stub.thundercloud.test")
        XCTAssertEqual(requests.last?.url?.host, elsewhere.host)
        XCTAssertNil(requests.last?.value(forHTTPHeaderField: "x-stub-key"))
    }

    //MARK: - Redirect scoping on background downloads -

    /// A background `URLSession` task follows redirects itself and never calls
    /// `willPerformHTTPRedirection`, so the live re-scoping cannot protect it. `downloadPackage` defaults
    /// to `inBackground: true` and every caller inside `ContentController` takes that default, so this is
    /// the path the seam exists for. The chain has to be walked on the default session first, which is
    /// what the stub sees here, and the header must not reach a host the provider doesn't vouch for.
    func testBackgroundDownloadDoesNotCarryTheHeaderToANonGrantedRedirectTarget() {

        let elsewhere = URL(string: "https://elsewhere.example.test/bundle.tar.gz")!

        contentController.contentRequestHeaderProvider = allowlistingProvider()

        stubbedResponses = [
            ContentRequestHeaderStub.Stubbed(statusCode: 303, redirectTo: elsewhere),
            ContentRequestHeaderStub.Stubbed(statusCode: 200)
        ]

        waitForRequests(2) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: true,
                progressHandler: nil
            )
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 2)

        XCTAssertEqual(requests.first?.url, deltaURL)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "x-stub-key"), "key-for-cdn.stub.thundercloud.test")

        XCTAssertEqual(requests.last?.url?.host, elsewhere.host)
        XCTAssertNil(requests.last?.value(forHTTPHeaderField: "x-stub-key"))
    }

    func testBackgroundDownloadKeepsTheHeaderWhenTheChainEndsOnAGrantedHost() {

        let otherGrantedHost = URL(string: "https://stub.thundercloud.test/bundle.tar.gz")!

        contentController.contentRequestHeaderProvider = allowlistingProvider()

        stubbedResponses = [
            ContentRequestHeaderStub.Stubbed(statusCode: 303, redirectTo: otherGrantedHost),
            ContentRequestHeaderStub.Stubbed(statusCode: 200)
        ]

        waitForRequests(2) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: true,
                progressHandler: nil
            )
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 2)

        XCTAssertEqual(requests.last?.url?.host, otherGrantedHost.host)
        XCTAssertEqual(requests.last?.value(forHTTPHeaderField: "x-stub-key"), "key-for-stub.thundercloud.test")
    }

    /// A chain longer than the session is willing to walk has to fail the download rather than let it
    /// start against a url that was never resolved
    func testBackgroundDownloadFailsWhenTheRedirectChainIsTooLong() {

        contentController.contentRequestHeaderProvider = allowlistingProvider()

        // One hop more than the session will follow, each to its own url, then somewhere real. The chain
        // is finite so a session which ignored its limit would finish rather than hang.
        let hops = (0...ContentRequestSession.maximumRedirects).map { (hop) in
            ContentRequestHeaderStub.Stubbed(
                statusCode: 303,
                redirectTo: URL(string: "https://cdn.stub.thundercloud.test/hop-\(hop).tar.gz")!
            )
        }
        ContentRequestHeaderStub.start(responding: hops + [ContentRequestHeaderStub.Stubbed(statusCode: 200)])

        var reportedError: Error?
        let failed = expectation(description: "download failed")

        contentController.downloadPackage(
            fromURL: deltaURL,
            destinationDirectory: destinationDirectory,
            inBackground: true
        ) { (_, _, _, error) in
            guard reportedError == nil, let error = error else { return }
            reportedError = error
            failed.fulfill()
        }

        wait(for: [failed], timeout: 10)

        XCTAssertEqual(reportedError as? ContentRequestSession.RedirectResolutionError, .tooManyRedirects)
        XCTAssertEqual(ContentRequestHeaderStub.requests.count, ContentRequestSession.maximumRedirects + 1)
    }

    //MARK: - Background session events after relaunch -

    /// After a relaunch the system hands background download events over by session identifier. Events
    /// for the content request session's own identifier must be recognised here rather than falling
    /// through to `BackgroundRequestController`, which would bind a second `URLSession` to an identifier
    /// that is already ours. Apple treats never calling the system's completion handler as a background
    /// transfer violation, so it has to be called even when there is nothing left that can handle the
    /// events, which is what a relaunch with no header provider set looks like.
    func testBackgroundEventsForTheContentRequestSessionAreNotRoutedToTheRequestController() {

        contentController.deltaDirectory = destinationDirectory
        contentController.contentRequestHeaderProvider = nil

        var completionHandlerCalled = false
        contentController.handleEventsForBackgroundURLSession(session: ContentRequestSession.backgroundSessionIdentifier) {
            completionHandlerCalled = true
        }

        XCTAssertTrue(completionHandlerCalled, "The system's background completion handler must not be left uncalled")
        XCTAssertNil(contentController.backgroundRequestController, "A second session must not be bound to the content request session's identifier")
    }

    //MARK: - Status codes -

    /// `HTTP.StatusCode` has gaps in the 4xx range — AWS ALB returns 460 — and `RequestController`
    /// treats a code it has no case for as an error. The session which replaces it on the provider path
    /// has to do the same, rather than handing the error body on as though it were a bundle.
    func testUnmappedErrorStatusCodeFailsTheDownload() {

        contentController.contentRequestHeaderProvider = { _ in
            return ["x-stub-key": "key"]
        }

        stubbedResponses = [ContentRequestHeaderStub.Stubbed(statusCode: 460)]

        var reportedStage: UpdateStage?
        var reportedError: Error?
        let failed = expectation(description: "download reported an error")

        waitForRequests(1) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: false
            ) { (stage, _, _, error) in
                guard reportedError == nil, let error = error else { return }
                reportedStage = stage
                reportedError = error
                failed.fulfill()
            }
        }

        wait(for: [failed], timeout: 5)

        XCTAssertEqual(reportedStage, .downloading)
        XCTAssertEqual(reportedError as? ContentControllerError, .invalidResponse)
    }

    //MARK: - Downloaded file lifetime -

    /// `ContentRequestSession` has to move a download out of the location `URLSession` gives it before
    /// that is deleted, so the copy it makes is its own to clean up once whoever it handed it to has had
    /// the chance to copy it somewhere else. Without that every download leaves a bundle-sized file
    /// behind in the app's temporary directory.
    func testDownloadedFileIsRemovedOnceTheCompletionHasReturned() {

        let session = ContentRequestSession(headerProvider: { _ in [:] })

        var downloadedFileURL: URL?
        var existedWhenHandedOver = false

        let finished = expectation(description: "download finished")

        ContentRequestHeaderStub.start(responding: [ContentRequestHeaderStub.Stubbed(statusCode: 200)])

        session.download(from: deltaURL, inBackground: false, progress: nil) { (fileURL, _, _) in
            downloadedFileURL = fileURL
            existedWhenHandedOver = fileURL.map({ FileManager.default.fileExists(atPath: $0.path) }) ?? false
            finished.fulfill()
        }

        wait(for: [finished], timeout: 5)

        XCTAssertTrue(existedWhenHandedOver, "The completion should be handed a file it can still copy")

        // The clean up happens once the completion has returned, so wait for the operation it runs in
        // to finish before checking
        let cleanedUp = expectation(description: "clean up ran")
        OperationQueue.main.addOperation {
            cleanedUp.fulfill()
        }
        wait(for: [cleanedUp], timeout: 5)

        guard let downloadedFileURL = downloadedFileURL else {
            return XCTFail("No file url was handed to the completion")
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: downloadedFileURL.path))
    }

    //MARK: - Nil hooks change nothing -

    func testNoHeadersAreAddedWithoutAProvider() {

        waitForRequests(1) {
            contentController.checkForUpdates(withTimestamp: 0)
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertNil(requests.first?.value(forHTTPHeaderField: "x-stub-key"))
    }

    func testNoHeadersAreAddedWhenProviderReturnsNothing() {

        contentController.contentRequestHeaderProvider = { _ in
            return [:]
        }

        waitForRequests(1) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                progressHandler: nil
            )
        }

        let requests = ContentRequestHeaderStub.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertNil(requests.first?.value(forHTTPHeaderField: "x-stub-key"))
    }

    func testUnauthorisedResponseIsNotRetriedWithoutAHandler() {

        stubbedResponses = [ContentRequestHeaderStub.Stubbed(statusCode: 401)]

        waitForRequests(1) {
            contentController.checkForUpdates(withTimestamp: 0)
        }
        waitForQuiet()

        XCTAssertEqual(ContentRequestHeaderStub.requests.count, 1)
    }

    func testUnauthorisedDownloadIsNotRetriedWithoutAHandler() {

        stubbedResponses = [ContentRequestHeaderStub.Stubbed(statusCode: 403)]

        waitForRequests(1) {
            contentController.downloadPackage(
                fromURL: deltaURL,
                destinationDirectory: destinationDirectory,
                inBackground: false,
                progressHandler: nil
            )
        }
        waitForQuiet()

        XCTAssertEqual(ContentRequestHeaderStub.requests.count, 1)
    }
}
