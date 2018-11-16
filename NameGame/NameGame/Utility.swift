//
//  Networking.swift
//  NameGame
//
//  Created by Robert Dates on 11/14/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

public struct Networking {
    
    static func imageRequest(url: URL, completion: @escaping (_ data:Data) -> Void) {
        let session = URLSession.shared
        session.dataTask(with: url) { (data:Data?, response: URLResponse?, error: Error?) in
            guard let data = data else { return }
            guard error == nil else {
                print("error: \(error!)")
                return
            }
            DispatchQueue.main.async {
                completion(data)
            }
        }.resume()
    }
    
    static func requestGameData(url: URL, completion: @escaping (_ data:Data) -> Void) {
        let session = URLSession.shared
        session.dataTask(with: url) { (data:Data?, response: URLResponse?, error: Error?) in
            guard let data = data else { return }
            guard error == nil else {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                completion(data)
            }
            }.resume()
    }
}

protocol SimpleTimerProtocol: NSObjectProtocol {
    func timerHandler()
}

public class SimpleTimer {
    private weak var timer: Timer?
    var delegate: SimpleTimerProtocol!
    var count = 0
    deinit {
        timer?.invalidate()
    }
    
    func timerHandler(_ timer: Timer) {
        guard self.delegate != nil  else { return }
        self.delegate.timerHandler()
    }
    
    func startTimer() {
        timer?.invalidate()   // stops previous timer, if any
        
        let seconds = 2.0
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { timer in
                self.timerHandler(timer)
                self.count+=1
                if(self.count == 5){
                    self.stopTimer()
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        self.count = 0
    }
}

class LoaderController: NSObject {
    
    static let sharedInstance = LoaderController()
    private let activityIndicator = UIActivityIndicatorView()
    
    //MARK: - Private Methods -
    private func setupLoader() {
        removeLoader()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
    }
    
    //MARK: - Public Methods -
    func showLoader() {
        setupLoader()
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let holdingView = appDel.window!.rootViewController!.view!
        
        DispatchQueue.main.async {
            self.activityIndicator.center = holdingView.center
            self.activityIndicator.startAnimating()
            holdingView.addSubview(self.activityIndicator)
            //UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            //UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
