//
//  NameGame.swift
//  NameGame
//
//  Created by Erik LaManna on 11/7/16.
//  Copyright © 2016 WillowTree Apps. All rights reserved.
//

import Foundation

protocol NameGameDelegate: class {
    
}

class NameGame {
    
    // MARK: - Private Properties
    
    private let numberPeople = 6
    private let url = "https://willowtreeapps.com/api/v1.0/profiles/"
    
    
    // MARK: - Public Properties
    
    public weak var delegate: NameGameDelegate?
    public var employees: [Employee]!
    
    // Load JSON data from API
    func loadGameData(completion: @escaping () -> Void) {
        guard let url = URL(string: self.url) else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { [weak self] (data:Data?, response: URLResponse?, error: Error?) in
            guard let strongSelf = self else { return }
            guard let data = data else { return }
            do {
                let employees = try JSONDecoder().decode([Employee].self, from: data)
                strongSelf.employees = employees
                completion()
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
