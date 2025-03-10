//
//  LanScanner.swift
//  aezakmiTask
//
//  Created by Владислав Шляховенко on 11.03.2025.
//

import Foundation
import LanScanner


protocol LanScannnerServiceDelegate: AnyObject {
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String)
    func lanScanDidFinishScanning()
}

protocol LanScannerService {
    func startScanning()
    func stopScanning()
    var connectedDevices: [LanDevice] { get }
    var delegate: LanScannnerServiceDelegate? { get set }
}

class LanScannnerServiceImpl {
    var connectedDevices = [LanDevice]()
    
    private lazy var scanner = LanScanner(delegate: self)
    weak var delegate: LanScannnerServiceDelegate?
    
}

extension LanScannnerServiceImpl: LanScannerDelegate {
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String) {
        delegate?.lanScanHasUpdatedProgress(progress, address: address)
    }

    func lanScanDidFindNewDevice(_ device: LanDevice) {
        connectedDevices.append(device)
    }

    func lanScanDidFinishScanning() {
        delegate?.lanScanDidFinishScanning()
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


class CountViewModel: ObservableObject {

    // Properties

    @Published var connectedDevices = [LanDevice]()
    @Published var progress: CGFloat = .zero
    @Published var title: String = .init()
    @Published var showAlert = false

    private lazy var scanner = LanScanner(delegate: self)

    // Init

    init() {
        scanner.start()
    }

    // Methos

    func reload() {
        connectedDevices.removeAll()
        scanner.start()
    }
}

extension CountViewModel: LanScannerDelegate {
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String) {
        self.progress = progress
        self.title = address
    }

    func lanScanDidFindNewDevice(_ device: LanDevice) {
        connectedDevices.append(device)
    }

    func lanScanDidFinishScanning() {
        showAlert = true
    }
}

extension LanDevice: Identifiable {
    public var id: UUID { .init() }
}
