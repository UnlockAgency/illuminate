# Support

Appreciate the small things. 

## DebugPanel

### Implementation

**MainViewController.swift**

```swift
override func viewDidLoad() {
    super.viewDidLoad()        
    #if !RELEASE
    becomeFirstResponder()
    #endif
}
    
#if !RELEASE
override var canBecomeFirstResponder: Bool {
    return true
}

override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
        DebugPanel.instance.present(in: self)
    }
}
#endif
```

### Usage

```swift
func add(key: String, value: @escaping (@escaping (String?) -> Void) -> Void)
```