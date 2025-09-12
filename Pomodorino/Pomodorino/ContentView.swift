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
    enum TimerMode {
        case pomodoro, shortPause
    }
    @State private var mode: TimerMode = .pomodoro
    @State private var timeRemaining = 1500 // Default 25 minutes
    @State private var isRunning = false
    @State private var showCompletion = false
    @State private var animateTomato = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Compute a gradient that changes with the time remaining and mode
    private var dynamicGradient: LinearGradient {
        switch mode {
        case .pomodoro:
            let fraction = Double(timeRemaining) / 1500.0
            let endColor = Color.red.opacity(1 - fraction)
            let startColor = Color.yellow.opacity(fraction)
            return LinearGradient(colors: [startColor, endColor], startPoint: .top, endPoint: .bottom)
        case .shortPause:
            let fraction = Double(timeRemaining) / 300.0
            let endColor = Color.blue.opacity(1 - fraction)
            let startColor = Color.green.opacity(fraction)
            return LinearGradient(colors: [startColor, endColor], startPoint: .top, endPoint: .bottom)
        }
    }
    
    // Progress bar fraction
    private var progress: Double {
        switch mode {
        case .pomodoro:
            return Double(timeRemaining) / 1500.0
        case .shortPause:
            return Double(timeRemaining) / 300.0
        }
    }
    
    // Timer label
    private var timerLabel: String {
        switch mode {
        case .pomodoro:
            return "Pomodorino"
        case .shortPause:
            return "Short Pause"
        }
    }
    
    var body: some View {
        ZStack {
            dynamicGradient
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(timerLabel)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ZStack {
                    // Circular progress bar
                    Circle()
                        .stroke(lineWidth: 12)
                        .opacity(0.3)
                        .foregroundColor(.white)
                        .frame(width: 160, height: 160)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                        .foregroundColor(mode == .pomodoro ? .green : .blue)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 160, height: 160)
                        .animation(.easeInOut, value: progress)
                    VStack {
                        // Animated tomato icon
                        Text(mode == .pomodoro ? "🍅" : "☕️")
                            .font(.system(size: 40))
                            .scaleEffect(isRunning ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isRunning)
                        Text(formatCountdown(seconds: timeRemaining))
                            .font(.system(size: 50, weight: .medium, design: .monospaced))
                            .padding(.top, 8)
                    }
                }
                .padding(.bottom, 10)
                .onReceive(timer) { _ in
                    if isRunning && timeRemaining > 0 {
                        timeRemaining -= 1
                        if timeRemaining == 0 {
                            isRunning = false
                            showCompletion = true
                        }
                    }
                }
                
                if showCompletion {
                    // Confetti/checkmark animation
                    VStack {
                        Text("✅")
                            .font(.system(size: 60))
                            .transition(.scale)
                        Text("Session Complete!")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(16)
                    .foregroundColor(.white)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCompletion = false
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        isRunning.toggle()
                        if isRunning {
                            scheduleNotification()
                        }
                    }) {
                        Text(isRunning ? "Pause" : "Start")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isRunning ? Color.yellow : (mode == .pomodoro ? Color.green : Color.blue))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .scaleEffect(isRunning ? 1.05 : 1.0)
                            .animation(.spring(), value: isRunning)
                    }
                    
                    Button(action: {
                        switch mode {
                        case .pomodoro:
                            timeRemaining = 1500
                        case .shortPause:
                            timeRemaining = 300
                        }
                        isRunning = false
                        showCompletion = false
                    }) {
                        Text("Reset")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .scaleEffect(1.05)
                            .animation(.spring(), value: timeRemaining)
                    }
                }
                .padding(.horizontal)
                // New buttons for mode switching
                HStack {
                    Button(action: {
                        mode = .shortPause
                        timeRemaining = 300
                        isRunning = false
                        showCompletion = false
                    }) {
                        Text("Short Pause")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        mode = .pomodoro
                        timeRemaining = 1500
                        isRunning = false
                        showCompletion = false
                    }) {
                        Text("Back to Pomodoro")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
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
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        content.body = "Your Pomodoro session has ended. Take a break!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1500, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
