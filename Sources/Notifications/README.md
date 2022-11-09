# Notifications

Handle (remote) notifications

## Implementation

### Setup

```swift
notificationService.logger = logger
notificationService.registerDeviceHandler = { [dataService] fcmToken in
    // Optionally subscribe to default topics
    return try await dataService.registerDevice(fcmToken: fcmToken).async()
}
```

### Handling notifications

```swift
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        notificationService.setDeviceToken(deviceToken, error: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        notificationService.setDeviceToken(nil, error: error)
    }
    
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let jsonString = notification.request.content.userInfo.toJSONString()
        logger.notice("Will present notification in foreground: \(jsonString)", metadata: [ "service": "notifications" ])
        return [.alert, .badge, .sound]
    }

   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let jsonString = response.notification.request.content.userInfo.toJSONString()
        logger.notice("Did receive notification response: '\(response.actionIdentifier)' for \(jsonString)", metadata: [ "service": "notifications" ])

        routingService.handleNotification(response: response)
    }

```