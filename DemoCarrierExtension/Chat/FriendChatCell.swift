//
//  FriendChatCell.swift
//  offmsg
//
//  Created by 李爱红 on 2020/6/13.
//  Copyright © 2019 李爱红. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

class FriendChatCell: UITableViewCell {

    var icon: UIImageView?
    var msgLable: UILabel?
    var model: MessageInfo? {
        didSet {
            msgLable?.text = model!.message
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        creatUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func creatUI() {
        
        self.backgroundColor = UIColor.clear
        icon = UIImageView.init(image: UIImage(named: "remote")!)
        icon?.layer.cornerRadius = 5
        icon?.layer.masksToBounds = true
        self.contentView.addSubview(icon!)
        icon?.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.height.width.equalTo(30)
        })

        msgLable = UILabel()
        msgLable?.numberOfLines = 0
        msgLable?.text = ""

        self.contentView.addSubview(msgLable!)
        msgLable?.snp.makeConstraints({ (make) in
            make.top.equalTo(icon!.snp.top)
            make.right.equalToSuperview().offset(-57)
            make.left.equalTo(icon!.snp_right).offset(5)
            make.height.greaterThanOrEqualTo(30)
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-15)
        })
    }

}
