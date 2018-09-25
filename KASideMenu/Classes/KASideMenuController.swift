//
//  KASideMenu.swift
//  KASideMenu
//
//  Created by ZhihuaZhang on 09/12/2018.
//  Copyright (c) 2018 Kapps Inc. All rights reserved.
//

import UIKit

open class KASideMenuController: UIViewController {
    
    public struct Config {
        public var animationDuration: TimeInterval = 0.2
        public var leftPadding: CGFloat = 60
        public var rightPadding: CGFloat = 60
        public var shadowWidth: CGFloat = 5
        public var shadowOpacity: Float = 0.5
        public var shadowRadius: CGFloat = 5
        public var autoClosePadding: CGFloat?
        public var autoClosePercentage: CGFloat?
        public var closeSpeed: CGFloat = 300
        public var maskViewAlpha: CGFloat = 0.3
    }
    
    open var leftMenuViewController: UIViewController?
    open var centerViewController: UIViewController?
    open var rightMenuViewController: UIViewController?
    
    open func openRight() {
        visableMenuView = rightMenuView
    }
    
    open func openLeft() {
        visableMenuView = leftMenuView
    }
    
    open func closeMenu() {
        visableMenuView = nil
    }
    
    open var config = Config()
    
    private lazy var leftMenuView = KASideMenuView(menuType: .left, padding: config.rightPadding)
    private lazy var rightMenuView = KASideMenuView(menuType: .right, padding: config.leftPadding)
    
    private lazy var menuViews = [leftMenuView, rightMenuView]
    
    private let maskView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.0
        
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private var visableMenuView: KASideMenuView? {
        didSet {
            if let oldValue = oldValue, visableMenuView != oldValue {
                oldValue.close(duration: config.animationDuration)
            }
            
            visableMenuView?.open(duration: config.animationDuration)
            
            let alpha = visableMenuView == nil ? 0.0 : config.maskViewAlpha
            
            UIView.animate(withDuration: config.animationDuration,
                           delay:0.0,
                           options:.curveEaseInOut,
                           animations: {() -> Void in
                            self.maskView.alpha = alpha
            },
                           completion: nil
            )
        }
    }
    
    private var autoClosePercentage: CGFloat {
        if let percentage = config.autoClosePercentage {
            return percentage
        }
        
        if let autoClosePadding = config.autoClosePadding {
            return autoClosePadding / view.bounds.width
        }
        
        return 1 / 2
    }
    
    private var progress: CGFloat = 0.0 {
        didSet {
            let alpha = config.maskViewAlpha * progress
            
            UIView.animate(withDuration: config.animationDuration,
                           delay:0.0,
                           options:.curveEaseInOut,
                           animations: {() -> Void in
                            self.maskView.alpha = alpha
            },
                           completion: nil
            )
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        addCenterViewController()
        addMenuViewController(viewController: leftMenuViewController, type: .left)
        addMenuViewController(viewController: rightMenuViewController, type: .right)
        
        addMaskView()
        setupMenuView()
        addGesture()
    }
    
    private func addCenterViewController() {
        guard let centerViewController = centerViewController else {
            fatalError("need center viewcontroller")
        }
        
        addChild(centerViewController)
        
        let centerView = centerViewController.view!
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerView)
        
        if #available(iOS 9.0, *) {
            centerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            centerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            centerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            centerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        centerViewController.didMove(toParent: self)
    }
    
    private func addMenuViewController(viewController: UIViewController?, type: KASideMenuType) {
        guard let viewController = viewController else { return }
        
        addChild(viewController)
        
        let menuView = menuFor(type: type)
        
        menuView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor.constraint(equalTo: menuView.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: menuView.bottomAnchor).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: menuView.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: menuView.trailingAnchor).isActive = true
        
        viewController.didMove(toParent: self)
    }
    
    //TODO: other way?
    private func menuFor(type: KASideMenuType) -> KASideMenuView {
        switch type {
        case .left:
            return leftMenuView
        case .right:
            return rightMenuView
        }
    }
    
    private func addMaskView() {
        view.addSubview(maskView)
        maskView.frame = view.bounds
    }
    
    private func setupMenuView() {
        menuViews.forEach {
            $0.attachTo(view: view)
            $0.close(animated: false)
        }
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        maskView.addGestureRecognizer(tapGesture)
        //pass the tap event to child
        tapGesture.cancelsTouchesInView = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(menuDragged))
        view.addGestureRecognizer(panGesture)
        panGesture.cancelsTouchesInView = false
    }
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        visableMenuView?.close(animated: true, duration: config.animationDuration)
        visableMenuView = nil
    }
    
    @objc private func menuDragged(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        
        visableMenuView?.move(distance: point.x)
        
        progress = visableMenuView?.progress ?? 0
        
        sender.setTranslation(.zero, in: view)
        
        if sender.state == .ended {
            visableMenuView = isNeedCloseAutomatically(sender) ? nil : visableMenuView
        }
    }
    
    private func isNeedCloseAutomatically(_ gesture: UIPanGestureRecognizer) -> Bool {
        if isCloseGesture(gesture) && abs(gesture.velocity(in: view).x) > config.closeSpeed {
            return true
        }
        
        guard let visableMenuView = visableMenuView else {
            return false
        }
        
        return visableMenuView.currentPadding > view.bounds.width * autoClosePercentage
    }
    
    private func isCloseGesture(_ gesture: UIPanGestureRecognizer) -> Bool {
        return (gesture.velocity(in: view).x < 0 && visableMenuView == leftMenuView) ||
            (gesture.velocity(in: view).x > 0 && visableMenuView == rightMenuView)
    }
}
