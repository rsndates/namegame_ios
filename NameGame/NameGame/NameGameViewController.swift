//
//  ViewController.swift
//  NameGame
//
//  Created by Matt Kauper on 3/8/16.
//  Copyright © 2016 WillowTree Apps. All rights reserved.
//

import UIKit

class NameGameViewController: UIViewController {
    
    // MARK: - IBOutlests
    
    @IBOutlet weak var avgTimeLabel: UILabel!
    @IBOutlet weak var hitsLabel: UILabel!
    @IBOutlet weak var missesLabel: UILabel!
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var innerStackView1: UIStackView!
    @IBOutlet weak var innerStackView2: UIStackView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var imageButtons: [FaceButton]!
    @IBOutlet weak var menuButton: UIButton! {
        didSet {
            menuButton.layer.cornerRadius = 5
            menuButton.clipsToBounds = true
        }
    }
    
    
    // MARK: - Public Properties
    
    public lazy var nameGame: NameGame = {
        var game = NameGame()
        game.delegate = self
        return game
    }()
    public var currentEmployees = [Employee]()
    public let timer = SimpleTimer()
    public var group = DispatchGroup()
    public var startTime:Date!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let orientation: UIDeviceOrientation = self.view.frame.size.height > self.view.frame.size.width ? .portrait : .landscapeLeft
        configureSubviews(orientation)
        self.nameGame.gameMode = .willowtree
        self.nameGame.loadGameData { [weak self] in
            guard let strongSelf = self else { return }
            LoaderController.sharedInstance.showLoader()
            strongSelf.nameGame.chooseRandomEmployees()
        }
        self.imageButtons.forEach { (button) in button.delegate = self }
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let orientation: UIDeviceOrientation = size.height > size.width ? .portrait : .landscapeLeft
        configureSubviews(orientation)
    }
    
    // MARK: - IBActions
    
    @IBAction func menuTapped(_ sender: Any) {
        self.presentMenuViewController()
        
    }
    
    @IBAction func faceTapped(_ button: FaceButton) {
        if let buttonIndex = imageButtons.index(of: button),
            self.currentEmployees[buttonIndex].fullName() == self.questionLabel.text {
            
            //Tracks elapsed time to guess the correct answer
            let elapsedTime = Date().timeIntervalSince(self.startTime)
            self.nameGame.guessTimeArray.append(elapsedTime)
            self.avgTimeLabel?.text = String(format: "%.1f sec", elapsedTime)
            // Show loader icon between batches of employees
            LoaderController.sharedInstance.showLoader()
            button.tintView.backgroundColor = UIColor(red: 64/255, green: 232/255, blue: 211/255, alpha: 0.6)
            button.tintView.alpha = 1.0
            UIView.animate(withDuration: 0.5, animations: {
                button.tintView.backgroundColor = .clear
                button.tintView.alpha = 0.0
                
            }) { (finished) in
                if !self.nameGame.correctHint {
                    self.showAlertController(title: "Nice!", message: "When you guess correctly your hit score increases.")
                    self.nameGame.correctHint = true
                } else if self.nameGame.correctHint && !self.nameGame.socialHint {
                    self.showAlertController(title: "Make Friends!", message: "If you press and hold the photos outlined in green, you can explore the selected person's social network account.")
                    self.nameGame.socialHint = true
                }
                let employee = self.currentEmployees[buttonIndex]
                if !(self.nameGame.correctlyGuessedEmployees.contains(employee.id)) {
                    self.nameGame.correctlyGuessedEmployees.insert(employee.id)
                }
                self.nameGame.incrementHits()
                self.updateScoreLabels()
                if (self.nameGame.correctlyGuessedEmployees.count == self.nameGame.filteredEmployees.count) {
                    self.showCompletionAlert()
                }
                if self.nameGame.gameMode == .hint { self.hintModeReset() }
                self.nameGame.chooseRandomEmployees()
                
            }
        } else {
            if !self.nameGame.wrongHint {
                self.showAlertController(title: "Oops!", message: "When you guess incorrectly your miss score increases.")
                self.nameGame.wrongHint = true
            }
            button.tintView.backgroundColor = UIColor(red: 255/255, green: 71/255, blue: 35/255, alpha: 0.6)
            button.tintView.alpha = 1.0
            UIView.animate(withDuration: 0.5, animations: {
                button.tintView.backgroundColor = .clear
                button.tintView.alpha = 0.0
                
            }) { (finished) in
                self.nameGame.incrementMisses()
                self.updateScoreLabels()
            }
        }
        
    }
    
    // MARK: - Private Methods
    
    /// Configure view based on orientation of the device
    ///
    /// - Parameter orientation: landscape or portrait
    private func configureSubviews(_ orientation: UIDeviceOrientation) {
        if orientation.isLandscape {
            outerStackView.axis = .vertical
            innerStackView1.axis = .horizontal
            innerStackView2.axis = .horizontal
        } else {
            outerStackView.axis = .horizontal
            innerStackView1.axis = .vertical
            innerStackView2.axis = .vertical
        }
        
        view.setNeedsLayout()
    }
    
    // MARK: - Public Methods
    
    /// Once a user has seen correctly guess every employee once this is fired
    public func showCompletionAlert() {
        let alertController = UIAlertController(title: "Congrats!!!", message: "You have matched everyone.", preferredStyle: UIAlertController.Style.alert)
        
        let OKAction = UIAlertAction(title: "New Game", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> Void in
            self.resetGame(to: self.nameGame.gameMode)
        })
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Instantiates MenuViewController and presents it
    public func presentMenuViewController() {
        if !self.nameGame.menuHint {
            self.showAlertController(title: "Game Modes", message: "The menu allows you to select different game modes and also check your average answering time.")
            self.nameGame.menuHint = true
        }
        let menuVC = MenuViewController()
        menuVC.view.backgroundColor = UIColor.clear
        menuVC.modalPresentationStyle = .overCurrentContext
        menuVC.configureMenu(hits: self.nameGame.hits, misses: self.nameGame.misses, timeArray: self.nameGame.guessTimeArray)
        menuVC.delegate = self
        present(menuVC, animated: true, completion: nil)
    }
    
    /// Convenience method to show alert controller
    ///
    /// - Parameters:
    ///   - title: Title that will be displayed on alert
    ///   - message: Message that will be displayed on alert
    
    public func showAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// update score label to reflect name game scores;
    public func updateScoreLabels() {
        self.hitsLabel.text = self.nameGame.hits.description
        self.missesLabel.text = self.nameGame.misses.description
    }
    
    /// Restores score labels to initial state
    public func resetScoreLabels() {
        self.hitsLabel.text = "0"
        self.missesLabel.text = "0"
    }
}
