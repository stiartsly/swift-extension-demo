//
//  MyChatCell.swift
//  offmsg
//
//  Created by 李爱红 on 2020/6/13.
//  Copyright © 2019 李爱红. All rights reserved.
//

import UIKit

class MyChatCell: UITableViewCell {

    var icon: UIImageView?
    var msgLable: UILabel?
    var statusLable: UILabel?

    var model: MessageInfo? {
        didSet {
            msgLable?.text = model!.message
            if model!.status! {
                statusLable?.isHidden = true
            }
            else {
                statusLable?.isHidden = false
            }
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
        icon = UIImageView.init(image: UIImage(named: "local")!)
        icon?.layer.cornerRadius = 5
        icon?.layer.masksToBounds = true
        self.contentView.addSubview(icon!)
        icon?.snp.makeConstraints({ (make) in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.height.width.equalTo(30)
        })

        msgLable = UILabel()
        msgLable?.numberOfLines = 0
        msgLable?.text = ""
        msgLable?.textAlignment = NSTextAlignment.right
        self.contentView.addSubview(msgLable!)
        msgLable?.snp.makeConstraints({ (make) in
            make.top.equalTo(icon!.snp.top)
            make.left.equalToSuperview().offset(57)
            make.right.equalTo(icon!.snp_left).offset(-5)
            make.height.greaterThanOrEqualTo(30)
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-15)
        })

        statusLable = UILabel()
        statusLable?.text = "发送失败"
        statusLable?.font = UIFont.systemFont(ofSize: 7)
        statusLable?.textAlignment = NSTextAlignment.right
        statusLable?.textColor = UIColor.red
        self.contentView.addSubview(statusLable!)
        statusLable?.snp.makeConstraints({ (make) in
            make.top.equalTo(msgLable!.snp.bottom).offset(1)
            make.right.equalTo((msgLable?.snp.right)!)
            make.height.equalTo(10)
            make.width.equalTo(30)
        })
    }
}
