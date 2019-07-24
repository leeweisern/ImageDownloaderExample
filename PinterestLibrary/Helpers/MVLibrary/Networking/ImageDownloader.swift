//
//  ImageDownloader.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

/// Represents a success result of an image downloading progress.
public struct ImageLoadingResult {
    
    /// The downloaded image.
    public let image: UIImage
    
    /// Original URL of the image request.
    public let url: URL?
    
    /// The raw data received from downloader.
    public let originalData: Data
}

/// Represents a task of an image downloading process.
public struct DownloadTask {
    
    public let sessionTask: SessionDataTask
    
    public let cancelToken: SessionDataTask.CancelToken
    
    public func cancel() {
        sessionTask.cancel(token: cancelToken)
    }
}

/// Represents a downloading manager for requesting the image with a URL from server.
open class ImageDownloader {

    public static let `default` = ImageDownloader(name: "default")

    open var downloadTimeout: TimeInterval = 15.0

    open var sessionConfiguration = URLSessionConfiguration.ephemeral {
        didSet {
            session.invalidateAndCancel()
            session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        }
    }

    /// Delegate of this `ImageDownloader` object. See `ImageDownloaderDelegate` protocol for more.
    open weak var delegate: ImageDownloaderDelegate?

    private let name: String
    private let sessionDelegate: SessionDelegate
    private var session: URLSession

    // MARK: Initializers
    public init(name: String) {
        if name.isEmpty {
            fatalError("[MindValley] You should specify a name for the downloader. "
                + "A downloader with empty name is not permitted.")
        }

        self.name = name

        sessionDelegate = SessionDelegate()
        session = URLSession(
            configuration: sessionConfiguration,
            delegate: sessionDelegate,
            delegateQueue: nil)

        setupSessionHandler()
    }

    deinit { session.invalidateAndCancel() }

    private func setupSessionHandler() {
        sessionDelegate.onValidStatusCode.delegate(on: self) { (self, code) in
            return (self.delegate ?? self).isValidStatusCode(code, for: self)
        }

        sessionDelegate.onDownloadingFinished.delegate(on: self) { (self, value) in
            let (url, result) = value
            do {
                let value = try result.get()
                self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: value, error: nil)
            } catch {
                self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: nil, error: error)
            }

        }

        sessionDelegate.onDidDownloadData.delegate(on: self) { (self, task) in
            guard let url = task.task.originalRequest?.url else {
                return task.mutableData
            }
            
            return (self.delegate ?? self).imageDownloader(self, didDownload: task.mutableData, for: url)
        }
    }

    @discardableResult
    func downloadImage(
        with url: URL,
        completionHandler: ((Result<ImageLoadingResult, Error>) -> Void)? = nil) -> DownloadTask?
    {
        // Creates default request.
        let request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: downloadTimeout)

        let onCompleted = wrapCompletionHandlerToOnCompleted(completionHandler: completionHandler)
        let callback = SessionDataTask.TaskCallback(onCompleted: onCompleted,
                                                    callback: .mainCurrentOrAsync)

        // Ready to start download. Add it to session task manager (`sessionHandler`)
        let downloadTask = addTaskForDownload(withRequest: request,
                           callback: callback)

        let sessionTask = downloadTask.sessionTask

        // Start the session task if not started yet.
        if !sessionTask.started {
            sessionTask.onTaskDone.delegate(on: self) { (self, done) in
                let (result, callbacks) = done

                // Before processing the downloaded data.
                do {
                    let value = try result.get()
                    self.delegate?.imageDownloader(
                        self,
                        didFinishDownloadingImageForURL: url,
                        with: value.1,
                        error: nil
                    )
                } catch {
                    self.delegate?.imageDownloader(
                        self,
                        didFinishDownloadingImageForURL: url,
                        with: nil,
                        error: error
                    )
                }

                switch result {
                // Download finished. Now process the data to an image.
                case .success(let (data, _)):
                    let image = UIImage(data: data)
                    let imageResult = ImageLoadingResult(image: image!,
                                                         url: url,
                                                         originalData: data)
                    callbacks.forEach { callback in
                        callback.callback.execute { callback.onCompleted?.call(.success(imageResult)) }
                    }

                case .failure(let error):
                    callbacks.forEach { callback in
                        callback.callback.execute { callback.onCompleted?.call(.failure(error)) }
                    }
                }
            }
            delegate?.imageDownloader(self, willDownloadImageForURL: url, with: request)
            sessionTask.resume()
        }

        return downloadTask
    }

    // Wraps `completionHandler` to `onCompleted` respectively.
    private func wrapCompletionHandlerToOnCompleted(completionHandler: ((Result<ImageLoadingResult, Error>) -> Void)? = nil) -> Delegate<Result<ImageLoadingResult, Error>, Void>? {
        let onCompleted = completionHandler.map {
            block -> Delegate<Result<ImageLoadingResult, Error>, Void> in
            let delegate =  Delegate<Result<ImageLoadingResult, Error>, Void>()
            delegate.delegate(on: self) { (_, callback) in
                block(callback)
            }
            return delegate
        }

        return onCompleted
    }

    private func addTaskForDownload(withRequest request: URLRequest,
                                    callback: SessionDataTask.TaskCallback) -> DownloadTask {
        let downloadTask: DownloadTask
        if let existingTask = sessionDelegate.task(for: request.url!) {
            downloadTask = sessionDelegate.append(existingTask, url: request.url!, callback: callback)
        } else {
            let sessionDataTask = session.dataTask(with: request)
            downloadTask = sessionDelegate.add(sessionDataTask, url: request.url!, callback: callback)
        }

        return downloadTask
    }
}

// MARK: Cancelling Task
extension ImageDownloader {

    /// Cancel all downloading tasks for this `ImageDownloader`. It will trigger the completion handlers
    /// for all not-yet-finished downloading tasks.
    ///
    /// If you need to only cancel a certain task, call `cancel()` on the `DownloadTask`
    /// returned by the downloading methods. If you need to cancel all `DownloadTask`s of a certain url,
    /// use `ImageDownloader.cancel(url:)`.
    public func cancelAll() {
        sessionDelegate.cancelAll()
    }

    /// Cancel all downloading tasks for a given URL. It will trigger the completion handlers for
    /// all not-yet-finished downloading tasks for the URL.
    ///
    /// - Parameter url: The URL which you want to cancel downloading.
    public func cancel(url: URL) {
        sessionDelegate.cancel(url: url)
    }
}

// Use the default implementation from extension of `ImageDownloaderDelegate`.
extension ImageDownloader: ImageDownloaderDelegate {}
