//
//  NameGameViewController+FaceButtonProtocol.swift
//  NameGame
//
//  Created by Robert Dates on 11/16/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

extension NameGameViewController: FaceButtonProtocol {
    
    /// Opens the social media information provided in the parameters
    ///
    /// - Parameter social: Social object that is used to obtain the web url
    func exploreEmpoyeeSocial(social: Social) {
        guard let url = URL(string: social.url) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            // Fallback on earlier versions
            let alertController = UIAlertController(title: "Oops", message: "This feature is only supported for iOS 10.0+", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
