//
//  MainViewController.swift
//  IluminateExample
//
//  Created by Bas van Kuijck on 09/02/2024.
//

import Foundation
import UIKit
import EasyPeasy

class MainViewController: UIViewController {
    lazy var mainNavigationController = UINavigationController()
    let bottomBar = BotomBarView()
    var appCoordinator: AppCoordinator!
    
    override func viewDidLoad() {
        addChild(mainNavigationController)
        view.addSubview(mainNavigationController.view)
        super.viewDidLoad()
        let mainView = view!
        
        let newView = UIView()
        newView.addSubview(bottomBar)
        bottomBar.mainViewController = self
        bottomBar.easy.layout(
            Left(),
            Right(),
            Bottom(),
            Height(100)
        )
        newView.addSubview(mainView)
        mainView.easy.layout(
            Left(),
            Top(),
            Right(),
            Bottom().to(bottomBar, .top)
        )
        view = newView
    }
}

class BotomBarView: UIView {
    weak var mainViewController: MainViewController?
    
    private var buttons: [UIButton] = []
    
    private var index = 0
    // MARK: - Initialization
    // --------------------------------------------------------
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.gray
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        
        addSubview(stack)
        buttons = [
            UIButton.systemButton(with: UIImage(systemName: "iphone.radiowaves.left.and.right.circle")!, target: self, action: #selector(tapButton1)),
            UIButton.systemButton(with: UIImage(systemName: "ev.plug.ac.type.2")!, target: self, action: #selector(tapButton2)),
            UIButton.systemButton(with: UIImage(systemName: "m3.button.horizontal")!, target: self, action: #selector(tapButton3)),
            UIButton.systemButton(with: UIImage(systemName: "bubble.middle.bottom")!, target: self, action: #selector(tapButton4))
        ]
        stack.addArrangedSubview(buttons[0])
        stack.addArrangedSubview(buttons[1])
        stack.addArrangedSubview(buttons[2])
        stack.addArrangedSubview(buttons[3])
        stack.easy.layout(Edges())
        buttons[0].tintColor = UIColor.yellow
    }
    
    private func reset() {
        buttons[0].tintColor = UIColor.blue
        buttons[1].tintColor = UIColor.blue
        buttons[2].tintColor = UIColor.blue
        buttons[3].tintColor = UIColor.blue
    }
    
    private func load(_ title: String, _ color: UIColor, _ newIndex: Int) {
        reset()
        mainViewController?.appCoordinator.startTab(coordinator: View1Coordinator(title: title, color: color), at: newIndex, reset: newIndex == 2)
        buttons[newIndex].tintColor = UIColor.yellow
    }
    
    @objc
    private func tapButton1() {
        load("Numero uno", .red, 0)
        index = 0
    }
    
    @objc
    private func tapButton2() {
        load("Twee", .orange, 1)
        index = 1
    }
    
    @objc
    private func tapButton3() {
        load("Pink", .cyan, 2)
        index = 2
    }
    
    @objc
    private func tapButton4() {
        load("Iets hel anders", .gray, 3)
        index = 3
    }
}
