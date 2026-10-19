//
//  ContentView.swift
//  Pomodorino
//
//  Created by William Oliveira de Lagos on 18.10.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timer = PomodoroTimer()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSettings = false
    
    private let brandYellow = Color(red: 0.976, green: 0.769, blue: 0.129)
    private let darkGrey = Color(red: 0.227, green: 0.227, blue: 0.227)
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pomodorino")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(.primary)
                        Text(timer.phase == .focus ? "Stay focused & productive" : "Rest and recharge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        if timer.completedPomodoros > 0 {
                            HStack(spacing: 4) {
                                Text("🍅")
                                    .font(.subheadline)
                                Text("\(timer.completedPomodoros)")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(Capsule())
                        }
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Mode Picker
                HStack(spacing: 8) {
                    ForEach(PomodoroPhase.allCases) { phase in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                timer.switchPhase(to: phase)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(phase.icon)
                                Text(phase.rawValue)
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(timer.phase == phase ? brandYellow : Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundColor(timer.phase == phase ? darkGrey : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: timer.phase == phase ? brandYellow.opacity(0.3) : .clear, radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Circular Timer Ring
                ZStack {
                    // Outer track
                    Circle()
                        .stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 16)
                        .frame(width: 260, height: 260)
                    
                    // Progress arc
                    Circle()
                        .trim(from: 0.0, to: CGFloat(timer.progress))
                        .stroke(
                            brandYellow,
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 260, height: 260)
                        .animation(.linear(duration: 0.25), value: timer.progress)
                    
                    // Center content
                    VStack(spacing: 8) {
                        Text(timer.phase.icon)
                            .font(.system(size: 48))
                            .scaleEffect(timer.isRunning ? 1.08 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: timer.isRunning)
                        
                        Text(timer.formattedTime)
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.primary)
                        
                        Text(timer.phase.rawValue.uppercased())
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
                
                Spacer()
                
                // Controls
                VStack(spacing: 14) {
                    // Primary Action Button (Start / Pause)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            timer.toggle()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .font(.title3.weight(.bold))
                            Text(timer.isRunning ? "Pause" : "Start")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(brandYellow)
                        .foregroundColor(darkGrey)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: brandYellow.opacity(0.4), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    // Secondary Actions (Reset & Skip)
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                timer.reset()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset")
                            }
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundColor(.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                timer.skip()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "forward.fill")
                                Text("Skip")
                            }
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundColor(.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(timer: timer)
        }
        .onAppear {
            timer.requestNotificationPermission()
        }
        .onChange(of: scenePhase) { newPhase in
            timer.handleScenePhase(newPhase)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var timer: PomodoroTimer
    @Environment(\.dismiss) private var dismiss
    
    private let focusOptions = [15, 20, 25, 30, 45, 50, 60]
    private let breakOptions = [3, 5, 10, 15, 20]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Timer Durations")) {
                    Picker("Focus Length", selection: $timer.focusMinutes) {
                        ForEach(focusOptions, id: \.self) { min in
                            Text("\(min) minutes").tag(min)
                        }
                    }
                    Picker("Break Length", selection: $timer.breakMinutes) {
                        ForEach(breakOptions, id: \.self) { min in
                            Text("\(min) minutes").tag(min)
                        }
                    }
                }
                
                Section(header: Text("Audio & Feedback")) {
                    Toggle("Sound & Haptics", isOn: $timer.isSoundEnabled)
                }
                
                Section(header: Text("About Pomodorino")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.1 (102)")
                            .foregroundColor(.secondary)
                    }
                    Link(destination: URL(string: "https://github.com/williamlagos/pomodorino")!) {
                        HStack {
                            Text("Open Source on GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
