//
//  ContentView.swift
//  BetterRest
//
//  Created by N N on 24/12/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
//    @State private var wakeUp = Date.now
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 0...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .scrollContentBackground(.hidden)
            .background(Image("cat")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea())
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            // Number of hours in seconds = * 60 * 60
            let hour = (components.hour ?? 0) * 60 * 60
            // Number of minutes in seconds = * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is:"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

        
//        VStack {
//         Text(Date.now, format: .dateTime.hour().minute())
//         Text(Date.now, format: .dateTime.day().month().year())
//         Text(Date.now.formatted(date: .long, time: .shortened))
//        }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// BetterRest is designed to help coffee drinkers get a good night’s sleep - allowing user input with a date picker and two steppers, which combined will tell us when they want to wake up, how much sleep they usually like, and how much coffee they drink.
// form and bindings, DatePicker, Stepper.formatted(), Date format, DateComponents
// Machine Learning Tabular Regression with CreateML: Xcode > Open Developer Tool > CreateML > New doc ument >  Tabular Regression > Name >  save it on your desktop then drag it inside the project and rename it as it's automatically become a class.
//
