//
//  Storage.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

/// Constants for some time intervals
struct TimeConstants {
    static let secondsInOneMinute = 60
    static let minutesInOneHour = 60
    static let hoursInOneDay = 24
    static let secondsInOneDay = secondsInOneMinute * minutesInOneHour * hoursInOneDay
}

public enum StorageExpiration {
    /// The item never expires.
    case never
    /// The item expires after a time duration of given seconds from now.
    case seconds(TimeInterval)
    /// The item expires after a time duration of given days from now.
    case days(Int)
    /// The item expires after a given date.
    case date(Date)
    /// Indicates the item is already expired. Use this to skip cache.
    case expired
    
    func estimatedExpirationSince(_ date: Date) -> Date {
        switch self {
        case .never: return .distantFuture
        case .seconds(let seconds): return date.addingTimeInterval(seconds)
        case .days(let days): return date.addingTimeInterval(TimeInterval(TimeConstants.secondsInOneDay * days))
        case .date(let ref): return ref
        case .expired: return .distantPast
        }
    }
    
    var estimatedExpirationSinceNow: Date {
        return estimatedExpirationSince(Date())
    }
    
    var isExpired: Bool {
        return timeInterval <= 0
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .never: return .infinity
        case .seconds(let seconds): return seconds
        case .days(let days): return TimeInterval(TimeConstants.secondsInOneDay * days)
        case .date(let ref): return ref.timeIntervalSinceNow
        case .expired: return -(.infinity)
        }
    }
}

public enum ExpirationExtending {
    /// The item expires after the original time, without extending after access.
    case none
    /// The item expiration extends by the original cache time after each access.
    case cacheTime
    /// The item expiration extends by the provided time after each access.
    case expirationTime(_ expiration: StorageExpiration)
}

public protocol CacheCostCalculable {
    var cacheCost: Int { get }
}

extension CacheCostCalculable where Self: UIImage {
    public var cacheCost: Int {
        let pixel = Int(size.width * size.height * scale * scale)
        guard let cgImage = cgImage else {
            return pixel * 4
        }
        return pixel * cgImage.bitsPerPixel / 8
    }
}

extension UIImage: CacheCostCalculable {}
