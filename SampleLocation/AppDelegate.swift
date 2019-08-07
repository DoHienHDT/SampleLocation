//
//  AppDelegate.swift
//  SampleLocation
//
//  Created by Rajan Maheshwari on 25/07/17.
//  Copyright © 2017 Rajan Maheshwari. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?

    var locationManager:CLLocationManager? = CLLocationManager()
    
    var myLocation:CLLocation?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        registerForPushNotifications()

        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            if locationManager == nil {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.distanceFilter = 10
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.allowsBackgroundLocationUpdates = true
                locationManager?.startUpdatingLocation()
            }
        } else {
            locationManager?.delegate = self
            locationManager?.distanceFilter = 10
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.startUpdatingLocation()
            
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager?.requestAlwaysAuthorization()
            }
            else if CLLocationManager.authorizationStatus() == .denied {
            }
            else if CLLocationManager.authorizationStatus() == .authorizedAlways {
                locationManager?.requestAlwaysAuthorization()
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.write(text: "applicationDidEnterBackground", to: kLogsFile)
        self.createRegion(location: myLocation)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func registerForPushNotifications() {
        let pushSettings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(pushSettings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    func createRegion(location:CLLocation?) {
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            let coordinate = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
            let regionRadius = 50.0
            
            let region = CLCircularRegion(center: CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude),
                                          radius: regionRadius,
                                          identifier: "aabb")
            
            region.notifyOnExit = true
            
            scheduleLocalNotification(alert: "Region Created \(location!.coordinate) with \(location!.horizontalAccuracy)")
            Logger.write(text: "Region Created \(location!.coordinate) with \(location!.horizontalAccuracy)", to: kLogsFile)
            self.locationManager?.stopUpdatingLocation()
            Logger.write(text: "stopUpdatingLocation", to: kLogsFile)
            self.locationManager?.startMonitoring(for: region)
            Logger.write(text: "startMonitoring", to: kLogsFile)
        }
        else {
            Logger.write(text: "System can't track regions", to: kLogsFile)
        }
    }
    
    //MARK:- Location Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        Logger.write(text: "didUpdateLocations \(location!.coordinate) and \(location!.horizontalAccuracy)", to: kLogsFile)

        if (location?.horizontalAccuracy)! <= Double(65.0) {
            myLocation = location
            if !(UIApplication.shared.applicationState == .active) {
                self.createRegion(location: location)
            }
        } else {
            self.locationManager?.stopUpdatingHeading()
            self.locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Logger.write(text: "didEnterRegion", to: kLogsFile)
        scheduleLocalNotification(alert: "didEnterRegion")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Logger.write(text: "didExitRegion", to: kLogsFile)
        scheduleLocalNotification(alert: "didExitRegion")
        locationManager?.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Logger.write(text: "\(error.localizedDescription)", to: kLogsFile)
        scheduleLocalNotification(alert: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.write(text: "\(error.localizedDescription)", to: kLogsFile)
        scheduleLocalNotification(alert: error.localizedDescription)
    }
    
    
    //MARK:-Notification Handling
    func scheduleLocalNotification(alert:String) {
        let notification = UILocalNotification()
        notification.timeZone = NSTimeZone.default
        let dateTime = Date()
        notification.fireDate = dateTime.addingTimeInterval(1.0)
        notification.alertBody = alert
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if application.applicationState == .active {
            let alert = UIAlertController(title: "Location", message: notification.alertBody!, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

}

