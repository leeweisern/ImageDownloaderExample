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
    
    public func cancelDownload(withUrl url: URL) {
        downloader.cancel(url: url)
    }
}
