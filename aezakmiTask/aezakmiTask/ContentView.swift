//
//  ContentView.swift
//  aezakmiTask
//
//  Created by Владислав Шляховенко on 09.03.2025.
//

import SwiftUI
import Combine
import LanScanner

struct SecondContentView: View {
    
    @ObservedObject var viewModel: SecondContentViewModel
    
    var body: some View  {
        VStack {
            List(viewModel.connectedDevices, id: \.id) { device in
                VStack(alignment: .leading) {
                    Text("IP-адрес: \(device.ipAddress)")
                        .font(.subheadline)
                    Text("MAC-адрес: \(device.mac)")
                        .font(.subheadline)
                    Text("Имя: \(device.name)")
                        .font(.subheadline)
                }
            }
        }
        .onAppear {
            viewModel.startScan()
        }
    }
}

class SecondContentViewModel: ObservableObject {
    @Published var connectedDevices: [LanDevice] = []
    private var lanScanner: LanScannerService
    
    init(lanScanner: LanScannerService) {
        self.lanScanner = lanScanner
        self.lanScanner.delegate = self
    }
    
    func startScan() {
        lanScanner.startScanning()
    }
}

extension SecondContentViewModel: LanScannnerServiceDelegate {
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String) {
        print("\(progress)")
    }
    
    func lanScanDidFinishScanning() {
        print("finish")
        connectedDevices = lanScanner.connectedDevices
    }
}

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
