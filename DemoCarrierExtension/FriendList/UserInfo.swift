//
//  UserInfo.swift
//  offmsg
//
//  Created by 李爱红 on 2020/6/12.
//  Copyright © 2019 李爱红. All rights reserved.
//

import UIKit

class UserInfo: NSObject {

    var name: String?
    var status = CarrierConnectionStatus.Disconnected;
    var remote: Bool?
    var userId: String?
    var isNews: Bool?
    var newMsgs = [MessageInfo]()

}

