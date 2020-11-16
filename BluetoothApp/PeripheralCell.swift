//
//  PeripheralCell.swift
//  BluetoothApp
//
//  Created by Victor Ruiz on 11/16/20.
//

import Foundation
import UIKit
import CoreBluetooth

protocol PeripheralCellDelegate {
	func didSelect(_ cell: PeripheralCell, atIndexPath indexPath: IndexPath)
}

class PeripheralCell: UITableViewCell {
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var connectButton: UIButton!
	
	var delegate: PeripheralCellDelegate?
	var indexPath: IndexPath!
	
	var peripheral: CBPeripheral? {
		didSet {
			updateViews()
		}
	}
	
	private func updateViews() {
		guard let peripheral = peripheral else {
			return
		}
		name.text = peripheral.name
		switch peripheral.state {
		case .disconnected:
			connectButton.setTitle("Connect", for: .normal)
		case .connected:
			connectButton.setTitle("Connected", for: .normal)
		case .connecting:
			connectButton.setTitle("Connecting", for: .normal)
		case .disconnecting:
			connectButton.setTitle("Disconnecting", for: .normal)
		default:
			connectButton.setTitle("Unkown", for: .normal)
		}
	}
	
	@IBAction func connectToDevice(_ sender: UIButton) {
		delegate?.didSelect(self, atIndexPath: indexPath)
	}
}
