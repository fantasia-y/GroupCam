//
//  JoinSessionView.swift
//  OneCam
//
//  Created by Gordon on 22.11.23.
//

import SwiftUI
import CodeScanner

struct JoinGroupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = JoinGroupViewModel()
    
    var groupId: Binding<String?>
    
    var body: some View {
        SheetWrapper(padding: nil) { _ in
            CarouselView(page: $viewModel.page) {
                CodeScannerView(codeTypes: [.qr], showViewfinder: true, simulatedData: "https://lamb-uncommon-goose.ngrok-free.app/join/a6700557-a790-407d-a1b4-53860df9aa95") { result in
                    switch(result) {
                    case .success(let data):
                        if let url = URL(string: data.string), URLUtils.isOwnHost(url) {
                            if let groupId = UUID(uuidString: url.lastPathComponent) {
                                viewModel.groupId = groupId.uuidString.lowercased()
                                viewModel.page += 1
                            } else {
                                // TODO correct host, invalid url
                            }
                        } else {
                            // TODO invalid host
                        }
                        
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                .tag(1)
                
                JoinGroupPreviewView()
                    .environmentObject(viewModel)
                    .tag(2)
            }
        }
        .toastView(toast: $viewModel.toast, isSheet: true)
        .onAppear() {
            if let groupId = groupId.wrappedValue, !groupId.isEmpty {
                viewModel.groupId = groupId
                viewModel.page += 1
            }
        }
        .onDisappear() {
            groupId.wrappedValue = nil
        }
    }
}

#Preview {
    JoinGroupView(groupId: .constant(""))
        .environmentObject(JoinGroupViewModel())
}
