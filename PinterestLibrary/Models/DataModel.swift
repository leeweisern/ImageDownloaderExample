//
//  DataModel.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

struct DataModel: Codable {
    
    let id: String
    let createdAt: String
    let width: Double
    let height: Double
    let color: String
    let likes: Int
    let likedByUser: Bool
    let user: UserModel
    let urls: UrlModel
    let categories: [CategoryModel]
    let links: LinksModel

    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case color = "color"
        case likes = "likes"
        case likedByUser = "liked_by_user"
        case user = "user"
        case urls = "urls"
        case categories = "categories"
        case links = "links"
    }
}
