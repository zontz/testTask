//
//  SplashScreenView.swift
//  aezakmiTask
//
//  Created by Владислав Шляховенко on 09.03.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State var isActive : Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
//            ContentView(viewModel: ContentViewModel(bluetoothDiscover: BluetoothDiscoverImpl(mapper: BTDeviceInfoMapperImpl())))
            SecondContentView(viewModel: .init(lanScanner: LanScannnerServiceImpl()))
        } else {
            ZStack {
                VStack {
                    VStack {
                        Image(systemName: "hare.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                        Text("Epic App")
                            .font(Font.custom("Baskerville-Bold", size: 26))
                            .foregroundColor(.black.opacity(0.80))
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.00
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
