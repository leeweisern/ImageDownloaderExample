//
//  SessionDataTask.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

public class SessionDataTask {
    
    /// Represents the type of token which used for cancelling a task.
    public typealias CancelToken = Int
    
    struct TaskCallback {
        let onCompleted: Delegate<Result<ImageLoadingResult, Error>, Void>?
        let callback: CallbackQueue
    }
    
    /// Downloaded raw data of current task.
    public private(set) var mutableData: Data
    
    public let task: URLSessionDataTask
    private var callbacksStore = [CancelToken: TaskCallback]()
    
    var callbacks: [SessionDataTask.TaskCallback] {
        lock.lock()
        defer { lock.unlock() }
        return Array(callbacksStore.values)
    }
    
    private var currentToken = 0
    private let lock = NSLock()
    
    let onTaskDone = Delegate<(Result<(Data, URLResponse?), Error>, [TaskCallback]), Void>()
    let onCallbackCancelled = Delegate<(CancelToken, TaskCallback), Void>()
    
    var started = false
    var containsCallbacks: Bool { return !callbacks.isEmpty }
    
    init(task: URLSessionDataTask) {
        self.task = task
        mutableData = Data()
    }
    
    func addCallback(_ callback: TaskCallback) -> CancelToken {
        lock.lock()
        defer { lock.unlock() }
        callbacksStore[currentToken] = callback
        defer { currentToken += 1 }
        return currentToken
    }
    
    func removeCallback(_ token: CancelToken) -> TaskCallback? {
        lock.lock()
        defer { lock.unlock() }
        if let callback = callbacksStore[token] {
            callbacksStore[token] = nil
            return callback
        }
        return nil
    }
    
    func resume() {
        guard !started else { return }
        started = true
        task.resume()
    }
    
    func cancel(token: CancelToken) {
        guard let callback = removeCallback(token) else {
            return
        }
        if callbacksStore.count == 0 {
            task.cancel()
        }
        onCallbackCancelled.call((token, callback))
    }
    
    func forceCancel() {
        for token in callbacksStore.keys {
            cancel(token: token)
        }
    }
    
    func didReceiveData(_ data: Data) {
        mutableData.append(data)
    }
}
