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
        ZStack {
            if viewModel.state.isLoading {
                VStack {
                    ProgressView()
                    ProgressBarView(progress: $viewModel.state.progress)
                }
                
            } else {
                VStack {
                    List(viewModel.state.connectedDevices, id: \.id) { device in
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
            }
        }
        .onAppear {
            viewModel.startScan()
        }
    }
}


public protocol ViewModel: ObservableObject {
    associatedtype State: Equatable
    associatedtype Action
    func dispatch(_ action: Action) async
}

extension LanDevice: Equatable {
    public static func == (lhs: LanDevice, rhs: LanDevice) -> Bool {
        lhs.id == rhs.id
    }
}

class SecondContentViewModel: ViewModel {
    
    struct State: Equatable {
        var connectedDevices: [LanDevice] = []
        var progress: CGFloat = 0
        var isScanningFinished: Bool = false
        var isLoading = false
    }

    enum Action {
        case onAppear
    }
    
    private let lanScanner: LanScannerService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var state: State  = .init()
    
    init(lanScanner: LanScannerService) {
        self.lanScanner = lanScanner
        setupBindings()
    }
    
    func dispatch(_ action: Action) async {
        switch action {
        case .onAppear:
            break
            //await fetchAstronomies()
        }
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
            self.state.isLoading = true
            self.state.progress = progress
            //self.currentAddress = address
        case .newDevice(let device):
            self.addDeviceIfNeeded(device)
        case .finished:
            self.state.isLoading = false
        }
    }
    
    func startScan() {
        lanScanner.startScanning()
    }
    
    func stopScan() {
        lanScanner.stopScanning()
    }
    
    
    private func addDeviceIfNeeded(_ device: LanDevice) {
        guard !state.connectedDevices.contains(where: { $0.id == device.id }) else { return }
        state.connectedDevices.append(device)
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

struct ProgressBarView: View {
    @Binding var progress: CGFloat
    
    var body: some View {
        VStack {
            Text("Progress: \(Int(progress * 100))%")
                .font(.headline)
                .padding(.top, 20)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(height: 20)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: UIScreen.main.bounds.width * progress, height: 20)
                    .foregroundColor(.blue)
                    .animation(.easeInOut(duration: 0.5), value: progress) // Анимация прогресса
            }
            .padding([.leading, .trailing], 20)
        }
    }
}
