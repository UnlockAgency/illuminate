# Coordination

## Basic implementation

> A single UINavigationController implementation where each view(controller) is pushed or set in the main stack.

```
┌───────────────────────────┐
│ MainNavigationController  │
│ ┌───────────────────────┐ │
│ │ BaseViewController    │ │
│ └───────────────────────┘ │
└───────────────────────────┘
```

**AppCoordinator.swift**

```swift
class AppCoordinator: BaseCoordinator {    
    private lazy var mainNavigationController = MainNavigationController()
    
    func setup(with window: UIWindow?) {
        navigationController = mainNavigationController
        
        window?.rootViewController = mainController
        window?.makeKeyAndVisible()
    }

    override init() {
        super.init()        
        setupDependencyInjection()
        // ...
    }
}
```

**DashboardCoordinator.swift**

```swift
class DashboardCoordinator: BaseCoordinator {
    override func start() {
        let viewModel = DashboardViewModel()
        let controller = displayHostingController(
            type: DashboardView,
            viewModel: viewModel
        ) { rootView in 
        	BaseViewController(rootView: rootView)
        }
        controller.title = "Dashboard"
    }
}
```

**DashboardView.swift**

```swift
import SwiftUI
import Combine
import IlluminateCoordination

struct DashboardView: View, ViewModelControllable {
    @ObservedObject private(set) var viewModel: DashboardViewModel
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }
}
```

**DashboardViewModel.swift**

```swift
class DashboardViewModel: BaseViewModel {

}
```

## Tabbar implementation

> Every tab bar item as a separate navigation stack.   
> That way the navigation state for each tabbar item is retained.

```
┌───────────────────────────────────────────────────────────┐
│ MainController                                            │
│ ┌──────────────────────────┐ ┌──────────────────────────┐ │
│ │ BaseNavigationController │ │ BaseNavigationController │ │
│ │ ┌──────────────────────┐ │ │ ┌──────────────────────┐ │ │
│ │ │ BaseViewController   │ │ │ │ BaseViewController   │ │ │
│ │ └──────────────────────┘ │ │ └──────────────────────┘ │ │
│ └──────────────────────────┘ └──────────────────────────┘ │
└───────────────────────────────────────────────────────────┘
```

**AppCoordinator.swift**

```swift
class AppCoordinator: TabbarCoordinator {
    private lazy var mainController = MainViewController()
    
    func setup(with window: UIWindow?) {
        navigationController = mainController.mainNavigationController
        
        window?.rootViewController = mainController
        window?.makeKeyAndVisible()
    }
    
    @MainActor
    func bottomBar(didSelectItem item: BottomBarItem) {
        startTab(
	        coordinator: item.coordinator(), 
	        at: item.rawValue, 
	        reset: item.shouldResetNavigationStack
        )
    }
}
```