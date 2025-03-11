//
//  LanScanner.swift
//  aezakmiTask
//
//  Created by Владислав Шляховенко on 11.03.2025.
//
import LanScanner
import Combine
import Foundation

enum LanScanEvent {
    case progress(CGFloat, String)
    case newDevice(LanDevice)
    case finished
}

protocol LanScannerService {
    func startScanning()
    func stopScanning()
    var scanPublisher: AnyPublisher<LanScanEvent, Never> { get }
}

class LanScannnerServiceImpl {
    var connectedDevices = [LanDevice]()
    
    private lazy var scanner = LanScanner(delegate: self)
    private let scanSubject = PassthroughSubject<LanScanEvent, Never>()
    var scanPublisher: AnyPublisher<LanScanEvent, Never> {
        scanSubject.eraseToAnyPublisher()
    }
}

extension LanScannnerServiceImpl: LanScannerDelegate {
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String) {
        scanSubject.send(.progress(progress, address))
    }

    func lanScanDidFindNewDevice(_ device: LanDevice) {
        scanSubject.send(.newDevice(device))
    }

    func lanScanDidFinishScanning() {
        scanSubject.send(.finished)
    }
}

extension LanScannnerServiceImpl: LanScannerService {
    func startScanning() {
        scanner.start()
    }
    
    func stopScanning() {
        scanner.stop()
    }
}

extension LanDevice: Identifiable {
    public var id: UUID { .init() }
}
