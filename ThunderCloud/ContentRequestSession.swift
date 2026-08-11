//
//  ContentRequestSession.swift
//  ThunderCloud
//
//  Copyright © 2026 threesidedcube. All rights reserved.
//

import Foundation
import os.log

/// Performs the requests `ContentController` makes for content, re-applying the app's header provider
/// on every redirect.
///
/// `URLSession` copies a request's headers onto the request it sends to a redirect's target, including
/// when that target is on a different host. A content request can be redirected off the Storm API onto
/// whichever host serves the bundle, so a header the app only meant for one host would otherwise be
/// sent on to another. Before each redirect is followed this asks the provider what should be sent to
/// the new url and removes anything it does not return for it.
///
/// This is only used when an app has set `ContentController.contentRequestHeaderProvider`. Without a
/// provider `ContentController` makes its requests exactly as it always has.
class ContentRequestSession: NSObject {

    /// Asked what headers should be sent to a given url
    typealias HeaderProvider = (URL) -> [String: String]

    /// Called when a request for data has finished
    typealias DataCompletion = (Data?, HTTPURLResponse?, Error?) -> Void

    /// Called when a download has finished, with the url the downloaded file was moved to
    typealias DownloadCompletion = (URL?, HTTPURLResponse?, Error?) -> Void

    /// Called as a download progresses
    typealias DownloadProgressHandler = (_ totalBytesWritten: Int64, _ totalBytesExpected: Int64) -> Void

    /// The identifier used for the background session, so `ContentController` can recognise events
    /// delivered for it after the app has been relaunched
    static let backgroundSessionIdentifier = "com.threesidedcube.ThunderCloud.ContentRequestSession"

    /// Identifies one of this class's tasks
    ///
    /// A task identifier is only unique within the `URLSession` which vended it, and this class has both
    /// a default and a background session, each numbering its own tasks from 1. Keying per-task state on
    /// the identifier alone would let a task on one session pick up the state of a task on the other.
    private struct TaskKey: Hashable {

        let session: ObjectIdentifier

        let taskIdentifier: Int

        init(session: URLSession, taskIdentifier: Int) {
            self.session = ObjectIdentifier(session)
            self.taskIdentifier = taskIdentifier
        }

        init(session: URLSession, task: URLSessionTask) {
            self.init(session: session, taskIdentifier: task.taskIdentifier)
        }
    }

    private let headerProvider: HeaderProvider

    private static let logCategory = "ContentRequestSession"

    private let log = OSLog(subsystem: "com.threesidedcube.ThunderCloud", category: ContentRequestSession.logCategory)

    /// Serialises access to the per-task state below, and is the queue the session's delegate is called on
    private let delegateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    /// The header names the provider returned for the url each task was last sent to, so they can be
    /// removed again if the provider doesn't return them for a redirect's target
    private var appliedHeaderNames: [TaskKey: Set<String>] = [:]

    private var dataCompletions: [TaskKey: DataCompletion] = [:]

    private var receivedData: [TaskKey: Data] = [:]

    private var downloadCompletions: [TaskKey: DownloadCompletion] = [:]

    private var downloadProgressHandlers: [TaskKey: DownloadProgressHandler] = [:]

    /// The url each download task's file was moved to, captured before `URLSession` deletes it
    private var downloadedFileURLs: [TaskKey: URL] = [:]

    /// Called for a download which finishes with no completion registered for it, which is what a
    /// download that finished while the app was not running looks like once the app has been relaunched
    /// to handle the background session's events
    var unhandledDownloadHandler: DownloadCompletion?

    /// Called once the background session has handed over every event it had queued up for us
    var backgroundEventsFinishedHandler: (() -> Void)?

    init(headerProvider: @escaping HeaderProvider) {
        self.headerProvider = headerProvider
        super.init()
    }

