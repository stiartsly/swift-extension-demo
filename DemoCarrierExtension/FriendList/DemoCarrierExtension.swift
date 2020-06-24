//
//  DemoCarrierExtension.swift
//  offmsg
//
//  Created by 李爱红 on 2020/6/12.
//  Copyright © 2020 李爱红. All rights reserved.
//

import UIKit
import ElastosCarrierSDK

class DemoCarrierExtension: CarrierExtension {

    deinit {
        print("DemoCarrierExtension deinit")
    }

    init(c: Carrier) {
        super.init(c)
    }

}
