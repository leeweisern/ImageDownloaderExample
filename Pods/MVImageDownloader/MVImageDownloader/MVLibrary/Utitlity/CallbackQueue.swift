//
//  CallbackQueue.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

/// Represents callback queue behaviors when an calling of closure be dispatched.
///
/// - asyncMain: Dispatch the calling to `DispatchQueue.main` with an `async` behavior.
/// - currentMainOrAsync: Dispatch the calling to `DispatchQueue.main` with an `async` behavior if current queue is not
///                       `.main`. Otherwise, call the closure immediately in current main queue.
/// - untouch: Do not change the calling queue for closure.
/// - dispatch: Dispatches to a specified `DispatchQueue`.
public enum CallbackQueue {
    /// Dispatch the calling to `DispatchQueue.main` with an `async` behavior.
    case mainAsync
    /// Dispatch the calling to `DispatchQueue.main` with an `async` behavior if current queue is not
    /// `.main`. Otherwise, call the closure immediately in current main queue.
    case mainCurrentOrAsync
    /// Do not change the calling queue for closure.
    case untouch
    /// Dispatches to a specified `DispatchQueue`.
    case dispatch(DispatchQueue)
    
    public func execute(_ block: @escaping () -> Void) {
        switch self {
        case .mainAsync:
            DispatchQueue.main.async { block() }
        case .mainCurrentOrAsync:
            DispatchQueue.main.safeAsync { block() }
        case .untouch:
            block()
        case .dispatch(let queue):
            queue.async { block() }
        }
    }
    
    var queue: DispatchQueue {
        switch self {
        case .mainAsync: return .main
        case .mainCurrentOrAsync: return .main
        case .untouch: return OperationQueue.current?.underlyingQueue ?? .main
        case .dispatch(let queue): return queue
        }
    }
}

extension DispatchQueue {
    // This method will dispatch the `block` to self.
    // If `self` is the main queue, and current thread is main thread, the block
    // will be invoked immediately instead of being dispatched.
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
