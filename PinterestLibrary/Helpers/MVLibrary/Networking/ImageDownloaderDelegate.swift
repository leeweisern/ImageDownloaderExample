//
//  ImageDownloaderDelegate.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import UIKit

/// Protocol of `ImageDownloader`. This protocol provides a set of methods which are related to image downloader
/// working stages and rules.
public protocol ImageDownloaderDelegate: AnyObject {
    
    func imageDownloader(
        _ downloader: ImageDownloader,
        willDownloadImageForURL url: URL,
        with request: URLRequest?)
    
    func imageDownloader(
        _ downloader: ImageDownloader,
        didFinishDownloadingImageForURL url: URL,
        with response: URLResponse?,
        error: Error?)
    
    func imageDownloader(
        _ downloader: ImageDownloader,
        didDownload data: Data,
        for url: URL) -> Data?
    
 
    func imageDownloader(
        _ downloader: ImageDownloader,
        didDownload image: UIImage,
        for url: URL,
        with response: URLResponse?)
   
    func isValidStatusCode(
        _ code: Int,
        for downloader: ImageDownloader) -> Bool
}

// Default implementation for `ImageDownloaderDelegate`.
extension ImageDownloaderDelegate {
    public func imageDownloader(
        _ downloader: ImageDownloader,
        willDownloadImageForURL url: URL,
        with request: URLRequest?) {}
    
    public func imageDownloader(
        _ downloader: ImageDownloader,
        didFinishDownloadingImageForURL url: URL,
        with response: URLResponse?,
        error: Error?) {}
    
    public func imageDownloader(
        _ downloader: ImageDownloader,
        didDownload image: UIImage,
        for url: URL,
        with response: URLResponse?) {}
    
    public func isValidStatusCode(_ code: Int, for downloader: ImageDownloader) -> Bool {
        return (200..<400).contains(code)
    }
    
    public func imageDownloader(
        _ downloader: ImageDownloader,
        didDownload data: Data,
        for url: URL) -> Data? {
        return data
    }
}
