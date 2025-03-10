//
//  CoreBluetooth.swift
//  aezakmiTask
//
//  Created by Владислав Шляховенко on 10.03.2025.
//

import Foundation
import CoreBluetooth

protocol BluetoothDiscover {
    func startScanning()
    func stopScanning()
    var delegate: BluetoothDiscoverDelegate? { get set }
}

protocol BluetoothDiscoverDelegate: AnyObject {
    func didDiscoverDevices(devices: [BTDeviceInfo])
}

final class BluetoothDiscoverImpl: NSObject {
    
    private let centralManager: CBCentralManager
    
    private var discoveredDevices: [(peripheral: CBPeripheral, rssi: NSNumber)] = []
    private var isScanning = false
    weak var delegate: BluetoothDiscoverDelegate?
    private let mapper: BTDeviceInfoMapper
    
    init(mapper: BTDeviceInfoMapper) {
        self.mapper = mapper
        self.centralManager = CBCentralManager()
        super.init()
        self.centralManager.delegate = self
    }
}

private extension BluetoothDiscoverImpl {
    func scanForPeripherals() {
        discoveredDevices.removeAll()
        switch centralManager.state {
        case .unknown:
            print("error not found")
        case .resetting:
            print("error resset")
        case .unsupported:
            print("error not supported")
        case .unauthorized:
            print("error authorized")
        case .poweredOff:
            print("error powered off")
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [])
        }
    }
}

extension BluetoothDiscoverImpl: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
     //   startScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredDevices.append((peripheral, RSSI))
            print(peripheral.state.rawValue)
        }
        
        let devices = mapper.map(from: discoveredDevices)
        delegate?.didDiscoverDevices(devices: devices)
    }
}

extension BluetoothDiscoverImpl: BluetoothDiscover {
    func startScanning() {
        guard !isScanning else { return }
        isScanning = true
        print("start scan")
        scanForPeripherals()
    }
    
    func stopScanning() {
        guard isScanning else { return }
        isScanning = false
        print("stop scan")
        centralManager.stopScan()
    }
}


struct BTDeviceInfo {
    let name: String?
    let uuid: UUID
    let rssi: Int
    let status: DeviceStatus
}

enum DeviceStatus {
    case connected
    case connecting
    case disconnected
}

protocol BTDeviceInfoMapper {
    func map(from discoveredDevices: [(peripheral: CBPeripheral, rssi: NSNumber)]) -> [BTDeviceInfo]
}

struct BTDeviceInfoMapperImpl: BTDeviceInfoMapper {
    func map(from discoveredDevices: [(peripheral: CBPeripheral, rssi: NSNumber)]) -> [BTDeviceInfo] {
        return discoveredDevices.map { device in
            BTDeviceInfo(
                name: device.peripheral.name,
                uuid: device.peripheral.identifier,
                rssi: device.rssi.intValue,
                status: {
                    switch device.peripheral.state {
                    case .connected: return .connected
                    case .connecting: return .connecting
                    default: return .disconnected
                    }
                }()
            )
        }
    }
}
