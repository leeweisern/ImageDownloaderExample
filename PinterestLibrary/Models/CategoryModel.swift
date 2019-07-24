//
//  CategoryModel.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

struct CategoryModel: Codable {
    
    let id: Int
    let title: String
    let photoCount: Int
    let links: LinksModel
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case photoCount = "photo_count"
        case links = "links"
    }
}
