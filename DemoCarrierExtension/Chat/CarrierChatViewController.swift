//
//  CarrierChatViewController.swift
//  offmsg
//
//  Created by 李爱红 on 2020/6/13.
//  Copyright © 2019 李爱红. All rights reserved.
//

import UIKit

class CarrierChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var mainTableView: UITableView!
    var chatInputView: UITextView?
    var sendButton: UIButton?
    var sfileTransfer: CarrierFileTransfer?
    var transferManager: ElastosCarrierSDK.CarrierFileTransferManager!
    var currentState: CarrierFileTransferConnectionState?

    var friendId: String?
    var myId: String?
    var chatList = [MessageInfo]()
    var newMsgs = [MessageInfo](){
        didSet{
            self.chatList += newMsgs
        }
    }
    typealias callBackCancleRed = (_ friendInfo: MessageInfo) -> Void

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleDoneAction(notif:)), name: Notification.Name("doneAction"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidReceiveFriendMessage(notif:)), name: .didReceiveFriendMessage, object: nil)

        self.view.backgroundColor = UIColor.lightGray
        self.creatUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        sfileTransfer?.close()
    }

    func handle(carrier: Carrier, from: String, info: CarrierFileTransferInfo) {
        print(from)
        do {
            if (sfileTransfer == nil) {
                sfileTransfer = try transferManager.createFileTransfer(to: from, withFileInfo: info, delegate: self)
            }
            try sfileTransfer!.acceptConnectionRequest()
        } catch {
            print(error)
        }
    }

    func creatUI() {
        mainTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        mainTableView.delegate = self as UITableViewDelegate
        mainTableView.dataSource = self as UITableViewDataSource
        mainTableView.estimatedRowHeight = 50
        mainTableView.estimatedSectionHeaderHeight = 395;
        mainTableView.estimatedSectionFooterHeight = 0;
        mainTableView.rowHeight = UITableView.automaticDimension
        mainTableView.separatorStyle = .none
        mainTableView.register(MyChatCell.self, forCellReuseIdentifier: "MyChatCell")
        mainTableView.register(FriendChatCell.self, forCellReuseIdentifier: "FriendChatCell")
        self.view.addSubview(mainTableView)
        mainTableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            } else {
                // Fallback on earlier versions
                make.bottom.equalToSuperview().offset(-89)
            }
        }
        chatInputView = UITextView()
        chatInputView?.backgroundColor = UIColor.white
        chatInputView?.layer.masksToBounds = true
        chatInputView?.layer.cornerRadius = 10
        self.view.addSubview(chatInputView!)
        chatInputView?.snp.makeConstraints({ (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                // Fallback on earlier versions
                make.bottom.equalToSuperview().offset(-49 - 4)
            }
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12 - 44)
            make.height.equalTo(44)
        })
        sendButton = UIButton()
        sendButton?.titleLabel?.text = "发送图片"
        sendButton?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //        sendButton?.backgroundColor = UIColor.green
        //        sendButton?.addTarget(self, action: #selector(sendFileAction), for: .touchUpInside)
        self.view.addSubview(sendButton!)
        sendButton?.snp.makeConstraints({ (make) in
            make.bottom.equalTo((chatInputView?.snp.bottom)!)
            make.left.equalTo((self.chatInputView?.snp.right)!).offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(44)
        })
    }

    @objc func handleDidReceiveFriendMessage(notif: NSNotification) {
        let friend = notif.userInfo!["messageInfo"] as! Dictionary<String, Any>
        if ((friend["userId"] as! String) == self.friendId) {
            let msgInfo = MessageInfo()
            msgInfo.friendId = self.friendId
            msgInfo.isMy = false
            msgInfo.message = (friend["msg"] as! String)
            msgInfo.status = true
            self.chatList.append(msgInfo)
            DispatchQueue.main.sync {
                self.mainTableView .reloadData()
            }
            NotificationCenter.default.post(name: Notification.Name("already"), object: nil, userInfo: ["msgInfo": msgInfo])
        }
    }

    @objc func handleDoneAction(notif: Notification) {
        print("no==\(notif)")
        sendInviteConfirm(friendId!, msg: chatInputView!.text)
        chatInputView?.text = ""
    }

    func sendInviteConfirm(_ userId: String, msg: String) {
        do {
            try DeviceManager.sharedInstance.carrierExtension.sendInviteFriendRequest(to: userId, withData: msg, { (carrier, frome, status, reason, data) in

                print(carrier)
                print(frome)
            })
        } catch {
            print(error)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let myCell: MyChatCell = tableView.dequeueReusableCell(withIdentifier: "MyChatCell") as! MyChatCell
        let frendCell: FriendChatCell = tableView.dequeueReusableCell(withIdentifier: "FriendChatCell") as! FriendChatCell
        if chatList[indexPath.row].isMy! {
            myCell.model = chatList[indexPath.row]
            return myCell
        }
        frendCell.model = chatList[indexPath.row]
        return frendCell
    }
}

extension CarrierChatViewController: CarrierFileTransferDelegate {

    func didReceiveFileRequest(_ fileTransfer: CarrierFileTransfer, _ fileId: String, _ fileName: String, _ fileSize: UInt64) {
        print("didReceiveFileRequest=========================================================")

        do {
            try sfileTransfer!.sendPullRequest(fileId: fileId, withOffset: 0)

        } catch {
            print("didReceiveFileRequest: error \(error)")
        }
    }

    func didReceivePullRequest(_ fileTransfer: CarrierFileTransfer, _ fileId: String, _ offset: UInt64) {
        print("didReceivePullRequest====================================\(fileTransfer)")
        let path = NSHomeDirectory() + "/Library/Caches/" + "test.txt"
        let readHandle = FileHandle(forReadingAtPath: path)
        readHandle?.seek(toFileOffset: 0)
        let data = readHandle?.readDataToEndOfFile()
        do {
            try sfileTransfer!.sendData(fileId: fileId, withData: data!)
        } catch {
            print("didReceivePullRequest: error \(error)")
        }
    }

    func didReceiveFileTransferData(_ fileTransfer: CarrierFileTransfer, _ fileId: String, _ data: Data) -> Bool {
        print("didReceiveFileTransferData===========\(data)")
        return true
    }

    func fileTransferStateDidChange(_ fileTransfer: CarrierFileTransfer, _ newState: CarrierFileTransferConnectionState) {
        print("newState======================\(newState)")
        currentState = newState
    }
}
