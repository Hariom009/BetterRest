//
//  ContentView.swift
//  BetterRest
//
//  Created by Hari's Mac on 16.01.2025.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 1.0
    @State private var coffeeCups = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    let gradient = LinearGradient(colors: [Color.orange,Color.green],
                                     startPoint: .top, endPoint: .bottom)
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from:components) ?? .now
    }
    var body: some View {
        NavigationStack{
            ZStack {
                // Background color
                LinearGradient(colors: [Color.orange,Color.green],
                                                 startPoint: .top, endPoint: .bottom)
                    .opacity(0.5)
                    .ignoresSafeArea()
                VStack{
                    Form{
                        Section{
                            Text("When do you want to wake up?")
                                .font(.headline)
                            DatePicker("Please choose a time", selection: $wakeUp,displayedComponents: .hourAndMinute).labelsHidden()
                        }
                        .listRowBackground(Color.clear)
                        //Now stepper of select hours to sleep
                        Section{
                            Text("Desired amount of sleep")
                                .font(.headline)
                            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 6...12)
                        }
                        .listRowBackground(Color.clear)
                        Section{
                            Text("Amount of coffee Cups")
                                .font(.headline)
                            Picker("coffee cups", selection: $coffeeCups){
                                ForEach (0...10, id: \.self){
                                    Text("\($0)")
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                   }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("BetterRest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showAlert ){
                Button("Ok"){}
            }message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeCups))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your bedtime should be ....".uppercased()
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // something went wrong!
            alertTitle = "Error"
            alertMessage = "Something went wrong calculating your bedtime. Please try again later."
        }
        showAlert = true
    }
}
#Preview {
    ContentView()
}
