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

    var menuType: KASideMenuType
    var padding: CGFloat
    var paddingConstraint: NSLayoutConstraint!
    
    var progress: CGFloat {
        guard let superview = superview else {
            return 0
        }
        
        return (superview.bounds.width - paddingConstraint.constant) / (superview.bounds.width - padding)
    }
    
    var currentPadding: CGFloat {
        return paddingConstraint.constant
    }
    
    init(menuType: KASideMenuType, padding: CGFloat) {
        self.menuType = menuType
        self.padding = padding
        
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        
        addGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attachTo(view: UIView) {
        view.addSubview(self)
        
        //TODO: delete this
        backgroundColor = .red
        
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
        updatePosition(constant: padding, animated: animated, duration: duration)
    }
    
    func close(animated: Bool = true, duration: TimeInterval = 0.0) {
        guard let superview = superview else {
            return
        }
        
        updatePosition(constant: superview.bounds.width, animated: animated, duration: duration)
    }
    
    func move(distance: CGFloat) {
        print(distance)
        
        let constant = menuType == .left ? paddingConstraint.constant - distance :
            paddingConstraint.constant + distance
        
        updatePosition(constant: max(padding, constant), animated: false)
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
            },
                           completion: nil
            )
        }
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {}
}
