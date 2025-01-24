//
//  PomodorinoApp.swift
//  Pomodorino
//
//  Created by William Oliveira de Lagos on 10/12/2020.
//

import SwiftUI

@main
struct PomodorinoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
