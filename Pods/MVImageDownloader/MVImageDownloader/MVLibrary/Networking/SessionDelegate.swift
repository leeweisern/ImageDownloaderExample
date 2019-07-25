//
//  SessionDelegate.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

class SessionDelegate: NSObject {

    private var tasks: [URL: SessionDataTask] = [:]
    private let lock = NSLock()
    
    let onValidStatusCode = Delegate<Int, Bool>()
    let onDownloadingFinished = Delegate<(URL, Result<URLResponse, Error>), Void>()
    let onDidDownloadData = Delegate<SessionDataTask, Data?>()
    
    func add(
        _ dataTask: URLSessionDataTask,
        url: URL,
        callback: SessionDataTask.TaskCallback) -> DownloadTask
    {
        lock.lock()
        defer { lock.unlock() }
        
        let task = SessionDataTask(task: dataTask)
        task.onCallbackCancelled.delegate(on: self) { [unowned task] (self, value) in
            let (_, callback) = value
            
            let error = MindValleyError.taskCancelled
            task.onTaskDone.call((.failure(error), [callback]))
            // No other callbacks waiting, we can clear the task now.
            
            if !task.containsCallbacks {
                let dataTask = task.task
                self.remove(dataTask)
            }
        }
        let token = task.addCallback(callback)
        tasks[url] = task
        return DownloadTask(sessionTask: task, cancelToken: token)
    }
    
    func append(
        _ task: SessionDataTask,
        url: URL,
        callback: SessionDataTask.TaskCallback) -> DownloadTask
    {
        let token = task.addCallback(callback)
        return DownloadTask(sessionTask: task, cancelToken: token)
    }
    
    private func remove(_ task: URLSessionTask) {
        guard let url = task.originalRequest?.url else {
            return
        }
        lock.lock()
        defer {lock.unlock()}
        tasks[url] = nil
    }
    
    private func task(for task: URLSessionTask) -> SessionDataTask? {
        
        guard let url = task.originalRequest?.url else {
            return nil
        }
        
        lock.lock()
        defer { lock.unlock() }
        guard let sessionTask = tasks[url] else {
            return nil
        }
        guard sessionTask.task.taskIdentifier == task.taskIdentifier else {
            return nil
        }
        return sessionTask
    }
    
    func task(for url: URL) -> SessionDataTask? {
        lock.lock()
        defer { lock.unlock() }
        return tasks[url]
    }
    
    func cancelAll() {
        lock.lock()
        let taskValues = tasks.values
        lock.unlock()
        for task in taskValues {
            task.forceCancel()
        }
    }
    
    func cancel(url: URL) {
        lock.lock()
        let task = tasks[url]
        lock.unlock()
        task?.forceCancel()
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data) {
        guard let task = self.task(for: dataTask) else {
            return
        }
        
        task.didReceiveData(data)
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = MindValleyError.invalidURLResponse
            onCompleted(task: dataTask, result: .failure(error))
            completionHandler(.cancel)
            return
        }
        
        let httpStatusCode = httpResponse.statusCode
        guard onValidStatusCode.call(httpStatusCode) == true else {
            let error = MindValleyError.invalidHTTPStatusCode
            onCompleted(task: dataTask, result: .failure(error))
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?) {
        guard let sessionTask = self.task(for: task) else { return }
        
        if let url = task.originalRequest?.url {
            let result: Result<URLResponse, Error>
            if let error = error {
                result = .failure(error)
            } else if let response = task.response {
                result = .success(response)
            } else {
                result = .failure(MindValleyError.noURLResponse)
            }
            
            onDownloadingFinished.call((url, result))
        }
        
        let result: Result<(Data, URLResponse?), Error>
        if let error = error {
            result = .failure(error)
        } else {
            if let data = onDidDownloadData.call(sessionTask), let finalData = data {
                result = .success((finalData, task.response))
            } else {
                result = .failure(MindValleyError.unknownError)
            }
        }
        
        onCompleted(task: task, result: result)
    }
    
    private func onCompleted(task: URLSessionTask, result: Result<(Data, URLResponse?), Error>) {
        guard let sessionTask = self.task(for: task) else {
            return
        }
        remove(task)
        sessionTask.onTaskDone.call((result, sessionTask.callbacks))
    }
}
