//
//  ContentView.swift
//  aezakmiTask
//
//  Created by Владислав Шляховенко on 09.03.2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            if viewModel.devices.isEmpty {
                Text("No devices found")
                    .padding()
            } else {
                List(viewModel.devices, id: \.uuid) { device in
                    VStack(alignment: .leading) {
                        Text(device.name ?? "Unknown")
                            .font(.headline)
                        Text("UUID: \(device.uuid.uuidString)")
                            .font(.subheadline)
                        Text("RSSI: \(device.rssi)")
                            .font(.subheadline)
                        Text("Status: \(device.status)")
                            .font(.subheadline)
                    }
                }
            }
            
            Button {
                viewModel.startScanning()
            } label: {
                Text("Start")
            }
            
            Button {
                viewModel.stopScanning()
            } label: {
                Text("Stop")
            }
        }
    }
}

#Preview {
    ContentView(viewModel: .init(bluetoothDiscover: BluetoothDiscoverImpl(mapper: BTDeviceInfoMapperImpl())))
}


class ContentViewModel: ObservableObject {
    private var bluetoothDiscover: BluetoothDiscover
    @Published var devices: [BTDeviceInfo] = []
    
    init(bluetoothDiscover: BluetoothDiscover) {
        self.bluetoothDiscover = bluetoothDiscover
        self.bluetoothDiscover.delegate = self
    }
    
    func startScanning() {
        bluetoothDiscover.startScanning()
    }
    
    func stopScanning() {
        bluetoothDiscover.stopScanning()
    }
}

extension ContentViewModel: BluetoothDiscoverDelegate {
    func didDiscoverDevices(devices: [BTDeviceInfo]) {
        self.devices = devices
    }
}
