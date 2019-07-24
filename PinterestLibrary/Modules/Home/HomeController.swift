//
//  Controller.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

final class HomeController {
    var data: [DataModel] = []
    
    public var didLoadData = Delegate<Void, Void>()
    public var didLoadMoreData = Delegate<Void, Void>()
    public var errorLoading = Delegate<NetworkError, Void>()
    
    private var isLoadingMore = false
    
    public func loadData() {
        fetchData(completion: strongify(weak: self) { (self, data) in
            self.data = data
            self.didLoadData.call()
        })
    }
    
    public func loadMoreData() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        fetchData(completion: strongify(weak: self) { (self, data) in
            self.data += data
            self.isLoadingMore = false
            self.didLoadMoreData.call()
        })
    }
    
    public func reloadData() {
        fetchData(completion: strongify(weak: self) { (self, data) in
            self.data = data
            self.didLoadData.call()
        })
    }
    
    private func fetchData(completion: @escaping (([DataModel]) -> Void)) {
        NetworkService.fetch(from: URL(string: "https://pastebin.com/raw/wgkJgazE")!, completion: strongify(weak: self) { (self, result: Result<[DataModel], NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                    
                case .failure(let error):
                    self.errorLoading.call(error)
                    return
                    
                case .success(let data):
                    completion(data)
                }
            }
        })
    }

    private func loadJsonFrom<T: Decodable>(fileName: String) -> T {
        let path = Bundle.main.path(forResource: fileName, ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options:  .mappedIfSafe)
        let object = try! JSONDecoder().decode(T.self, from: data)
        return object
    }
}
