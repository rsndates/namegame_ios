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
            let elapsedTime = Date().timeIntervalSince(self.startTime)
            self.nameGame.guessTimeArray.append(elapsedTime)
            self.avgTimeLabel?.text = String(format: "%.1f sec", elapsedTime)
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
    
    public func showCompletionAlert() {
        let alertController = UIAlertController(title: "Congrats!!!", message: "You have matched everyone.", preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "New Game", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
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
        let OKAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
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

extension NameGameViewController: MenuActionProtocol {
    public func resetGame(to gameMode: NameGame.Mode) {
        if gameMode != .hint { self.hintModeReset() }
        self.resetScoreLabels()
        self.nameGame.resetGame(with: gameMode)
    }
    
    public func hintModeReset() {
        self.timer.stopTimer()
        self.imageButtons.forEach({ (button) in
            button.imageView?.alpha = 1.0
        })
    }
}

extension NameGameViewController: NameGameDelegate {
    /// Grabs 6 randomly chosen employees
    ///
    /// - Parameter employees: array of employees
    public func displayNewBatch(of employees: [Employee]) {
        self.currentEmployees = employees
        let randomIndex = Int(arc4random_uniform(UInt32(6)))
        self.outerStackView.alpha = 0.0
        for pair in zip(imageButtons, employees).enumerated() {
            
            pair.element.0.showUsersFace(employee: pair.element.1, group: self.group)
        }
        group.notify(queue: .main) {
            UIView.animate(withDuration: 0.4, animations: {
                self.outerStackView.alpha = 1.0
            })
            self.questionLabel.text? = employees[randomIndex].fullName()
            sleep(UInt32(0.7))
            LoaderController.sharedInstance.removeLoader()
            self.startTime = Date()
            if self.nameGame.gameMode == .hint {
                self.startFaceButtonDissapearingTimer()
            }
        }
    }
    
    public func startFaceButtonDissapearingTimer() {
        timer.delegate = self
        timer.startTimer()
    }
    
    /// Selects a qualifiiying faceButton to hide
    public func hideFaceButtonImage() {
        for button in imageButtons {
            if let buttonIndex = imageButtons.index(of: button),
                self.currentEmployees[buttonIndex].fullName() != self.questionLabel.text,
                button.imageView?.alpha != 0.0 {
                button.imageView?.alpha = 0.0
                button.layer.borderWidth = 0
                break
            }
        }
    }
}

extension NameGameViewController: SimpleTimerProtocol {
    public func timerHandler() {
        hideFaceButtonImage()
    }
}

extension NameGameViewController: FaceButtonProtocol {
    func exploreEmpoyeeSocial(social: Social) {
        guard let url = URL(string: social.url) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            // Fallback on earlier versions
            let alertController = UIAlertController(title: "Oops", message: "This feature is only supported for iOS 10.0+", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
