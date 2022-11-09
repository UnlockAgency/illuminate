# Keychain

A small helper and property wrapper for managing keychain stored values.


## Usage 

### Property wrapper

```swift
public class UserSessionManager {
    @KeychainStore(service: "nl.app.user", key: "current-user") private(set) var user: User?
}
```

```swift
struct User: Codable {
	let id: String
	let email: String
}
```