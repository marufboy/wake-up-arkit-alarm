//
//  OnboardingView.swift
//  Wake up
//
//  Created by Muhammad Afif Maruf on 25/05/23.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPageIndex = 0
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = #colorLiteral(red: 0.4688182473, green: 0.7363420129, blue: 0.9106647968, alpha: 1)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    var body: some View {
        VStack{
            TabView(selection: $currentPageIndex) {
                FirstPage()
                    .tag(0)
                SecondPage()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            Button(action: {
                navigateToHome()
            }) {
                Text("Let's Go")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding()
            .opacity(currentPageIndex == 1 ? 1.0 : 0.0)
        }
    }
    
    func navigateToHome() {
        withAnimation{
            isFirstLaunch = false
            print(isFirstLaunch)
        }
    }
}

struct FirstPage: View{
    var body: some View{
        VStack(spacing: 20) {
            Image("wake-up-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            Text("Wake Up")
                .font(.largeTitle)
            Text("An alarm that improve your \n self-discipline")
                .multilineTextAlignment(.center)
                .font(.title2)
        }
        .offset(y: -80)
    }
}

struct SecondPage: View{
    var body: some View{
        VStack(spacing: 20) {
            Image("scan-up-Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            Text("Wake Up")
                .font(.largeTitle)
            Text("Everytime you want to stop an \n alarm, you need to get out of bed \n and find the image")
                .multilineTextAlignment(.center)
                .font(.title2)
        }
        .offset(y: -80)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
