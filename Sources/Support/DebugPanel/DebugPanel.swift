//
//  File.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation

#if !RELEASE
import Foundation

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

class DebugPanel {
    static let instance = DebugPanel()
    fileprivate var rows: [DebugRow] = []
    fileprivate var buttons: [DebugRowButton] = []
    
    private weak var navigationController: UINavigationController?
    
    private init() {
        
    }
    
    func present(in viewController: UIViewController) {
        if self.navigationController != nil {
            return
        }
        logger.info("Presenting debug panel...")
        let panelViewController = DebugPanelViewController()
        let navigationController = UINavigationController(rootViewController: panelViewController)
        viewController.present(navigationController, animated: true)
        self.navigationController = navigationController
        navigationController.navigationBar.topItem?.title = "Debug panel"
        navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
    }
    
    func add(key: String, value: @escaping (@escaping (String?) -> Void) -> Void) {
        let row = DebugRow(key: key, value: value)
        if let index = rows.firstIndex(where: { $0 == row }) {
            rows.remove(at: index)
            rows.insert(row, at: index)
        } else {
            rows.append(row)
        }
    }
    
    func dismiss() {
        navigationController?.dismiss(animated: true)
        navigationController = nil
    }
    
    func add(key: String, value: String?) {
        add(key: key) { $0(value) }
    }
    
    func addButton(title: String, action: @escaping (() -> Void)) {
        buttons.append(DebugRowButton(title: title, action: action))
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
        scrollView.easy.layout(Edges())
        
        stackView.axis = .vertical
        stackView.spacing = 10
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.easy.layout(
            Edges(),
            Width().like(scrollView, .width)
        )
        
        contentView.addSubview(stackView)
        stackView.easy.layout(
            Edges(12)
        )
        
        let label = UILabel {
            $0.text = title
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }
        stackView.addArrangedSubview(label)
        setupRows()
    }
    
    private func setupRows() {
        var rows = DebugPanel.instance.rows
        
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
        buttonInstance.easy.layout(Height(44))
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
    
    convenience init(row: DebugRow) {
        self.init()
        self.row = row
        setup()
    }
    
    private func setup() {
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.easy.layout(Edges())
        stackView.spacing = 5
        
        let keyView = UIStackView()
        stackView.addArrangedSubview(keyView)
        
        let keyLabel = UILabel {
            $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            $0.numberOfLines = 1
            $0.text = row.key
        }
        keyView.addSubview(keyLabel)
        keyLabel.easy.layout(
            Top(),
            Left(),
            Bottom(),
            Height(>=16)
        )
        keyView.addSubview(copyButton)
        copyButton.easy.layout(
            Height(16),
            Width(16),
            CenterY(),
            Left(5).to(keyLabel, .right)
        )
        copyButton.addTarget(self, action: #selector(tapCopy), for: .touchUpInside)
        setupValue()
    }
    
    private func setCopyButtonText(value: String) {
        copyButton.isHidden = value.isEmpty
        if value.count > 64 {
            copyButton.setTitle("View", for: .normal)
            copyButton.easy.layout(
                Width(64)
            )
            return
        }
        copyButton.easy.layout(
            Width(16)
        )
        if #available(iOS 13.0, *) {
            copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        } else {
            copyButton.setTitle("Copy", for: .normal)
        }
    }
    
    private func setupValue() {
        let valueLabel = UILabel {
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.numberOfLines = 0
            $0.text = "..."
        }
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
        line.easy.layout(Height(1))
        
        line = UIView()
        line.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        stackView.addArrangedSubview(line)
        line.easy.layout(Height(1))
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
        textView.easy.layout(Edges())
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
class DebugPanel {
    static let instance = DebugPanel()
    func add(key: String, value: @escaping (@escaping (String?) -> Void) -> Void) {
        
    }
    
    func addButton(title: String, action: @escaping (() -> Void)) {
        
    }
}
#endif
