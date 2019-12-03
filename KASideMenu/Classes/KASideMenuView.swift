//
//  KASideMenuView.swift
//  KASideMenu
//
//  Created by ZhihuaZhang on 09/12/2018.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit

enum KASideMenuType {
    case left, right
}

class KASideMenuView: UIView {
    
    private var menuType: KASideMenuType
    private var padding: CGFloat
    private var paddingConstraint: NSLayoutConstraint!
    private var shadowWidth: CGFloat
    private var shadowOpacity: Float
    private var shadowRadius: CGFloat
    
    var progress: CGFloat {
        guard let superview = superview else {
            return 0
        }
        
        return (superview.bounds.width - paddingConstraint.constant) / (superview.bounds.width - padding)
    }
    
    var currentPadding: CGFloat {
        return paddingConstraint.constant
    }
    
    init(menuType: KASideMenuType,
         padding: CGFloat,
         shadowWidth: CGFloat = 5.0,
         shadowOpacity: Float = 0.5,
         shadowRadius: CGFloat = 5.0) {
        self.menuType = menuType
        self.padding = padding
        self.shadowWidth = shadowWidth
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addGesture()
        
        addShadowForMenu()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attachTo(view: UIView) {
        view.addSubview(self)
        
        if #available(iOS 9.0, *) {
            topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            widthAnchor.constraint(equalTo: view.widthAnchor, constant: -padding).isActive = true
            
            if menuType == .left {
                paddingConstraint = view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: padding)
            } else {
                paddingConstraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding)
            }
            
            paddingConstraint.isActive = true
        }
    }
    
    func open(animated: Bool = true, duration: TimeInterval = 0.0) {
        showShadow()
        updatePosition(constant: padding, animated: animated, duration: duration)
    }
    
    func close(animated: Bool = true, duration: TimeInterval = 0.0) {
        guard let superview = superview else {
            return
        }
        
        updatePosition(constant: superview.bounds.width, animated: animated, duration: duration)
        
        //hide shadow after the menu has been closed
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hideShadow()
        }
    }
    
    func move(distance: CGFloat) {
        let constant = menuType == .left ? paddingConstraint.constant - distance :
            paddingConstraint.constant + distance
        
        updatePosition(constant: max(padding, constant), animated: false)
    }
    
    private func addShadowForMenu() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: menuType == .left ? shadowWidth : -shadowWidth, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.0
        layer.shadowRadius = shadowRadius
    }
    
    private func showShadow() {
        layer.shadowOpacity = shadowOpacity
    }
    
    private func hideShadow() {
        layer.shadowOpacity = 0.0
    }
    
    private func updatePosition(constant: CGFloat, animated: Bool, duration: TimeInterval = 0) {
        guard let superview = superview else {
            return
        }
        
        paddingConstraint.constant = constant
        
        if animated {
            UIView.animate(withDuration: duration,
                           delay:0.0,
                           options:.curveEaseInOut,
                           animations: {() -> Void in
                            superview.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {}
}
