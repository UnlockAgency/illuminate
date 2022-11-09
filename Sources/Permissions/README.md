# Permissions

A helper module to ask for users permissions 

## Implementation

### Get the current permission state

```swift
let permissionManager = PermissionManager()
permissionManager.getPermission(for: .notifications).sink { (status: PermissionStatus) in 
    // ...
}.store(in: &cancellables)

```
### Request permission

```swift
let permissionManager = PermissionManager()
permissionManager.requestPermission(for: .notifications).sink { (status: PermissionStatus) in 
    // ...
}.store(in: &cancellables)

```
