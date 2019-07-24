//
//  UserModel.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

struct UserModel: Codable {
    
    let id: String
    let username: String
    let name: String
    let profileImage: ProfileImageModel
    let links: LinksModel
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case name = "name"
        case profileImage = "profile_image"
        case links = "links"
    }
}
