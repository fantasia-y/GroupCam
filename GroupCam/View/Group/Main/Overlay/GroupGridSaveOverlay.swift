//
//  GroupGridSaveOverlay.swift
//  OneCam
//
//  Created by Gordon on 23.02.24.
//

import SwiftUI

struct GroupGridSaveOverlay: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    var body: some View {
        if viewModel.isSaving {
            ZStack {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                
                Card {
                    VStack(spacing: 20) {
                        ProgressView(value: viewModel.saveProgress, total: 1)
                            .progressViewStyle(GaugeProgressStyle())
                            .frame(width: 50, height: 50)
                        
                        Text("group.share.loading")
                            .foregroundStyle(Color("textSecondary"))
                    }
                    .padding(.all, 20)
                }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    GroupGridSaveOverlay()
}
