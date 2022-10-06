# Security

Securing the contents of your app by asking the user to authenticate themselves using either a pincode or biometric authentication.  

## Setup

### Provider

Create a SecurityProvider for your app and make sure it inherits from `SecurityProvider`. It enables you to configure the settings for your app.

```swift
import IlluminateSecurity

class Provider: SecurityProvider {
    var biometricAuthenticationMessage: String? {
        return "Secure your app with biometric authentication"
    }
    
    var biometricSecurityKeychainItemName: String? {
        // The name of the secured keychain item for biometric security
        return "keychain-key"
    }
    
    var userIdentifier: String? {
        // "An" ID of the user currently signed in.
        // This is used to store the secured keychain item related to the user.
        return "1"
    }
    
    var sessionLifetime: Int? {
        // The duration in seconds of the session in which the user doesn't have to go through the security screen again.
        // This is optional. Return `nil` to show the screen only once during an app session.
        return nil
    }
    
    func securityType() -> SecurityType? {
        // Return the selected security type from UserDefaults or Keychain
        return .code
    }
    
    func setSecurityType(_ securityType: SecurityType?) {
        // Store the selected type of security in UserDefaults or Keychain
    }
    
    func didSetPinCode(_ code: String?) {
        // Store the pincode in Keychain
    }
    
    func getPinCode() -> String? {
        // Retrieve the pincode from Keychain
        return "1234"
    }
}
```

### Manager

Your provider is then passed onto your general `SecurityManager`. Make sure there's only one instance used in your app. 

```swift
import IlluminateSecurity

let manager = SecurityManager(provider: Provider())
```

The manager provides methods to trigger the authentication view, either biometric or asking for a pincode.

### AuthenticationDelegate 

We need to register a presenter, which is responsible for presenting and dismissing the security code view, if used in your app. Make sure it inherits from `SecurityAuthenticationDelegate`

```swift 
import IlluminateSecurity

class AuthenticationViewPresenter: SecurityAuthenticationDelegate {
        
    func presentSecurityCodeView(in viewController: UIViewController) -> AnyPublisher<AuthenticationResult, Never> {
        // ... 
    }
    
    func dismissSecurityCodeView(withResult result: AuthenticationResult) {
        // ...
    }
}
```

## Usage

### Pincode authentication

Say for instance, you've got a view which triggers the authentication process when the user presses a button:

```swift
import SwiftUI

struct ContentView: View {
    let viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Button {
                viewModel.presentAuthenticationView()
            } label: {
                Text("open security code view")
            }
        }
        .padding()
    }
}
```

Your `ViewModel` could look something like this:

```swift
import SwiftUI
import IlluminateSecurity
import Combine

class ViewModel: ObservableObject {
    let authenticationViewPresenter = AuthenticationViewPresenter()
    let manager = SecurityManager(provider: Provider())
    var cancellables = Set<AnyCancellable>()
    
    init() {
        manager.authenticationDelegate = authenticationViewPresenter
    }
    
    func presentAuthenticationView() {
        manager.present(in: UIViewController.upmost!)
            .sink { result in
                print("Result of authentication view: \(result)")
            }
            .store(in: &cancellables)
    }
}
```

When pressing the button, the `SecurityManager` will present the security code view, or biometric scan dialog. This depends on the settings in the provider.

As you can see, we're registering our `AuthenticationViewPresenter`, which has been enhanced to show the user the security code view:

```swift
import IlluminateSecurity
import Combine
import UIKit
import SwiftUI

class AuthenticationViewPresenter: SecurityAuthenticationDelegate {
    
    private var navigationController: UINavigationController?
    
    @Published var result: AuthenticationResult = .pending
    
    func presentSecurityCodeView(in viewController: UIViewController) -> AnyPublisher<AuthenticationResult, Never> {
        self.navigationController = UINavigationController(
            rootViewController: UIHostingController(
                rootView: SecurityCodeView() { [weak self] result in
                    self?.result = result
                }
            )
        )
        
        viewController.present(self.navigationController!, animated: true)
        
        return $result.eraseToAnyPublisher()
    }
    
    func dismissSecurityCodeView(withResult result: AuthenticationResult) {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.result = .pending
        }
    }
}
```

You're free to design your own `SecurityCodeView`. You could also use the validation method inside the manager to validate the code the user provided.

```swift
import Foundation
import SwiftUI
import IlluminateSecurity

struct SecurityCodeView: View {
    
    private let onTap: (AuthenticationResult) -> Void
    
    init(onTap: @escaping (AuthenticationResult) -> Void) {
        self.onTap = onTap
    }
    
    var body: some View {
        VStack {
            Button {
                onTap(.successful)
            } label: {
                Text("Successful")
            }
                     
            Button {
                onTap(.cancelled)
            } label: {
                Text("Cancelled")
            }
        }
    }
}
```

The result will be returned to your viewModel, where you can either push the following view to the user, or present a dialog staging an error message.
