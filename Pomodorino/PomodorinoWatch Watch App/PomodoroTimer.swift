//
//  PomodoroTimer.swift
//  Pomodorino
//
//  Created by William Oliveira de Lagos on 18.10.2026.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications
#if os(iOS)
import UIKit
import AudioToolbox
#elseif os(watchOS)
import WatchKit
#endif

public enum PomodoroPhase: String, CaseIterable, Identifiable {
    case focus = "Focus Time"
    case shortBreak = "Short Break"
    
    public var id: String { rawValue }
    
    public var duration: TimeInterval {
        switch self {
        case .focus:
            return 25 * 60 // 25 minutes
        case .shortBreak:
            return 5 * 60 // 5 minutes
        }
    }
    
    public var icon: String {
        switch self {
        case .focus:
            return "🍅"
        case .shortBreak:
            return "☕️"
        }
    }
}

@MainActor
public final class PomodoroTimer: ObservableObject {
    public static let notificationIdentifier = "io.williamlagos.pomodorino.timer"
    
    @Published public private(set) var phase: PomodoroPhase = .focus
    @Published public private(set) var timeRemaining: TimeInterval = PomodoroPhase.focus.duration
    @Published public private(set) var isRunning: Bool = false
    @Published public var showCompletion: Bool = false
    @Published public private(set) var completedPomodoros: Int = 0
    
    private var targetEndDate: Date?
    private var timerCancellable: AnyCancellable?
    
    public init() {
        requestNotificationPermission()
    }
    
    // MARK: - Computed Properties
    
    public var progress: Double {
        let total = phase.duration
        guard total > 0 else { return 0 }
        return max(0, min(1, timeRemaining / total))
    }
    
    public var formattedTime: String {
        let totalSeconds = max(0, Int(ceil(timeRemaining)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Timer Controls
    
    public func start() {
        guard !isRunning else { return }
        showCompletion = false
        targetEndDate = Date().addingTimeInterval(timeRemaining)
        isRunning = true
        scheduleNotification(for: timeRemaining)
        startHeartbeat()
    }
    
    public func pause() {
        guard isRunning else { return }
        syncRemainingTime()
        targetEndDate = nil
        isRunning = false
        stopHeartbeat()
        cancelPendingNotification()
    }
    
    public func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }
    
    public func reset() {
        pause()
        showCompletion = false
        timeRemaining = phase.duration
    }
    
    public func skipToNextPhase() {
        pause()
        showCompletion = false
        setPhase(phase == .focus ? .shortBreak : .focus)
    }
    
    public func skip() {
        skipToNextPhase()
    }
    
    public func selectPhase(_ newPhase: PomodoroPhase) {
        guard phase != newPhase else { return }
        pause()
        showCompletion = false
        setPhase(newPhase)
    }
    
    public func switchPhase(to newPhase: PomodoroPhase) {
        selectPhase(newPhase)
    }
    
    private func setPhase(_ newPhase: PomodoroPhase) {
        phase = newPhase
        timeRemaining = newPhase.duration
    }
    
    // MARK: - Lifecycle Sync
    
    public func handleScenePhaseChange(to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            if isRunning {
                syncRemainingTime()
            }
        case .background:
            if isRunning {
                syncRemainingTime()
                scheduleNotification(for: timeRemaining)
            }
        default:
            break
        }
    }
    
    public func handleScenePhase(_ newPhase: ScenePhase) {
        handleScenePhaseChange(to: newPhase)
    }
    
    // MARK: - Private Helpers
    
    private func startHeartbeat() {
        timerCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func stopHeartbeat() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func tick() {
        guard isRunning else { return }
        syncRemainingTime()
        if timeRemaining <= 0 {
            completeSession()
        }
    }
    
    private func syncRemainingTime() {
        guard let targetEndDate = targetEndDate else { return }
        let remaining = targetEndDate.timeIntervalSinceNow
        if remaining > 0 {
            timeRemaining = remaining
        } else {
            timeRemaining = 0
        }
    }
    
    private func completeSession() {
        if phase == .focus {
            completedPomodoros += 1
        }
        pause()
        timeRemaining = 0
        showCompletion = true
        playFeedback()
        
        // Prepare next phase automatically
        let nextPhase: PomodoroPhase = (phase == .focus ? .shortBreak : .focus)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self, !self.isRunning else { return }
            self.showCompletion = false
            self.setPhase(nextPhase)
        }
    }
    
    private func playFeedback() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #elseif os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1007)
        #endif
    }
    
    // MARK: - Notifications
    
    public func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func scheduleNotification(for duration: TimeInterval) {
        cancelPendingNotification()
        guard duration > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Pomodorino"
        content.body = phase == .focus
            ? "Focus session complete! Time for a short break ☕️"
            : "Break is over! Ready to focus? 🍅"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, duration), repeats: false)
        let request = UNNotificationRequest(identifier: Self.notificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelPendingNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.notificationIdentifier])
    }
}
