//
//  CarrierListCell.swift
//  offmsg
//
//  Created by 李爱红 on 2020/6/12.
//  Copyright © 2019 李爱红. All rights reserved.
//

import UIKit

class CarrierListCell: UITableViewCell {

    var online: UIImageView?
    var icon: UIImageView?
    var userLable: UILabel?
    var offlineLable: UILabel?
    var red: UILabel?
    
    var model: UserInfo?{
        didSet{
            userLable?.text = model!.name!
            if model!.status == .Connected {
                online?.isHidden = false
                offlineLable?.isHidden = true
            }
            else {
                online?.isHidden = true
                offlineLable?.isHidden = false
            }
            if model!.remote! {
                icon?.image = UIImage.init(named: "remote")
            }
            if model!.isNews == true {
                red?.isHidden = false
            }
            else {
                red?.isHidden = true
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

    func creatUI() -> Void {

        icon = UIImageView.init(image: UIImage(named: "local")!)
        self.contentView.addSubview(icon!)

        red = UILabel()
        red?.backgroundColor = UIColor.red
        red?.layer.cornerRadius = 5.0
        red?.layer.masksToBounds = true
        self.contentView.addSubview(red!)

        userLable = UILabel()
        userLable?.backgroundColor = UIColor.clear
        userLable?.text = "44444"
        userLable?.textAlignment = .left
        userLable!.sizeToFit()
        self.contentView.addSubview(userLable!)

        offlineLable = UILabel()
        offlineLable!.text = " 离线"
        offlineLable?.textColor = UIColor.lightGray
        offlineLable?.font = UIFont.systemFont(ofSize: 9)
        offlineLable?.backgroundColor = UIColor.clear
        offlineLable!.textColor = UIColor.black
        offlineLable!.sizeToFit()

        self.addSubview(offlineLable!)
        online = UIImageView.init(image: UIImage(named: "online")!)
        online!.isHidden = true
        self.contentView.addSubview(online!)

        let line = UIView()
        line.backgroundColor = UIColor.lightGray
        self.contentView.addSubview(line)

        icon?.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(22)
            make.centerY.equalToSuperview()
        })

        red?.snp.makeConstraints({ (make) in
            make.right.equalTo(icon!.snp_right).offset(5)
            make.width.height.equalTo(10)
            make.top.equalTo(icon!.snp_top).offset(-5)
        })

        userLable?.snp.makeConstraints({ (make) in
            make.top.equalTo(icon!)
            make.left.equalToSuperview().offset(45)
            make.height.equalTo(20)
        })

        offlineLable?.snp.makeConstraints({ (make) in
            make.top.equalTo(icon!.snp_bottom)
            make.width.equalTo(200)
            make.height.equalTo(8)
            make.left.equalTo(userLable!)
        })

        online?.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(12)
            make.right.equalToSuperview().offset(-12)
        })

        line.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview()
        }
    }

}
