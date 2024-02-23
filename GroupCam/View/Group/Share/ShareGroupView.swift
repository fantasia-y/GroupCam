//
//  ShareSessionView.swift
//  OneCam
//
//  Created by Gordon on 11.12.23.
//

import SwiftUI
import GordonKirschUtils

struct ShareGroupView: View {
    let group: Group
    
    var body: some View {
        SheetWrapper { _ in
            VStack {
                Text("share.qr.title")
                    .bold()
                
                Image(uiImage: QRCodeUtils.generate(forGroup: group))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .presentationDetents([.height(400)])
    }
}

#Preview {
    ShareGroupView(group: Group.Example)
}
