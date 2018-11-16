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
    
    /// Network request for images
    ///
    /// - Parameters:
    ///   - url: url of image
    ///   - completion: execute this block on main thread after data is received
    
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
    
    /// Network request for game data
    ///
    /// - Parameters:
    ///   - url: url of data
    ///   - completion: execute this block on main thread after data is received
    
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

/// Allow an adopter to handle the timer firing
protocol SimpleTimerProtocol: NSObjectProtocol {
    func timerHandler()
}

public class SimpleTimer {
    
    // MARK: - Properties
    private weak var timer: Timer?
    public var count = 0
    var delegate: SimpleTimerProtocol!
    
    // MARK: - Methods
    
    deinit {
        timer?.invalidate()
    }
    
    func timerHandler(_ timer: Timer) {
        guard self.delegate != nil  else { return }
        self.delegate.timerHandler()
    }
    
    func startTimer() {
        timer?.invalidate()
        let seconds = 2.0
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { timer in
                self.timerHandler(timer)
                self.count+=1
                if(self.count == 5){
                    self.stopTimer()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        self.count = 0
    }
}

/// Displays a loading indicator in the middle of the screen
class LoaderController: NSObject {
    
    // MARK: - Properties
    
    static let sharedInstance = LoaderController()
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Private Methods
    
    private func setupLoader() {
        removeLoader()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
    }
    
    // MARK: - Public Methods
    
    func showLoader() {
        setupLoader()
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let holdingView = appDel.window!.rootViewController!.view!
        
        DispatchQueue.main.async {
            self.activityIndicator.center = holdingView.center
            self.activityIndicator.startAnimating()
            holdingView.addSubview(self.activityIndicator)
        }
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
}



extension Array {
    
    
    /// Shuffles the contents of an array
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count-index)))+index
            if anotherIndex != index {
                elements.swapAt(index, anotherIndex)
            }
        }
        return elements
    }
}

