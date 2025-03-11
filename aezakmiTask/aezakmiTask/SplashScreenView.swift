//
//  SplashScreenView.swift
//  aezakmiTask
//
//  Created by Владислав Шляховенко on 09.03.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive: Bool = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        if isActive {
            SecondContentView(viewModel: .init(lanScanner: LanScannnerServiceImpl()))
        } else {
            splashView
        }
    }
    
    @MainActor
    private func animateSplash() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            scale = 0.9
            opacity = 1.0
        }
        
        Task {
            try await Task.sleep(nanoseconds: 2_500_000_000)
            withAnimation(.easeOut(duration: 0.5)) {
                isActive = true
            }
        }
    }
}

//MARK: - splashView

private extension SplashScreenView {
    var splashView: some View {
        VStack {
            Image(systemName: "hare.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            Text("ScannerTestTask")
                .font(.custom("Baskerville-Bold", size: 26))
                .foregroundColor(.black.opacity(0.80))
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear(perform: animateSplash)
        .transition(.opacity)
    }
}

#Preview {
    SplashScreenView()
}
