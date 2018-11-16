//
//  NameGameViewController+SimpleTimerProtocol.swift
//  NameGame
//
//  Created by Robert Dates on 11/16/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation


extension NameGameViewController: SimpleTimerProtocol {
    
    /// Function is called when the simple timer is fired.
    public func timerHandler() {
        hideFaceButtonImage()
    }
    
}
