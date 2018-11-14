//
//  Headshot.swift
//  NameGame
//
//  Created by Robert Dates on 11/13/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation

struct Headshot: Codable {
    var type: String
    var mimeType: String?
    var id: String
    var url: String?
    var alt: String
    var height: Int?
    var width: Int?
}
