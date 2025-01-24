//
//  ContentView.swift
//  Pomodorino
//
//  Created by William Oliveira de Lagos on 10/12/2020.
//

import SwiftUI
import Foundation

func formatCountdown(seconds: Int) -> String {
    // Calculate hours, minutes, and seconds
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}

struct ContentView: View {
    @State private var timeRemaining = 1500 // Default 25 minutes
    @State private var isRunning = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Compute a gradient that changes with the time remaining
    private var dynamicGradient: LinearGradient {
        let fraction = Double(timeRemaining) / 1500.0
        let endColor = Color.red.opacity(1 - fraction)
        let startColor = Color.yellow.opacity(fraction)
        return LinearGradient(colors: [startColor, endColor], startPoint: .top, endPoint: .bottom)
    }
    
    var body: some View {
        ZStack {
            dynamicGradient
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Pomodorino")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(formatCountdown(seconds: timeRemaining))
                    .font(.system(size: 50, weight: .medium, design: .monospaced))
                    .padding()
                    .onReceive(timer) { _ in
                        if isRunning && timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
                
                HStack {
                    Button(action: {
                        isRunning.toggle()
                    }) {
                        Text(isRunning ? "Pause" : "Start")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isRunning ? Color.yellow : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        timeRemaining = 1500
                        isRunning = false
                    }) {
                        Text("Reset")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .foregroundColor(.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
