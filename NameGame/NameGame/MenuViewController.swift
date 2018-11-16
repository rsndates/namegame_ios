//
//  MenuViewController.swift
//  NameGame
//
//  Created by Robert Dates on 11/14/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import UIKit

protocol MenuActionProtocol: NSObjectProtocol {
    func resetGame(to gameMode: NameGame.Mode)
}

class MenuViewController: UIViewController {
    
    typealias Mode = NameGame.Mode
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var guessTimeLabel: UILabel!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var hitsCountLabel: UILabel!
    @IBOutlet weak var missesCountLabel: UILabel!
    @IBOutlet var gameModeButtons: [UIButton]!
    
    
    // MARK: - IBActions
    
    @IBAction func gameModeTapped(_ sender: UIButton) {
        //reset counts
        guard self.delegate != nil else { return }
        self.hitsCountLabel.text = "0"
        self.missesCountLabel.text = "0"
        switch (String(sender.titleLabel?.text?.lowercased().prefix(2) ?? "wi")) {
        case Mode.willowtree.rawValue:
            self.delegate.resetGame(to: .willowtree)
        case Mode.matt.rawValue:
            self.delegate.resetGame(to: .matt)
        case Mode.reverse.rawValue:
            break
        case Mode.hint.rawValue:
            self.delegate.resetGame(to: .hint)
        case Mode.team.rawValue:
            self.delegate.resetGame(to: .team)
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Public Properties
    
    public var delegate: MenuActionProtocol!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureFrameView()
        
    }
    
    // MARK: - Private Methods
    
    private func configureFrameView() {
        self.frameView.layer.borderColor = UIColor.darkGray.cgColor
        self.frameView.layer.borderWidth = 0.5
    }
    
    // MARK: - Public  Methods
    
    /// Quick configuration method for the menu view controller
    ///
    /// - Parameters:
    ///   - hits: Total Correct Guesses
    ///   - misses: Total Incorrect Guesses
    ///   - timeArray: Collection of elapsed time during guess
    
    public func configureMenu(hits: Int, misses: Int, timeArray: [TimeInterval]) {
        self.hitsCountLabel.text = hits.description
        self.missesCountLabel.text = misses.description
        self.calculateTimeAverage(timeArray: timeArray)
    }
    
    /// Method is used to calculate the average elapsed time it takes for
    /// user to correctly guess an employee
    /// - Parameter timeArray: array of elapsed time during a game round
    
    public func calculateTimeAverage(timeArray: [TimeInterval]) {
        guard !timeArray.isEmpty else {
            self.guessTimeLabel?.text = "avg: 0 sec"
            return
        }
        let totalTime:Double = timeArray.reduce(0,+)
        let avgTime = CGFloat(totalTime/Double(timeArray.count))
        self.guessTimeLabel?.text = String(format: "avg: %.3f sec", avgTime)
        
    }
    
}

