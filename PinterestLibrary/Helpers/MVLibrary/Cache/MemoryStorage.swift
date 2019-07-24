//
//  MemoryStorage.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

public class CacheDelegate<T>: NSObject, NSCacheDelegate {
    let onObjectRemoved = Delegate<T, Void>()
    public func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let obj = obj as? T {
            onObjectRemoved.call(obj)
        }
    }
}

public enum MemoryStorage {
    
    public class Backend<T: CacheCostCalculable> {
        let storage = NSCache<NSString, StorageObject<T>>()
        var keys = Set<String>()
        
        var cleanTimer: Timer? = nil
        let lock = NSLock()
        
        let cacheDelegate = CacheDelegate<StorageObject<T>>()
        
        public var config: Config {
            didSet {
                storage.totalCostLimit = config.totalCostLimit
                storage.countLimit = config.countLimit
            }
        }
        
        public init(config: Config) {
            self.config = config
            storage.totalCostLimit = config.totalCostLimit
            storage.countLimit = config.countLimit
            storage.delegate = cacheDelegate
            cacheDelegate.onObjectRemoved.delegate(on: self) { (self, obj) in
                self.keys.remove(obj.key)
            }
            
            cleanTimer = .scheduledTimer(withTimeInterval: config.cleanInterval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.removeExpired()
            }
        }
        
        func removeExpired() {
            lock.lock()
            defer { lock.unlock() }
            
            for key in keys {
                let nsKey = key as NSString
                guard let object = storage.object(forKey: nsKey) else {
                    keys.remove(key)
                    continue
                }
                if object.estimatedExpiration.isPast {
                    storage.removeObject(forKey: nsKey)
                    keys.remove(key)
                }
            }
        }
        
        // Storing in memory will not throw. It is just for meeting protocol requirement and
        // forwarding to no throwing method.
        func store(
            value: T,
            forKey key: String,
            expiration: StorageExpiration? = nil) throws {
            storeNoThrow(value: value, forKey: key, expiration: expiration)
        }
        
        func storeNoThrow(
            value: T,
            forKey key: String,
            expiration: StorageExpiration? = nil) {
            lock.lock()
            defer { lock.unlock() }
            let expiration = expiration ?? config.expiration
            // The expiration indicates that already expired, no need to store.
            guard !expiration.isExpired else { return }
            
            let object = StorageObject(value, key: key, expiration: expiration)
            storage.setObject(object, forKey: key as NSString, cost: value.cacheCost)
            keys.insert(key)
        }
        
        func value(forKey key: String, extendingExpiration: ExpirationExtending = .cacheTime) -> T? {
            guard let object = storage.object(forKey: key as NSString) else {
                return nil
            }
            if object.expired {
                return nil
            }
            object.extendExpiration(extendingExpiration)
            return object.value
        }
        
        func isCached(forKey key: String) -> Bool {
            guard let _ = value(forKey: key, extendingExpiration: .none) else {
                return false
            }
            return true
        }
        
        func remove(forKey key: String) throws {
            lock.lock()
            defer { lock.unlock() }
            storage.removeObject(forKey: key as NSString)
            keys.remove(key)
        }
        
        func removeAll() throws {
            lock.lock()
            defer { lock.unlock() }
            storage.removeAllObjects()
            keys.removeAll()
        }
    }
}

extension MemoryStorage {
    /// Represents the config used in a `MemoryStorage`.
    public struct Config {
        
        /// Total cost limit of the storage in bytes.
        public var totalCostLimit: Int
        
        /// The item count limit of the memory storage.
        public var countLimit: Int = .max
        
        public var expiration: StorageExpiration = .seconds(300)
        
        public let cleanInterval: TimeInterval
        
        public init(totalCostLimit: Int, cleanInterval: TimeInterval = 120) {
            self.totalCostLimit = totalCostLimit
            self.cleanInterval = cleanInterval
        }
    }
}

extension MemoryStorage {
    class StorageObject<T> {
        let value: T
        let expiration: StorageExpiration
        let key: String
        
        private(set) var estimatedExpiration: Date
        
        init(_ value: T, key: String, expiration: StorageExpiration) {
            self.value = value
            self.key = key
            self.expiration = expiration
            
            self.estimatedExpiration = expiration.estimatedExpirationSinceNow
        }
        
        func extendExpiration(_ extendingExpiration: ExpirationExtending = .cacheTime) {
            switch extendingExpiration {
            case .none:
                return
            case .cacheTime:
                self.estimatedExpiration = expiration.estimatedExpirationSinceNow
            case .expirationTime(let expirationTime):
                self.estimatedExpiration = expirationTime.estimatedExpirationSinceNow
            }
        }
        
        var expired: Bool {
            return estimatedExpiration.isPast
        }
    }
}
