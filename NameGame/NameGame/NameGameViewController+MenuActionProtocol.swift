//
//  NameGameViewController+MenuActionProtocol.swift
//  NameGame
//
//  Created by Robert Dates on 11/16/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

extension NameGameViewController: MenuActionProtocol {
    
    
    /// Reset the game session in different mode
    ///
    /// - Parameter gameMode: Desired game mode
    public func resetGame(to gameMode: NameGame.Mode) {
        if gameMode != .hint { self.hintModeReset() }
        self.resetScoreLabels()
        self.nameGame.resetGame(with: gameMode)
    }
    
    /// Ensures the image button photos are visible
    public func hintModeReset() {
        self.timer.stopTimer()
        self.imageButtons.forEach({ (button) in
            button.imageView?.alpha = 1.0
        })
    }
}
