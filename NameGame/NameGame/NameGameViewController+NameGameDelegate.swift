//
//  NameGameViewController+NameGameDelegate.swift
//  NameGame
//
//  Created by Robert Dates on 11/16/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

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
    
    /// Initiates the timer to hide facebutton images
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
