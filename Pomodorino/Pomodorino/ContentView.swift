//
//  ContentView.swift
//  Pomodorino
//
//  Created by William Oliveira de Lagos on 10/12/2020.
//

import SwiftUI

let backgroundGradient = LinearGradient(
    colors: [Color.red, Color.yellow],
    startPoint: .top, endPoint: .bottom)

struct ContentView: View {
    @State var currentDate = Date()
    @State var timeRemaining = 1500
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                Text("Countdown: \(timeRemaining)")
                    .padding()
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
                Text("\(currentDate)")
                    .padding()
                    .onReceive(timer) { input in
                        currentDate = input
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
