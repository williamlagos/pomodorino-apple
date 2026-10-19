//
//  ContentView.swift
//  PomodorinoWatch Watch App
//
//  Created by William Oliveira de Lagos on 19.10.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timer = PomodoroTimer()
    @Environment(\.scenePhase) private var scenePhase
    
    private let brandYellow = Color(red: 0.976, green: 0.769, blue: 0.129)
    private let darkGrey = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header: Phase icon & Session count
                HStack {
                    Text(timer.phase.icon)
                        .font(.title3)
                    Text(timer.phase.rawValue)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if timer.completedPomodoros > 0 {
                        HStack(spacing: 2) {
                            Text("🍅")
                                .font(.caption2)
                            Text("\(timer.completedPomodoros)")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 4)
                
                // Circular Timer Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 8)
                        .frame(width: 124, height: 124)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(timer.progress))
                        .stroke(
                            brandYellow,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 124, height: 124)
                        .animation(.linear(duration: 0.25), value: timer.progress)
                    
                    VStack(spacing: 2) {
                        Text(timer.formattedTime)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                        
                        Text(timer.isRunning ? "RUNNING" : "PAUSED")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .tracking(1)
                            .foregroundColor(timer.isRunning ? brandYellow : .secondary)
                    }
                }
                .padding(.vertical, 4)
                
                // Primary Control Button (Play / Pause)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        timer.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            .font(.headline)
                        Text(timer.isRunning ? "Pause" : "Start")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                }
                .tint(brandYellow)
                .foregroundColor(darkGrey)
                
                // Secondary Controls: Reset & Skip
                HStack(spacing: 6) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            timer.reset()
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.body)
                    }
                    .tint(.gray.opacity(0.3))
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            timer.skip()
                        }
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.body)
                    }
                    .tint(.gray.opacity(0.3))
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            timer.switchPhase(to: timer.phase == .focus ? .shortBreak : .focus)
                        }
                    }) {
                        Text(timer.phase == .focus ? "☕️" : "🍅")
                            .font(.body)
                    }
                    .tint(.gray.opacity(0.3))
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            timer.requestNotificationPermission()
        }
        .onChange(of: scenePhase) { newPhase in
            timer.handleScenePhase(newPhase)
        }
    }
}

#Preview {
    ContentView()
}
