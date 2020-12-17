//
//  ContentView.swift
//  Pomodorino
//
//  Created by William Oliveira de Lagos on 10/12/2020.
//

import SwiftUI

struct ContentView: View {
    @State var currentDate = Date()
    @State var timeRemaining = 1500
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack {
            Text("Countdown: \(timeRemaining)")
                .bold()
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                }
            Text("\(currentDate)")
                .onReceive(timer) { input in
                    currentDate = input
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
