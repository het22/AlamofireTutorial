//
//  CodableResponse.swift
//  AlamofireTutorial
//
//  Created by Het Song on 11/04/2019.
//  Copyright © 2019 Het Song. All rights reserved.
//

import Foundation

struct UploadRes: Codable {
    let status: String
    let uploaded: [Uploaded]
}

struct Uploaded: Codable {
    let filename: String
    let id: String
}

struct TagResponse: Codable {
    let results: [TagResult]
}

struct TagResult: Codable {
    let image: String
    let tagging_id: String?
    let tags: [Tag]
}

struct Tag: Codable {
    let confidence: Double
    let tag: String
}
