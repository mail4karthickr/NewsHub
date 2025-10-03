//
//  RefreshControl.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 30/09/25.
//

import SwiftUI

// MARK: - Pull-to-Refresh Component
struct RefreshControl: View {
    let coordinateSpaceName: String
    let onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .named(coordinateSpaceName)).midY > 50 {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Spacer()
                }
                .onAppear {
                    onRefresh()
                }
            }
        }
        .frame(height: 0)
    }
}

#Preview {
    RefreshControl(
        coordinateSpaceName: "pullToRefresh",
        onRefresh: {
            print("Refreshing...")
        }
    )
}
