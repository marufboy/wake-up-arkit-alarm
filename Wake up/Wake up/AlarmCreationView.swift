//
//  AlarmCreationView.swift
//  Wake up
//
//  Created by Muhammad Afif Maruf on 20/05/23.
//

import SwiftUI
import UserNotifications
import AVFoundation

struct AlarmCreationView: View {
    @State private var isShowingSheet = false
    @State private var alarmName: String = ""
    @State private var selectedTime = Date()
    @Binding var alarmActive : Bool
    var alarmPlayer : AVAudioPlayer
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                VStack {
                    //Header
                    HStack{
                        Text("WAKE UP!")
                            .fontWeight(.medium)
                        Spacer()
                        Button{
                            isShowingSheet.toggle()
                        }label: {
                            Image(systemName: "plus")
                        }
                    }
                    .padding(.all)
                    Spacer()
                    //show alarm data
                    if !alarmName.isEmpty{
                        //make a card to show alarm
                        Text("\(dateFormatter.string(from: selectedTime))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        GIFImageView("wizard")
                            .frame(width: 250, height: 250)
                        Text(alarmName)
                            .font(.title)
                            .fontWeight(.medium)
                    }else{
                        //show gif image
                        Text("Time is important")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        GIFImageView("wizard")
                            .frame(width: 250, height: 250)
                        Text("Wake Up Alarm")
                            .font(.title)
                            .fontWeight(.medium)
                    }
                    Spacer()
                }
                .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            SheetView(isShowingSheet: $isShowingSheet, alarmName: $alarmName, selectedTime: $selectedTime, alarmActive: $alarmActive, alarmPlayer: alarmPlayer)
        }
    }
}

struct SheetView: View {
    @Binding var isShowingSheet: Bool
    @Binding var alarmName: String
    @Binding var selectedTime : Date
    @Binding var alarmActive : Bool
    var alarmPlayer : AVAudioPlayer
    
    var body: some View {
        NavigationStack{
            Form {
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                Section(header: Text("Alarm Information")) {
                    TextField("Alarm Name", text: $alarmName)
                }
            }
            .navigationBarTitle("Set Alarm",displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isShowingSheet = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSheet = false
                        setAlarm()
                    }) {
                        Text("Save")
                            .foregroundColor(alarmName.isEmpty ? .gray : .blue)
                    }.disabled(alarmName.isEmpty)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    //function to start alarm
    func startAlarm(){
        alarmPlayer.numberOfLoops = -1 // Play indefinitely
        alarmPlayer.play()
        alarmActive = true
    }
    
    func setAlarm() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
        var alarmTime = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: now)!
        
        if alarmTime < now {
            alarmTime = calendar.date(byAdding: .day, value: 1, to: alarmTime)!
        }
        
        let timeUntilAlarm = alarmTime.timeIntervalSinceNow
        DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilAlarm) {
            self.startAlarm()
        }
        
        scheduleNotification(at: alarmTime)
    }
    
    //function to call notifiacation
    func scheduleNotification(at date: Date) {
        //setup notificaiton
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Alarm"
        notificationContent.body = "Wake up!"
        notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName("alarm.wav"))
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let stopAction = UNNotificationAction(identifier: "StopAction", title: "Stop Alarm", options: [.destructive])
        let category = UNNotificationCategory(identifier: "AlarmCategory", actions: [stopAction], intentIdentifiers: [], options: [.customDismissAction])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        //request handler
        let request = UNNotificationRequest(identifier: "AlarmNotification", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

//struct AlarmCreationView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlarmCreationView(alarmActive: .constant(false))
//    }
//}