    private lazy var defaultSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
    }()

    private lazy var backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: ContentRequestSession.backgroundSessionIdentifier)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }()

    /// Creates the background `URLSession` if it doesn't exist yet, so it binds to
    /// `backgroundSessionIdentifier` and the system hands over the events queued against that identifier
    ///
    /// Holding a `ContentRequestSession` is not enough on its own, the `URLSession` itself has to exist.
    func resumeBackgroundSession() {
        _ = backgroundSession
    }

    /// Calls `invalidateAndCancel` on the underlying sessions so self can be deallocated
    func invalidateAndCancel() {
        defaultSession.invalidateAndCancel()
        backgroundSession.invalidateAndCancel()
    }

    /// Cancels any requests in flight
    func cancelAllRequests() {
        defaultSession.getAllTasks { tasks in
            tasks.forEach({ $0.cancel() })
        }
        backgroundSession.getAllTasks { tasks in
            tasks.forEach({ $0.cancel() })
        }
    }

    //MARK: - Making requests -

    /// Builds a request for the given url, with the headers the provider returns for it
    private func request(for url: URL, additionalHeaders: [String: String]) -> (request: URLRequest, providedHeaderNames: Set<String>) {

        var request = URLRequest(url: url)
        additionalHeaders.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let providedHeaders = headerProvider(url)
        providedHeaders.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return (request, Set(providedHeaders.keys))
    }

    /// Requests the data at the given url
    /// - Parameters:
    ///   - url: The url to request
    ///   - additionalHeaders: Headers to send which don't come from the provider, such as the user agent
    ///   - completion: Called on the main queue once the request has finished
    func data(from url: URL, additionalHeaders: [String: String] = [:], completion: @escaping DataCompletion) {

        let (urlRequest, providedHeaderNames) = request(for: url, additionalHeaders: additionalHeaders)
        let session = defaultSession
        let task = session.dataTask(with: urlRequest)
        let key = TaskKey(session: session, task: task)

        delegateQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.appliedHeaderNames[key] = providedHeaderNames
            self.dataCompletions[key] = completion
        }

        task.resume()
    }

    /// Downloads the file at the given url
    /// - Parameters:
    ///   - url: The url to download from
    ///   - additionalHeaders: Headers to send which don't come from the provider, such as the user agent
    ///   - inBackground: Whether the download should be made on the background session
    ///   - progress: Called as the download progresses
    ///   - completion: Called on the main queue once the download has finished
    func download(from url: URL, additionalHeaders: [String: String] = [:], inBackground: Bool, progress: DownloadProgressHandler?, completion: @escaping DownloadCompletion) {

        let (urlRequest, providedHeaderNames) = request(for: url, additionalHeaders: additionalHeaders)
        let session = inBackground ? backgroundSession : defaultSession
        let task = session.downloadTask(with: urlRequest)
        let key = TaskKey(session: session, task: task)

        delegateQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.appliedHeaderNames[key] = providedHeaderNames
            self.downloadCompletions[key] = completion
            self.downloadProgressHandlers[key] = progress
        }

        task.resume()
    }

    //MARK: - Redirects -

    /// Returns the request that should be sent to a redirect's target, with any header the provider
    /// doesn't return for the target's url removed
    ///
    /// - Parameters:
    ///   - proposedRequest: The request `URLSession` proposes to send, which still carries the headers
    ///   that were sent to the previous url
    ///   - key: Identifies the task being redirected
    /// - Returns: The request to follow the redirect with
    private func redirectRequest(from proposedRequest: URLRequest, key: TaskKey) -> URLRequest {

        var request = proposedRequest

        guard let url = request.url else { return request }

        let headersForNewURL = headerProvider(url)
        let previouslyApplied = appliedHeaderNames[key] ?? []

        // Anything the provider gave us for the previous url but doesn't give us for this one must not
        // be carried over
        previouslyApplied.subtracting(headersForNewURL.keys).forEach { (header) in
            request.setValue(nil, forHTTPHeaderField: header)
        }

        headersForNewURL.forEach { (header, value) in
            request.setValue(value, forHTTPHeaderField: header)
        }

        appliedHeaderNames[key] = Set(headersForNewURL.keys)

        return request
    }

    //MARK: - Completion -

    private func finish(key: TaskKey, isDownload: Bool, response: HTTPURLResponse?, error: Error?) {

        let dataCompletion = dataCompletions[key]
        let downloadCompletion = downloadCompletions[key]
        let data = receivedData[key]
        let fileURL = downloadedFileURLs[key]

        appliedHeaderNames[key] = nil
        dataCompletions[key] = nil
        downloadCompletions[key] = nil
        downloadProgressHandlers[key] = nil
        receivedData[key] = nil
        downloadedFileURLs[key] = nil

        guard dataCompletion != nil || downloadCompletion != nil else {

            // A download whose completion we no longer hold, because it finished while the app was not
            // running, is handed to whoever has taken responsibility for the background session's events
            guard isDownload, let unhandledDownloadHandler = unhandledDownloadHandler else {
                ContentRequestSession.removeTemporaryFile(at: fileURL)
                return
            }

            OperationQueue.main.addOperation {
                unhandledDownloadHandler(fileURL, response, error)
                ContentRequestSession.removeTemporaryFile(at: fileURL)
            }
            return
        }

        OperationQueue.main.addOperation {
            dataCompletion?(data, response, error)
            downloadCompletion?(fileURL, response, error)
            ContentRequestSession.removeTemporaryFile(at: fileURL)
        }
    }

    /// Removes a file this session moved out of `URLSession`'s temporary location, once whoever was
    /// handed it has had its chance to copy it somewhere of their own
    ///
    /// Without this every download, including the ones which come back with an error body, would leave a
    /// full copy of the payload behind in the app's temporary directory.
    private static func removeTemporaryFile(at url: URL?) {

        guard let url = url else { return }
        try? FileManager.default.removeItem(at: url)
    }
}

//MARK: - URLSessionDelegate -

extension ContentRequestSession: URLSessionDataDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {

        let redirected = redirectRequest(from: request, key: TaskKey(session: session, task: task))

        if let host = redirected.url?.host {
            os_log("Following redirect to %{public}@, headers re-scoped for the new url", log: log, type: .debug, host)
        }

        completionHandler(redirected)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData[TaskKey(session: session, task: dataTask), default: Data()].append(data)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadProgressHandlers[TaskKey(session: session, task: downloadTask)]?(totalBytesWritten, totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        // `URLSession` deletes the file as soon as this returns, so it has to be moved somewhere of
        // our own before the completion is called
        let destination = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("ContentRequestSession-\(UUID().uuidString)")

        do {
            try FileManager.default.moveItem(at: location, to: destination)
            downloadedFileURLs[TaskKey(session: session, task: downloadTask)] = destination
        } catch {
            os_log("Failed to move downloaded file out of the session's temporary location", log: log, type: .error)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        finish(
            key: TaskKey(session: session, task: task),
            isDownload: task is URLSessionDownloadTask,
            response: task.response as? HTTPURLResponse,
            error: error
        )
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {

        guard let backgroundEventsFinishedHandler = backgroundEventsFinishedHandler else { return }

        OperationQueue.main.addOperation {
            backgroundEventsFinishedHandler()
        }
    }
}
