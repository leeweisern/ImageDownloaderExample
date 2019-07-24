//
//  ProfileLinksModel.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

struct LinksModel: Codable {
    
    let own: String?
    let html: String?
    let download: String?
    let photos: String?
    let likes: String?
    
    enum CodingKeys: String, CodingKey {
        case own = "self"
        case html = "html"
        case download = "download"
        case photos = "photos"
        case likes = "likes"
    }
}
