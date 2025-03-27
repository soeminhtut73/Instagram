//
//  Extension.swift
//  Instagram
//
//  Created by S M H  on 10/12/2024.
//

import UIKit
import JGProgressHUD


extension UIViewController {
    static let hud = JGProgressHUD(style: .dark)
    
    func configureGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    func showLoader(_ show: Bool) {
        view.endEditing(true)
        
        if show {
            UIViewController.hud.textLabel.text = "Loading..."
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss(afterDelay: 1.5, animated: true)
        }
    }
    
    func showMessage(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UIButton {
    func attributedTitle(firstPart: String, secondPart: String) {
        let atts: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.87), .font: UIFont.systemFont(ofSize: 16)]
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: atts)
        
        let boldAtts: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.87), .font: UIFont.boldSystemFont(ofSize: 16)]
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: boldAtts))
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
}

extension UILabel {
    func attributedLabel(firstPart: String, secondPart: String, timestamp: String) {
        let boldAtts: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 13)]
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: boldAtts)
        
        let atts: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 13)]
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: atts))
        
        attributedTitle.append(NSAttributedString(string: " \(timestamp)", attributes: [.foregroundColor : UIColor.lightGray, .font : UIFont.systemFont(ofSize: 11)]))
        
        attributedText = attributedTitle
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor, left: view.leftAnchor,
               bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func configureGradientLayer() {
        /// configure gradient backgroundColor
        let gradientLayer = CAGradientLayer()
        let gradientColors: [CGColor] = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
         
//        let animation = CABasicAnimation(keyPath: "colors")
//        animation.fromValue = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
//        animation.toValue = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
//        animation.duration = 9.0
//        animation.autoreverses = true
//        animation.repeatCount = .infinity
//        gradientLayer.add(animation, forKey: nil)
    }
    
    // Start skeleton animation on this view
    func showSkeletonAnimation() {
        // Remove any existing skeleton layers first
        hideSkeletonAnimation()
        
        // Create a gradient layer for the skeleton effect
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "SkeletonLayer"
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.masksToBounds = true
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.3).cgColor,
            UIColor.lightGray.withAlphaComponent(0.7).cgColor,
            UIColor.lightGray.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Add the gradient layer to the view's layer hierarchy
        self.layer.addSublayer(gradientLayer)
        
        // Create the animation for the gradient's locations
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        gradientLayer.add(animation, forKey: "skeletonAnimation")
    }
    
    // Remove the skeleton animation
    func hideSkeletonAnimation() {
        self.layer.sublayers?.removeAll(where: { $0.name == "SkeletonLayer" })
    }
    
    // Update the gradient frame in case the view’s bounds change
    func updateSkeletonFrame() {
        self.layer.sublayers?.forEach { layer in
            if layer.name == "SkeletonLayer" {
                layer.frame = self.bounds
            }
        }
    }
    
}



