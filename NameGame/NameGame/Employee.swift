//
//  Employee.swift
//  NameGame
//
//  Created by Robert Dates on 11/13/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation


struct Employee: Codable {
    var id: String
    var type: String
    var slug: String
    var jobTitle: String?
    var firstName: String
    var lastName: String
    var headshot: Headshot
    var socialLinks: [Social?]
    
    func fullName() -> String {
        return self.firstName + " " + self.lastName
    }
    
}

