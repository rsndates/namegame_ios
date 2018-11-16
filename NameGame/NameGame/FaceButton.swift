//
//  FaceButton.swift
//  NameGame
//
//  Created by Intern on 3/11/16.
//  Copyright © 2016 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

protocol FaceButtonProtocol: NSObjectProtocol {
    func exploreEmpoyeeSocial(social: Social)
}

open class FaceButton: UIButton {
    
    var id: Int = 0
    var tintView: UIView = UIView(frame: CGRect.zero)
    var employee: Employee!
    var delegate: FaceButtonProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func setup() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.7
        self.addGestureRecognizer(longPressGesture)
        
        layer.cornerRadius = 5
        
        setTitleColor(.white, for: .normal)
        titleLabel?.alpha = 0.0
        
        tintView.alpha = 0.0
        tintView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tintView)
        
        tintView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tintView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tintView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tintView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    public func handleLongPress(_ longPress: UILongPressGestureRecognizer!)  {
        if let social = self.employee.socialLinks.first as? Social, self.delegate != nil {
            self.delegate.exploreEmpoyeeSocial(social: social)
        }
    }
    
    func showUsersFace(employee: Employee, group: DispatchGroup) {
        guard let urlString = employee.headshot.url,
            let url = URL(string: "https:" + urlString) else { return }
        self.employee = employee
        group.enter()
        Networking.imageRequest(url: url) { (data:Data) in
            if !self.employee.socialLinks.isEmpty{
                self.layer.borderColor = UIColor(red: 64/255, green: 232/255, blue: 211/255, alpha: 0.6).cgColor
                self.layer.borderWidth = 4
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0
            }
            self.layoutIfNeeded()
            let cropImage: UIImage = self.cropToBounds(image: UIImage(data: data) ?? UIImage(), width: 340, height: 340)
            let scaledImage = cropImage.scaleImage(to: CGSize(width: 340, height: 340))
            self.setImage(scaledImage, for: .normal)
            
            group.leave()
        }
    }
    
    public func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var positionX: CGFloat = 0.0
        var positionY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        if contextSize.width > contextSize.height {
            positionX = ((contextSize.width - contextSize.height) / 2)
            positionY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            positionX = 0
            positionY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        let rect: CGRect = CGRect(x: positionX, y: positionY, width: cgwidth, height: cgheight)
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return image
    }
}

extension UIImage {
    func scaleImage(to newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let currentGraphicContext = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            currentGraphicContext.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            currentGraphicContext.concatenate(flipVertical)
            currentGraphicContext.draw(cgImage, in: newRect)
            if let image = currentGraphicContext.makeImage() {
                newImage = UIImage(cgImage: image)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}


