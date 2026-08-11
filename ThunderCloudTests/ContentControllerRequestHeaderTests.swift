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

    override func setUp() {
        super.setUp()

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

        contentController.contentRequestHeaderProvider = nil
        contentController.contentAuthFailureHandler = nil
        contentController.requestController = nil
        contentController.downloadRequestController = nil
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
