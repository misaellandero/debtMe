//
//  LocalNotification.swift
//  debtMe
//
//  Created by Misael Landero on 12/06/24.
//

import SwiftUI

struct LocalNotification {
    
    static func schedule(id: String, title: String, body: String, date: Date, isTimeSensitive: Bool) {
        // Solicitar permiso para enviar notificaciones
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
                return
            }
            
            guard granted else {
                print("Notification authorization denied")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            if isTimeSensitive {
                content.interruptionLevel = .timeSensitive
            }

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Notification scheduled with ID: \(id)")
                }
            }
        }
    }
    
    static func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("Notification with ID: \(id) has been cancelled.")
    }
}
