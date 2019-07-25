//
//  MindValleyManager.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

public var MindValley: MindValleyManager { return MindValleyManager.shared }

public class MindValleyManager {
    
    public static let shared = MindValleyManager()
    public var cache: ImageCache
    public var downloader: ImageDownloader

    /// Creates an image setting manager with specified downloader and cache.
    ///
    /// - Parameters:
    ///   - cache: The image cache which stores images in memory.
    ///   - downloader: The image downloader used to download images.
    public init(cache: ImageCache, downloader: ImageDownloader) {
        self.cache = cache
        self.downloader = downloader
    }
    
    private convenience init() {
        self.init(cache: .default, downloader: .default)
    }
    
    /// Download image from a particular url, that handles caching as well.
    ///
    /// - Parameters:
    ///   - resource: The url for requesting the image
    ///   - completionHandler: Callback when finish getting an image or error
    public func retrieveImage(
        with resource: Resource,
        completionHandler: @escaping ((Result<UIImage, Error>) -> Void)) {
        if let imageFromCache = cache.retrieveImage(forKey: resource.cacheKey) {
            completionHandler(.success(imageFromCache))
            return
        }
        
        downloader.downloadImage(with: resource.downloadURL, completionHandler: strongify(weak: self) { (self, result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
                print("MindValley: ", error)
            
            case .success(let response):
                self.cache.store(response.image, forKey: resource.cacheKey)
                completionHandler(.success(response.image))
            }
        })
    }
    
    /// Cancel a download task if it is running. It will do nothing if this task is not running.
    ///
    /// - Note:
    /// There is an optimization to prevent starting another download task if the target URL is being
    /// downloading. However,cancelling a `DownloadTask`
    /// does not affect other `DownloadTask`s.
    ///
    /// - Parameters:
    ///   - url: The requested url task that is downloading
    public func cancelDownload(withUrl url: URL) {
        downloader.cancel(url: url)
    }
    
    /// Limits the maximum total cost that the cache can hold before it starts evicting objects.
    ///
    /// - Parameters:
    ///   - size: The maximum total cost that the cache can hold in bytes
    public func maximumMemoryStorage(ofSize size: Int) {
        cache.setStorageLimit(withMemory: size)
    }
}
