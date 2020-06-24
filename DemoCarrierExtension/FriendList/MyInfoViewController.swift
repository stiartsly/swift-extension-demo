//
//  MyInfoViewController.swift
//  offmsg
//
//  Created by 李爱红 on 2020/6/12.
//  Copyright © 2019 李爱红. All rights reserved.
//

import UIKit
import QRCode

class MyInfoViewController: UIViewController {

    var nameLabel: UILabel?
    var qrCodeImageView: UIImageView?
    var messageLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        loadMyInfo()
    }

    func createUI() {
        self.view.backgroundColor = UIColor.white
        qrCodeImageView = UIImageView()
        self.view.addSubview(qrCodeImageView!)
        qrCodeImageView?.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(200)
        })
    }

    func loadMyInfo() {
        navigationItem.title = "我"
        if let carrierInst = DeviceManager.sharedInstance.carrierInst {
            if (try? carrierInst.getSelfUserInfo()) != nil {
                let address = carrierInst.getAddress()
                let qrCode = QRCode(address)
                qrCodeImageView!.image = qrCode?.image
                return
            }
        }
    }

}
