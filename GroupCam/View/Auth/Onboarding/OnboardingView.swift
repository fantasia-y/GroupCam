//
//  OnboardingView.swift
//  OneCam
//
//  Created by Gordon on 08.02.24.
//

import SwiftUI
import SwiftUIIntrospect

struct OnboardingView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    @State var page = 1
    
    var body: some View {
        CarouselView(page: $page) {
            AccountSetupView() {
                withAnimation {
                    page += 1
                }
            }
            .tag(1)
            
            FirstStepView(selection: $page) {
                withAnimation {
                    contentViewModel.finishOnboarding()
                }
            }
            .tag(2)
        }
    }
}

#Preview {
    OnboardingView()
}
