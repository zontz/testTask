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
    @Published var progress: CGFloat = 0
    @Published var isScanningFinished: Bool = false
    private let lanScanner: LanScannerService
    private var cancellables = Set<AnyCancellable>()
    
    init(lanScanner: LanScannerService) {
        self.lanScanner = lanScanner
        setupBindings()
    }
    
    private func setupBindings() {
        lanScanner.scanPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleLanScanEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func handleLanScanEvent(_ event: LanScanEvent) {
        switch event {
        case .progress(let progress, let address):
            self.progress = progress
            //self.currentAddress = address
        case .newDevice(let device):
            self.addDeviceIfNeeded(device)
        case .finished:
            self.isScanningFinished = true
        }
    }
    
    func startScan() {
        lanScanner.startScanning()
    }
    
    func stopScan() {
        lanScanner.stopScanning()
    }
    
    
    private func addDeviceIfNeeded(_ device: LanDevice) {
        guard !connectedDevices.contains(where: { $0.id == device.id }) else { return }
        connectedDevices.append(device)
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
