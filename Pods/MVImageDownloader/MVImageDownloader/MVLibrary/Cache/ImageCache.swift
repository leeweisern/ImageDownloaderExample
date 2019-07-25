//
//  ImageCache.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

open class ImageCache {
    public static let `default` = ImageCache()
    let memoryStorage: MemoryStorage.Backend<UIImage>
    
    public init() {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4
        let memoryStorage = MemoryStorage.Backend<UIImage>(config:
            .init(totalCostLimit: (costLimit > Int.max) ? Int.max : Int(costLimit)))
        
        self.memoryStorage = memoryStorage
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearMemoryCache),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)

    }
    
    public func setStorageLimit(withMemory memory: Int) {
        memoryStorage.config.totalCostLimit = memory
    }
    
    @objc public func clearMemoryCache() {
        try? memoryStorage.removeAll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func store(_ image: UIImage,
                    forKey key: String) {
        memoryStorage.storeNoThrow(value: image, forKey: key)
    }
    
    open func removeImage(forKey key: String) {
        try? memoryStorage.remove(forKey: key)
    }
    
    open func retrieveImage(forKey key: String) -> UIImage? {
        return memoryStorage.value(forKey: key,
                                   extendingExpiration: .cacheTime)
    }
    
    open func cleanExpiredMemoryCache() {
        memoryStorage.removeExpired()
    }
    
    open func isCached(forKey key: String) -> Bool {
        return memoryStorage.isCached(forKey: key)
    }
}
