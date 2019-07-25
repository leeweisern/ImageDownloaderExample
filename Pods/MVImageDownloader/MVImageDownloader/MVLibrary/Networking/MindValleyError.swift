//
//  MindValleyError.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 24/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

public enum MindValleyError: Error {
    case taskCancelled
    case invalidURLResponse
    case invalidHTTPStatusCode
    case URLSessionError
    case noURLResponse
    case unknownError

}
