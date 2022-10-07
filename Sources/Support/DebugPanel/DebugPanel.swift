//
//  File.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation

#if !RELEASE
import UIKit
#if canImport(Firebase)
import Firebase
#endif
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif
#if canImport(FirebaseInstallations)
import FirebaseInstallations
#endif

private extension Bundle {
    var version: String {
        return (self.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    }
    
    var build: String {
        return (self.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
    }
}

private struct DebugRow: Equatable {
    let key: String
    let value: ((@escaping (String?) -> Void) -> Void)
    
    static func == (lhs: DebugRow, rhs: DebugRow) -> Bool {
        return lhs.key == rhs.key
    }
}

private class DebugRowButton {
    let title: String
    let action: () -> Void
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

open class DebugPanel {
    public static let instance = DebugPanel()
    fileprivate var rows: [DebugRow] = []
    fileprivate var buttons: [DebugRowButton] = []
    
    private weak var navigationController: UINavigationController?
    
    private init() {
        
    }
    
    open func present(in viewController: UIViewController) {
        if self.navigationController != nil {
            return
        }
        print("[IlluminateSupport] Presenting debug panel...")
        let panelViewController = DebugPanelViewController()
        let navigationController = UINavigationController(rootViewController: panelViewController)
        viewController.present(navigationController, animated: true)
        self.navigationController = navigationController
        navigationController.navigationBar.topItem?.title = "Debug panel"
        navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
    }
    
    public func add(key: String, value: @escaping (@escaping (String?) -> Void) -> Void) {
        let row = DebugRow(key: key, value: value)
        if let index = rows.firstIndex(where: { $0 == row }) {
            rows.remove(at: index)
            rows.insert(row, at: index)
        } else {
            rows.append(row)
        }
    }
    
    public func add(key: String, value: String?) {
        add(key: key) { $0(value) }
    }
    
    public func addButton(title: String, action: @escaping (() -> Void)) {
        buttons.append(DebugRowButton(title: title, action: action))
    }
    
    public func dismiss() {
        navigationController?.dismiss(animated: true)
        navigationController = nil
    }
}

private class DebugPanelViewController: UIViewController {
    private let stackView = UIStackView()
    private var weakMap = NSMapTable<UIButton, DebugRowButton>(keyOptions: .weakMemory, valueOptions: .weakMemory)
    private lazy var logButton: DebugRowButton = {
        DebugRowButton(title: "Open logs") { [weak self] in
            let textViewController = LargeTextViewController(text: DebugPanelLogHandler.logLines.joined(separator: "\n"))
            textViewController.title = "Logs"
            let navigationViewController = UINavigationController(rootViewController: textViewController)
            self?.present(navigationViewController, animated: true, completion: nil)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(tapClose))
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        stackView.axis = .vertical
        stackView.spacing = 10
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
        
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        stackView.addArrangedSubview(label)
        setupRows()
    }
    
    private func setupRows() {
        var rows = DebugPanel.instance.rows
        
#if canImport(FirebaseMessaging)
        rows.insert(DebugRow(key: "FCM-token") { $0(Messaging.messaging().fcmToken) }, at: 0)
#endif
        
#if canImport(FirebaseInstallations)
        rows.insert(DebugRow(key: "Firebase Installation ID") { handler in
            Installations.installations().installationID { installationID, _ in
                handler(installationID)
            }
        }, at: 0)
#endif
        
        rows.insert(DebugRow(key: "App version") { $0("\(Bundle.main.version) (build \(Bundle.main.build))") }, at: 0)
        rows.insert(DebugRow(key: "Bundle identifier") { $0(Bundle.main.bundleIdentifier) }, at: 0)
        
        for row in rows {
            let rowView = DebugPanelRowView(row: row)
            rowView.debugPanelViewController = self
            stackView.addArrangedSubview(rowView)
        }
        
        for button in DebugPanel.instance.buttons {
            addButton(button)
        }
        addButton(logButton)
    }
    
    private func addButton(_ button: DebugRowButton) {
        let buttonInstance = UIButton(type: .system)
        weakMap.setObject(button, forKey: buttonInstance)
        buttonInstance.tintColor = UIColor.systemBlue
        buttonInstance.setTitle(button.title, for: .normal)
        buttonInstance.layer.borderColor = UIColor.systemBlue.cgColor
        buttonInstance.layer.cornerRadius = 5
        buttonInstance.layer.borderWidth = 1
        stackView.addArrangedSubview(buttonInstance)
        buttonInstance.translatesAutoresizingMaskIntoConstraints = false
        buttonInstance.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonInstance.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
    }
    
    @objc
    private func tapButton(_ sender: UIButton) {
        weakMap.object(forKey: sender)?.action()
    }
    
    @objc
    private func tapClose() {
        navigationController?.dismiss(animated: true)
    }
}

private class DebugPanelRowView: UIView {
    let stackView = UIStackView()
    private var row: DebugRow!
    private var rawValue: String?
    weak var debugPanelViewController: DebugPanelViewController?
    private let copyButton = UIButton(type: .system)
    private var copyButtonWidthConstraint: NSLayoutConstraint?
    
    convenience init(row: DebugRow) {
        self.init()
        self.row = row
        setup()
    }
    
    private func setup() {
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.spacing = 5
        
        let keyView = UIStackView()
        stackView.addArrangedSubview(keyView)
        
        let keyLabel = UILabel()
        keyLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        keyLabel.numberOfLines = 1
        keyLabel.text = row.key
        keyView.addSubview(keyLabel)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.leftAnchor.constraint(equalTo: keyView.leftAnchor).isActive = true
        keyLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true
        keyLabel.topAnchor.constraint(equalTo: keyView.topAnchor).isActive = true
        keyLabel.bottomAnchor.constraint(equalTo: keyView.bottomAnchor).isActive = true
        
        keyView.addSubview(copyButton)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.leftAnchor.constraint(equalTo: keyLabel.rightAnchor, constant: 5).isActive = true
        copyButton.centerYAnchor.constraint(equalTo: keyView.centerYAnchor).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        copyButtonWidthConstraint = copyButton.widthAnchor.constraint(equalToConstant: 16)
        copyButtonWidthConstraint?.isActive = true
        copyButton.contentHorizontalAlignment = .left
        copyButton.addTarget(self, action: #selector(tapCopy), for: .touchUpInside)
        setupValue()
    }
    
    private func setCopyButtonText(value: String) {
        copyButton.isHidden = value.isEmpty
        if value.count > 64 {
            copyButton.setTitle("View", for: .normal)
            copyButtonWidthConstraint?.constant = 64
            return
        }
        copyButtonWidthConstraint?.constant = 16
        if #available(iOS 13.0, *) {
            copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        } else {
            copyButton.setTitle("Copy", for: .normal)
        }
    }
    
    private func setupValue() {
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 15)
        valueLabel.numberOfLines = 0
        valueLabel.text = "..."
        stackView.addArrangedSubview(valueLabel)
        
        row.value { [weak self, valueLabel] string in
            self?.rawValue = string
            let aString = string ?? ""
            if aString.count > 64 || aString.contains("\n") {
                valueLabel.text = "<data>"
            } else {
                valueLabel.text = aString.isEmpty ? "(nil)" : aString
            }
            self?.setCopyButtonText(value: aString)
            valueLabel.alpha = aString.isEmpty ? 0.5 : 1
        }
        
        var line = UIView()
        line.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(line)
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        line = UIView()
        line.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        stackView.addArrangedSubview(line)
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc
    private func tapCopy() {
        if copyButton.title(for: .normal) == "View" {
            let textViewController = LargeTextViewController(text: rawValue ?? "")
            textViewController.title = row.key
            let navigationViewController = UINavigationController(rootViewController: textViewController)
            debugPanelViewController?.present(navigationViewController, animated: true, completion: nil)
            return
        }
        
        UIPasteboard.general.string = rawValue
        backgroundColor = UIColor.yellow
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = UIColor.clear
        }
    }
}

private class LargeTextViewController: UIViewController {
    let textView = UITextView()
    
    convenience init(text: String) {
        self.init(nibName: nil, bundle: nil)
        textView.text = text
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(tapClose))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(tapClose))
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Copy", style: .plain, target: self, action: #selector(tapCopy))
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc
    private func tapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func tapCopy() {
        UIPasteboard.general.string = textView.text
    }
}
#else
open class DebugPanel {
    public static let instance = DebugPanel()
    
    public func add(key: String, value: @escaping (@escaping (String?) -> Void) -> Void) {
        
    }
    
    public func addButton(title: String, action: @escaping (() -> Void)) {
        
    }
}
#endif
