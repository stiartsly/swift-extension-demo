import Foundation
import AVFoundation
import MediaPlayer

extension Notification.Name {
    static let selfInfoChanged = Notification.Name("didReceiveData")
    static let deviceListChanged = Notification.Name("didCompleteTask")
    static let deviceStatusChanged = Notification.Name("completedLengthyDownload")
    static let friendStatusChanged = Notification.Name("friendStatusChanged")
    static let friendInfoChanged = Notification.Name("friendInfoChanged")
    static let friendAdded = Notification.Name("friendAdded")
    static let acceptFriend = Notification.Name("acceptFriend")
    static let didReceiveFriendMessage = Notification.Name("didReceiveFriendMessage")
    static let didcreatGroupSuccee = Notification.Name("didcreatGroupSuccee")
    static let showAddFriendOrCreateGroup = Notification.Name("showAddFriendOrCreateGroup")
    static let extensionFriendInvite = Notification.Name("extensionFriendInvite")

}

class DeviceManager : NSObject {
    fileprivate static let checkURL = "https://apache.org"

    // MARK: - Singleton
    @objc(sharedInstance)
    static let sharedInstance = DeviceManager()
    var status = CarrierConnectionStatus.Disconnected
    @objc(carrierInst)
    var carrierInst: ElastosCarrierSDK.Carrier!
    var carrierExtension: ElastosCarrierSDK.CarrierExtension!
    fileprivate var networkManager : NetworkReachabilityManager?

    var carrierGroup: CarrierGroup?

    override init() {
//        Carrier.setLogLevel(.Debug)
    }

    func start() {
        if carrierInst == nil {
            do {
                if networkManager == nil {
                    let url = URL(string: DeviceManager.checkURL)
                    networkManager = NetworkReachabilityManager(host: url!.host!)
                }

                guard networkManager!.isReachable else {
                    print("network is not reachable")
                    networkManager?.listener = { [weak self] newStatus in
                        if newStatus == .reachable(.ethernetOrWiFi) || newStatus == .reachable(.wwan) {
                            self?.start()
                        }
                    }
                    networkManager?.startListening()
                    return
                }

                let carrierDirectory: String = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/carrier"
                if !FileManager.default.fileExists(atPath: carrierDirectory) {
                    var url = URL(fileURLWithPath: carrierDirectory)
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try url.setResourceValues(resourceValues)
                }

                let options = CarrierOptions()
                options.bootstrapNodes = [BootstrapNode]()
                options.expressNodes = [ExpressNode]()

                let bootstrapNode = BootstrapNode()
                bootstrapNode.ipv4 = "13.58.208.50"
                bootstrapNode.port = "33445"
                bootstrapNode.publicKey = "89vny8MrKdDKs7Uta9RdVmspPjnRMdwMmaiEW27pZ7gh"
                options.bootstrapNodes?.append(bootstrapNode)

                bootstrapNode.ipv4 = "18.216.102.47"
                bootstrapNode.port = "33445"
                bootstrapNode.publicKey = "G5z8MqiNDFTadFUPfMdYsYtkUDbX5mNCMVHMZtsCnFeb"
                options.bootstrapNodes?.append(bootstrapNode)

                bootstrapNode.ipv4 = "18.216.6.197"
                bootstrapNode.port = "33445"
                bootstrapNode.publicKey = "H8sqhRrQuJZ6iLtP2wanxt4LzdNrN2NNFnpPdq1uJ9n2"
                options.bootstrapNodes?.append(bootstrapNode)

                bootstrapNode.ipv4 = "54.223.36.193"
                bootstrapNode.port = "33445"
                bootstrapNode.publicKey = "5tuHgK1Q4CYf4K5PutsEPK5E3Z7cbtEBdx7LwmdzqXHL"
                options.bootstrapNodes?.append(bootstrapNode)

                bootstrapNode.ipv4 = "52.83.191.228"
                bootstrapNode.port = "33445"
                bootstrapNode.publicKey = "3khtxZo89SBScAMaHhTvD68pPHiKxgZT6hTCSZZVgNEm"
                options.bootstrapNodes?.append(bootstrapNode)

                let hivebootstrapNode0 = ExpressNode()
                hivebootstrapNode0.ipv4 = "ece00.trinity-tech.io"
                hivebootstrapNode0.publicKey = "FyTt6cgnoN1eAMfmTRJCaX2UoN6ojAgCimQEbv1bruy9"
                hivebootstrapNode0.port = "443"
                options.expressNodes?.append(hivebootstrapNode0)

                let hivebootstrapNode1 = ExpressNode()
                hivebootstrapNode1.ipv4 = "ece01.trinity-tech.io"
                hivebootstrapNode1.publicKey = "FyTt6cgnoN1eAMfmTRJCaX2UoN6ojAgCimQEbv1bruy9"
                hivebootstrapNode1.port = "443"
                options.expressNodes?.append(hivebootstrapNode1)

                let hivebootstrapNode2 = ExpressNode()
                hivebootstrapNode2.ipv4 = "ece01.trinity-tech.cn"
                hivebootstrapNode2.publicKey = "FyTt6cgnoN1eAMfmTRJCaX2UoN6ojAgCimQEbv1bruy9"
                hivebootstrapNode2.port = "33445"
                options.expressNodes?.append(hivebootstrapNode2)

                options.udpEnabled = true
                options.persistentLocation = carrierDirectory

                carrierInst = try Carrier.createInstance(options: options, delegate: self)
                print("carrier instance created")

                networkManager = nil
                carrierExtension = DemoCarrierExtension(c: carrierInst)
                try carrierExtension.registerExtension(handel)
                try! carrierInst.start(iterateInterval: 1000)
                print("carrier started, waiting for ready")
            }
            catch {
                NSLog("Start carrier instance error : \(error.localizedDescription)")
            }
        }
    }

