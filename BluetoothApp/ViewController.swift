//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Victor Ruiz on 11/16/20.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	var centralManager: CBCentralManager!
	var discoveredPeripheral: CBPeripheral?
	var transferCharacteristic: CBCharacteristic?
	var peripherals: [CBPeripheral] = []
	var connectedIndexPath: IndexPath!

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		centralManager.stopScan()
		super.viewWillDisappear(animated)
	}
}

extension ViewController: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
		case .poweredOff:
			print("powered off")
		case .poweredOn:
			centralManager.scanForPeripherals(withServices: nil, options: nil)
			
			print("powered on")
		case .unauthorized:
			print("Unauthorized")
		case .unknown:
			print("unknown")
		case .unsupported:
			print("Unsupported")
		case .resetting:
			print("Resetting")
		default:
			print("Unknown error")
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		if peripherals.contains(peripheral) {
			return
		} else {
			peripherals.append(peripheral)
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("Connected!!!!!!!!!")
		peripheral.delegate = self
		tableView.reloadRows(at: [connectedIndexPath], with: .automatic)
		centralManager.stopScan()
		peripheral.discoverServices(nil)
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if let services = peripheral.services {
			peripheral.discoverCharacteristics(nil, for: services[0])
			print(services[0])
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let characteristics = service.characteristics {
			peripheral.readValue(for: characteristics[0])
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		if let data = characteristic.value {
			let string = String(data: data, encoding: .utf8)
			let alertController = UIAlertController(title: "\(characteristic.uuid)", message: string, preferredStyle: .alert)
			let action = UIAlertAction(title: "OK", style: .default, handler: nil)
			alertController.addAction(action)
			present(alertController, animated: true, completion: nil)
		}
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return peripherals.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell", for: indexPath) as? PeripheralCell else {
			return UITableViewCell()
		}
		let peripheral = peripherals[indexPath.row]
		cell.indexPath = indexPath
		cell.delegate = self
		cell.peripheral = peripheral
		return cell
	}
}

extension ViewController: PeripheralCellDelegate {
	func didSelect(_ cell: PeripheralCell, atIndexPath indexPath: IndexPath) {
		let peripheral = peripherals[indexPath.row]
		centralManager.connect(peripheral, options: nil)
		tableView.reloadRows(at: [indexPath], with: .automatic)
		connectedIndexPath = indexPath
	}
}
