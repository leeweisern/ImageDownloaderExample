//
//  Resource.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

public protocol Resource {
    var cacheKey: String { get }
    var downloadURL: URL { get }
}

public struct ImageResource: Resource {
    
    public let cacheKey: String
    public let downloadURL: URL
    
    public init(downloadURL: URL) {
        self.downloadURL = downloadURL
        self.cacheKey = downloadURL.absoluteString
    }
}

extension URL: Resource {
    public var cacheKey: String { return absoluteString }
    public var downloadURL: URL { return self }
}
