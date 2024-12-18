//
//  ContentView.swift
//  Pomodorino
//
//  Created by William Oliveira de Lagos on 10/12/2020.
//

import SwiftUI
import Foundation

let backgroundGradient = LinearGradient(
    colors: [Color.red, Color.yellow],
    startPoint: .top, endPoint: .bottom)

func formatCountdown(seconds: Int) -> String {
    // Calculate hours, minutes, and seconds
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60
    
    // Format the result as "HH:mm:ss"
    return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
}

struct ContentView: View {
    @State var timeRemaining = 1500
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                Text("Countdown: \(formatCountdown(seconds: timeRemaining))")
                    .padding()
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
