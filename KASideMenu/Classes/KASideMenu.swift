//
//  KASideMenu.swift
//  KASideMenu
//
//  Created by ZhihuaZhang on 09/12/2018.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit

open class KASideMenu: UIViewController {

    public struct Config {
        public var leftPadding: CGFloat = 60
        public var rightPadding: CGFloat = 60
        public var shadowWidth: CGFloat = 5
        public var shadowOpacity: Float = 0.5
        public var shadowRadius: CGFloat = 5
        public var thresholdWidth: CGFloat?
        public var thresholdPercentage: CGFloat?
    }
    
    open var leftViewController: UIViewController?
    open var centerViewController: UIViewController?
    open var rightViewController: UIViewController?
    
    open func showRight() {
        state = .rightMenuVisible
    }
    
    open func showLeft() {
        state = .leftMenuVisible
    }
    
    open func closeMenu() {
        state = .centerVisible
    }
    
    open var config = Config()
    
    private var rightMenuPadding: NSLayoutConstraint?
    private var leftMenuPadding: NSLayoutConstraint?
    
    private enum SideMenuState {
        case centerVisible, leftMenuVisible, rightMenuVisible
    }
    
    private var state: SideMenuState = .centerVisible {
        didSet {
            switch state {
            case .centerVisible:
                leftMenuPadding?.constant = view.bounds.width
                rightMenuPadding?.constant = view.bounds.width
            case .leftMenuVisible:
                leftMenuPadding?.constant = config.rightPadding
            case .rightMenuVisible:
                rightMenuPadding?.constant = config.leftPadding
            }
            
            UIView.animate(withDuration: 0.15,
                           delay:0.0,
                           options:.curveEaseInOut,
                           animations: {() -> Void in
                            self.view.layoutIfNeeded()
            },
                           completion: nil
            )
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        addCenterViewController()
        addLeftMenu()
        addRightMenu()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        //pass the tap event to child
        tapGesture.cancelsTouchesInView = false
        
        if config.thresholdWidth == nil && config.thresholdPercentage == nil {
            config.thresholdPercentage = 1 / 2
        } else if let width = config.thresholdWidth, config.thresholdPercentage == nil {
            config.thresholdPercentage = width / view.bounds.width
        }
    }

    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        if isTappedOutsideTheMenu(sender) {
            closeMenu()
        }
    }
    
    private func isTappedOutsideTheMenu(_ sender: UITapGestureRecognizer) -> Bool {
        let location = sender.location(in: view)
        
        if state == .rightMenuVisible {
            return location.x < config.leftPadding
        }
        
        if state == .leftMenuVisible {
            return abs(view.bounds.width - location.x) < config.rightPadding
        }
        
        return false
    }
    
    private func addCenterViewController() {
        guard let centerViewController = centerViewController else {
            fatalError("need center viewcontroller")
        }
        
        addChildViewController(centerViewController)
        
        let centerView = centerViewController.view!
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerView)
        
        if #available(iOS 9.0, *) {
            centerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            centerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            centerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            centerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        }
        
        centerViewController.didMove(toParentViewController: self)
    }
    
    private func addLeftMenu() {
        if let leftViewController = leftViewController {
            addChildViewController(leftViewController)
            
            let leftView = leftViewController.view!
            leftView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(leftView)
            
            if #available(iOS 9.0, *) {
                leftView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
                leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
                leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
                leftMenuPadding = view.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: view.bounds.width)
                leftMenuPadding?.isActive = true
            }
            
            leftViewController.didMove(toParentViewController: self)
            
            setupMenu(menu: leftView, isLeft: true)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(menuDragged))
            leftView.addGestureRecognizer(panGesture)
        }
    }
    
    private func addRightMenu() {
        if let rightViewController = rightViewController {
            addChildViewController(rightViewController)
            
            let rightView = rightViewController.view!
            rightView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(rightView)
            
            if #available(iOS 9.0, *) {
                rightView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
                rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
                rightMenuPadding = rightView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width)
                rightMenuPadding?.isActive = true
                rightView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            }
            
            rightViewController.didMove(toParentViewController: self)
            
            setupMenu(menu: rightView, isLeft: false)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(menuDragged))
            rightView.addGestureRecognizer(panGesture)
        }
    }
    
    private func setupMenu(menu: UIView, isLeft: Bool) {
        let layer = menu.layer
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: isLeft ? config.shadowWidth : -config.shadowWidth, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = config.shadowOpacity;
        layer.shadowRadius = config.shadowRadius;
    }
    
    @objc private func menuDragged(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        
        if state == .rightMenuVisible {
            let constant = rightMenuPadding!.constant + point.x
            rightMenuPadding?.constant = max(0, constant)
        } else if state == .leftMenuVisible {
            let constant = leftMenuPadding!.constant - point.x
            leftMenuPadding?.constant = max(0, constant)
        }
        
        sender.setTranslation(.zero, in: view)
        
        if sender.state == .ended {
            state = isNeedCloseAutomatically(menuCenter: sender.view!.center) ? .centerVisible : state
        }
    }
    
    private func isNeedCloseAutomatically(menuCenter: CGPoint) -> Bool {
        guard let percentage = config.thresholdPercentage else {
            return false
        }
        
        let padding = state == .leftMenuVisible ? leftMenuPadding : rightMenuPadding
        let visibleMenuWidth = abs(view.bounds.width - padding!.constant)
        
        print(visibleMenuWidth)
        
        return visibleMenuWidth < view.bounds.width * percentage
    }

}
