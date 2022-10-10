# Injection

A helper property wrapper for Swinject's DI service


## Usage 

### Regular

Service will be created / fetched when the surrounding class/struct is initialized

```swift
@Injected private var userSessionService: UserSessionManageable
```

### Lazy

Service will be created / fetched when the variable is accessed

```swift
@LazyInjected private var userSessionService: UserSessionManageable
```