    func handel(_ carrier: Carrier, _ from: String, _ data: String?) {
        NotificationCenter.default.post(name: .extensionFriendInvite, object: nil, userInfo: ["carrier": carrier, "from": from, "data": data as Any])
    }

    func creatCarrierGroup() {
        do {
            if carrierInst.isReady() {
                self.carrierGroup = try carrierInst.createGroup()
                NotificationCenter.default.post(name: .didcreatGroupSuccee, object: nil)
                print("======= Create carrierGroup success",carrierGroup as Any)
            }
            else {
                print("==== Carrier is not ready, Invoke after carrier ready")
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - CarrierDelegate
extension DeviceManager : CarrierDelegate
{
    func connectionStatusDidChange(_ carrier: Carrier,
                                   _ newStatus: CarrierConnectionStatus) {
        self.status = newStatus
        if status == .Disconnected {
        }
        
        NotificationCenter.default.post(name: .deviceStatusChanged, object: nil)
    }
    
    public func didBecomeReady(_ carrier: Carrier) {

        // test turnServerInfo
         let info = try! carrierExtension.turnServerInfo()

        let myInfo = try! carrier.getSelfUserInfo()
        if myInfo.name?.isEmpty ?? true {
            myInfo.name = UIDevice.current.name
            try? carrier.setSelfUserInfo(myInfo)
        }

        try? _ = CarrierSessionManager.createInstance(carrier: carrier, sessionRequestHandler: { (carrier, frome, sdp) in
            
        })
    }
    
    public func selfUserInfoDidChange(_ carrier: Carrier,
                                      _ newInfo: CarrierUserInfo) {
        NotificationCenter.default.post(name: .selfInfoChanged, object: nil)
    }
    
    public func didReceiveFriendsList(_ carrier: Carrier,
                                      _ friends: [CarrierFriendInfo]) {
        var friendList = [UserInfo]()
        for friend in friends {
            let userInfo = UserInfo()
            if friend.status == CarrierConnectionStatus.Connected {
                friendConnectionDidChange(carrier, friend.userId!, CarrierConnectionStatus.Connected)
            }
            userInfo.name = friend.name
            if friend.name == "" {
                userInfo.name = friend.userId
            }
            userInfo.userId = friend.userId
            userInfo.remote = true
            userInfo.status = friend.status
            friendList.append(userInfo)
        }
        NotificationCenter.default.post(name: .deviceListChanged, object: self, userInfo: ["friends":friendList])
    }
    
    public func friendInfoDidChange(_ carrier: Carrier,
                                    _ friendId: String,
                                    _ newInfo: CarrierFriendInfo) {
        print("friendInfoDidChange : \(newInfo)")
        NotificationCenter.default.post(name: .friendInfoChanged, object: self, userInfo: ["friendInfo":newInfo])
    }
    
    public func friendConnectionDidChange(_ carrier: Carrier,
                                          _ friendId: String,
                                          _ newStatus: CarrierConnectionStatus) {
        print("friendConnectionDidChange: \(newStatus)")
        let friendInfo = UserInfo()
        friendInfo.userId = friendId
        friendInfo.status = newStatus
        NotificationCenter.default.post(name: .friendStatusChanged, object: self, userInfo: ["friendInfo":friendInfo])
    }
    
    public func didReceiveFriendRequest(_ carrier: Carrier,
                                        _ userId: String,
                                        _ userInfo: CarrierUserInfo,
                                        _ hello: String) {
        print("didReceiveFriendRequest, userId : \(userId), name : \(String(describing: userInfo.name)), hello : \(hello)")
        do {
            try carrier.acceptFriend(with: userId)
        } catch {
            NSLog("Accept friend \(userId) error : \(error.localizedDescription)")
        }
        NotificationCenter.default.post(name: .acceptFriend, object: self, userInfo: ["friendInfo":userInfo])
    }
    
    public func didReceiveFriendResponse(_ carrier: Carrier,
                                         _ userId: String,
                                         _ status: Int,
                                         _ reason: String?,
                                         _ entrusted: Bool,
                                         _ expire: String?) {
        print("didReceiveFriendResponse, userId : \(userId)")
    }
    
    public func newFriendAdded(_ carrier: Carrier,
                               _ newFriend: CarrierFriendInfo) {
        print("newFriendAdded : \(newFriend)")
        NotificationCenter.default.post(name: .friendAdded, object: self, userInfo: ["friendInfo":newFriend])
    }
    
    public func friendRemoved(_ carrier: Carrier,
                              _ friendId: String) {
        print("friendRemoved, userId : \(friendId)")

    }

    func didReceiveFriendMessage(_ carrier: Carrier, _ from: String, _ data: Data, _ timestamp: Date, _ isOffline: Bool) {
        print("didReceiveFriendMessage : \(data)")
        // test
        let msgStr = String(data: data, encoding: .utf8)
        let messageInfo = ["userId": from, "msg": msgStr]
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateformatter.string(from: timestamp)

        NotificationCenter.default.post(name: .didReceiveFriendMessage, object: self, userInfo: ["messageInfo": messageInfo])
    }

    public func didReceiveFriendInviteRequest(_ carrier: Carrier,
                                              _ from: String,
                                              _ data: String) {
        print("didReceiveFriendInviteRequest")
    }
}

// MARK: - GroupDelegate
extension DeviceManager: CarrierGroupDelegate {

    func groupDidConnect(_ group: CarrierGroup) {

        print(group)
    }

    func groupPeerListDidChange(_ group: CarrierGroup) {
        print(group)
    }

    func groupPeerNameDidChange(_ group: CarrierGroup, _ from: String, _ newName: String) {
        print(group)
    }

    func groupTitleDidChange(_ group: CarrierGroup, _ from: String, _ newTitle: String) {
        print(group)
    }

}

