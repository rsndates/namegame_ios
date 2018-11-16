//
//  NameGame.swift
//  NameGame
//
//  Created by Erik LaManna on 11/7/16.
//  Copyright © 2016 WillowTree Apps. All rights reserved.
//

import Foundation
import Darwin

protocol NameGameDelegate: class {
    func displayNewBatch(of employees: [Employee])
}

class NameGame {
    
    // MARK: - Private Properties
    
    private let numberPeople = 6
    private let url = "https://willowtreeapps.com/api/v1.0/profiles/"
    
    
    // MARK: - Public Properties
    
    public weak var delegate: NameGameDelegate?
    public var employees: [Employee]!
    public var filteredEmployees: [Employee]!
    public var hits:Int = 0
    public var misses:Int = 0
    public var gameMode = Mode.willowtree
    public var correctlyGuessedEmployees = Set<String>()
    public var guessTimeArray: [TimeInterval] = []
    public var socialHint = false
    public var correctHint = false
    public var wrongHint = false
    public var menuHint = false
    
    // MARK: - Game Mode Enum
    
    enum Mode: String {
        case willowtree = "wi"
        case matt = "ma"
        case reverse = "re"
        case hint = "hi"
        case team = "te"
        
    }
    
    // MARK: - Public Methods
    
    public func incrementHits() {
        self.hits+=1
    }
    
    public func incrementMisses() {
        self.misses+=1
    }
    
    public func resetGame(with newGameMode: Mode) {
        self.hits = 0
        self.misses = 0
        self.correctlyGuessedEmployees.removeAll()
        self.gameMode = newGameMode
        self.guessTimeArray.removeAll()
        self.chooseRandomEmployees()
    }
    
    public func loadGameData(completion: @escaping () -> Void) {
        guard let url = URL(string: self.url) else { return }
        Networking.requestGameData(url: url) { [weak self] (data:Data) in
            guard let strongSelf = self else { return }
            do {
                let employees = try JSONDecoder().decode([Employee].self, from: data)
                strongSelf.employees = employees
                completion()
            } catch let error {
                print(error)
            }
        }
    }
    
    public func uniqueRandomNumbers(totalRandoms: Int, minimum: Int, maximum: UInt32) -> [Int] {
        var uniqueNumbers = Set<Int>()
        while uniqueNumbers.count < totalRandoms {
            uniqueNumbers.insert(Int(arc4random_uniform(maximum + 1)) + minimum)
        }
        return Array(uniqueNumbers).shuffle
    }
    
    public func chooseRandomEmployees()  {
        guard self.employees != nil else { return }
        switch (self.gameMode) {
        case .willowtree, .reverse, .hint:
            self.filteredEmployees = self.employees.filter({ $0.jobTitle != nil && $0.headshot.url != nil && $0.headshot.alt.lowercased().contains($0.firstName.lowercased())})
        case .matt:
            self.filteredEmployees = self.employees.filter({ $0.firstName.lowercased().hasPrefix("mat") && $0.headshot.url != nil && $0.headshot.alt.lowercased().contains($0.firstName.lowercased())})
        case .team:
            self.filteredEmployees = self.employees.filter({$0.headshot.url != nil && $0.headshot.alt.lowercased().contains($0.firstName.lowercased())})
        }
        let randomIndices:[Int] = uniqueRandomNumbers(totalRandoms: 6, minimum: 0, maximum: UInt32(self.filteredEmployees.count-1))
        let employeeArray = randomIndices.map { (index) -> Employee in
            return self.filteredEmployees[index]
        }
        self.delegate!.displayNewBatch(of: employeeArray)
    }
    
}



