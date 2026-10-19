//
//  PomodorinoWatch_Watch_AppTests.swift
//  PomodorinoWatch Watch AppTests
//
//  Created by William Oliveira de Lagos on 19.10.2026.
//

import Testing
@testable import Pomodorino_Watch_App

@Suite("PomodoroTimer Engine Tests")
@MainActor
struct PomodoroTimerTests {

    @Test("Timer initializes with 25-minute focus phase by default")
    func testInitialState() {
        let timer = PomodoroTimer()
        #expect(timer.phase == .focus)
        #expect(timer.timeRemaining == 25 * 60)
        #expect(!timer.isRunning)
        #expect(timer.formattedTime == "25:00")
        #expect(timer.progress == 1.0)
        #expect(timer.completedPomodoros == 0)
    }

    @Test("Switching to short break sets 5-minute duration")
    func testSwitchPhase() {
        let timer = PomodoroTimer()
        timer.switchPhase(to: .shortBreak)
        #expect(timer.phase == .shortBreak)
        #expect(timer.timeRemaining == 5 * 60)
        #expect(timer.formattedTime == "05:00")
        #expect(timer.progress == 1.0)
    }

    @Test("Skip toggles between focus and short break")
    func testSkip() {
        let timer = PomodoroTimer()
        timer.skip()
        #expect(timer.phase == .shortBreak)
        timer.skip()
        #expect(timer.phase == .focus)
    }

    @Test("Start, pause, and reset controls work as expected")
    func testControls() {
        let timer = PomodoroTimer()
        timer.start()
        #expect(timer.isRunning)
        
        timer.pause()
        #expect(!timer.isRunning)
        
        timer.reset()
        #expect(!timer.isRunning)
        #expect(timer.timeRemaining == 25 * 60)
    }

    @Test("Formatted time displays correct mm:ss")
    func testFormattedTime() {
        let timer = PomodoroTimer()
        #expect(timer.formattedTime == "25:00")
        timer.switchPhase(to: .shortBreak)
        #expect(timer.formattedTime == "05:00")
    }
}
