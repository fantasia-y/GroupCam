//
//  GroupGridDragGesture.swift
//  OneCam
//
//  Created by Gordon on 23.02.24.
//

import Foundation
import SwiftUI

struct DragSelect: ViewModifier {
    @StateObject var viewModel: GroupViewModel
    
    func body(content: Content) -> some View {
        if viewModel.isEditing {
            content.gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged() { drag in
                        let a = drag.startLocation
                        let b = drag.location

                        viewModel.selectRect = CGRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(a.x - b.x), height: abs(a.y - b.y))

                        var resSet: [Int] = []

                        for i in 0 ..< viewModel.images.count {
                            if CGRectIntersectsRect(viewModel.rectangles.content[i]!, viewModel.selectRect!) {
                                resSet.append(i)
                            }
                        }
                        
                        if !resSet.isEmpty {
                            viewModel.dragSelectedSubviews = Set(resSet.first!...resSet.last!)
                        } else {
                            viewModel.dragSelectedSubviews = Set<Int>()
                        }
                    }
                    .onEnded() { _ in
                        viewModel.selectRect = nil
                        viewModel.selectedSubviews.formUnion(viewModel.dragSelectedSubviews)
                        viewModel.dragSelectedSubviews = Set<Int>()
                    }
            )
        } else {
            content
        }
    }
}

extension GroupGridView {
    func isSelected(_ index: Int) -> Bool {
        return viewModel.selectedSubviews.contains(index) || viewModel.dragSelectedSubviews.contains(index)
    }
}
