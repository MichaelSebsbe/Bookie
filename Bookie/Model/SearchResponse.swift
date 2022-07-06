//
//  SearchResponse.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/5/22.
//

import Foundation

struct SearchResponse: Codable {
    var docs: [Doc]
}

struct Doc: Codable {
    var title: String
    var isbn: [String]? //use last one to fetch image
    var author_name: [String]?
}
