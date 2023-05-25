//
//  ContentView.swift
//  Wake up
//
//  Created by Muhammad Afif Maruf on 20/05/23.
//

import SwiftUI
import ARKit
import UserNotifications
import AVFoundation

struct ContentView: View {
    @State private var showImageDetectedAlert = false
    @State private var restartARSession = false
    @State private var isAlarmActive = false
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    //setup avplayer
    let alarmPlayer: AVAudioPlayer
    
    //init for usernotification and url sound
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        let alarmSound = Bundle.main.path(forResource: "alarm", ofType: "wav")!
        let alarmURL = URL(fileURLWithPath: alarmSound)
        
        do {
            //set background music
            alarmPlayer = try AVAudioPlayer(contentsOf: alarmURL)
            alarmPlayer.prepareToPlay()
        } catch {
            fatalError("Unable to load alarm sound file: \(error)")
        }
    }
    
    
    var body: some View {
        ZStack {
            if isFirstLaunch{
                OnboardingView()
            }else{
                if isAlarmActive{
                    //show up the ar
                    ARViewContainer(showImageDetectedAlert: $showImageDetectedAlert, restartSession: restartARSession)
                        .edgesIgnoringSafeArea(.all)
                    
                    //if detect call an action
                    if showImageDetectedAlert {
                        VStack {
                            Spacer()
                            Text("Image Detected!")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                                .padding()
                            
                            Button(action: {
                                showImageDetectedAlert = false
                                restartARSession = true
                                stopAlarm()
                            }) {
                                Text("Dismiss")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 50)
                            
                            Spacer()
                        }
                    }else{
                        VStack {
                            Text("Find Afif's Apple Academy Card")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                                .padding()
                            Spacer()
                        }
                    }
                }else{
                    AlarmCreationView(alarmActive: $isAlarmActive ,alarmPlayer: alarmPlayer)
                }
            }
        }
    }
    
    //function to stop an alarm
    func stopAlarm(){
        alarmPlayer.stop()
        isAlarmActive = false
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var showImageDetectedAlert: Bool
    var restartSession: Bool
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        
        // Create a configuration for image tracking
        let configuration = ARImageTrackingConfiguration()
        
        // Load the reference image to be detected
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.trackingImages = referenceImages
        }
        //show statistic
        arView.showsStatistics = false
        
        // Run the session with the configuration
        arView.session.run(configuration)
        
        // Set the delegate to receive ARImageAnchor updates
        arView.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if restartSession {
            let configuration = ARImageTrackingConfiguration()
            if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
                configuration.trackingImages = referenceImages
            }
            uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        let parent: ARViewContainer
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            if anchor is ARImageAnchor {
                parent.showImageDetectedAlert = true
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
