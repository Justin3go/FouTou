// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./utils/ArrayLib.sol";

contract Auth {
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);
    event TransferSUPER_ADMIN(address oldAccount, address newAccount);
    event Register(address indexed admin, address account, uint256 time);
    // role -> account -> bool : 判断某个账户是否属于该角色
    mapping(bytes32 => mapping(address => bool)) public roles;

    bytes32 internal constant SUPER_ADMIN =
        keccak256(abi.encodePacked("SUPER_ADMIN"));
    bytes32 internal constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 internal constant USER = keccak256(abi.encodePacked("USER"));

    // 设置一些定量以后使用
    uint16 public ADMIN_NUM = 30; // 预计管理员数量
    int32 public REQUIRED_ADMIN = 15; // 多少管理员同意才能完成盗版认证
    uint256 public REQUIRED_REPOERTER = 100; // 多少用户举报才会提交申请
    uint256 public REQUIRED_FANS = 500; // 多少粉丝数才有被举报的功能
    uint256 internal FEE = 20; // 除以100，代表5%
    bool IS_TEST_VERSION = true; // 是否公开注册

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _;
    }

    constructor() {
        roles[SUPER_ADMIN][msg.sender] = true;
        roles[ADMIN][msg.sender] = true;
        roles[USER][msg.sender] = true;
        // LOG中零地址到某个地址代表：记录部署合约的人成为超级管理员的事件
        emit TransferSUPER_ADMIN(address(0), msg.sender);
        emit GrantRole(USER, msg.sender);
        emit Register(msg.sender, msg.sender, block.timestamp);
    }

    function setConfig(
        uint16 _ADMIN_NUM,
        int32 _REQUIRED_ADMIN,
        uint256 _REQUIRED_REPOERTER,
        uint256 _REQUIRED_FANS,
        bool _IS_TEST_VERSION
    ) external onlyRole(SUPER_ADMIN) {
        ADMIN_NUM = _ADMIN_NUM;
        REQUIRED_ADMIN = _REQUIRED_ADMIN;
        REQUIRED_REPOERTER = _REQUIRED_REPOERTER;
        REQUIRED_FANS = _REQUIRED_FANS;
        IS_TEST_VERSION = _IS_TEST_VERSION;
    }

    function transferSUPER_ADMIN(address _account)
        external
        onlyRole(SUPER_ADMIN)
    {
        roles[SUPER_ADMIN][_account] = true;
        roles[SUPER_ADMIN][msg.sender] = false; // only one superadmin
        emit TransferSUPER_ADMIN(msg.sender, _account);
    }

    function _USER2ADMIN(address _account) internal {
        require(!roles[ADMIN][_account], "already admin");
        roles[ADMIN][_account] = true;
        emit GrantRole(ADMIN, _account);
    }

    function USER2ADMIN(address _account) external onlyRole(SUPER_ADMIN) {
        _USER2ADMIN(_account);
    }

    function _ADMIN2USER(address _account) internal {
        require(roles[ADMIN][_account], "already user");
        roles[ADMIN][_account] = false;
        emit RevokeRole(ADMIN, _account);
    }

    function ADMIN2USER(address _account) external onlyRole(SUPER_ADMIN) {
        _ADMIN2USER(_account);
    }

    function registerByAdmin(address _account) external onlyRole(ADMIN) {
        require(!roles[USER][_account], "This user is already registered!");
        roles[USER][_account] = true;
        emit Register(msg.sender, _account, block.timestamp);
    }

    function publicRegister(address _account) external {
        require(
            !IS_TEST_VERSION,
            "The registration is not public for the time being. Please contact the administrator to register"
        );
        roles[USER][_account] = true;
        emit Register(address(0), _account, block.timestamp);
    }
}

contract Photo {
    event AddFT(FT ft, uint256 tokenID);
    event Buy(uint256 indexed tokenID, address indexed account);
    event AlertPrice(uint256 indexed tokenID, uint256 newPrice, uint256 time);
    event AlertDescription(
        uint256 indexed tokenID,
        string newDes,
        uint256 time
    );

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct FT {
        string tokenURI; // 必须是ipfs
        address payable owner;
        bool status; // false: 正常，ture: 盗版
        uint256 reportCount; // 举报数
        uint256 price;
        uint256 uploadtime;
        string description; // string化的json数组，由前端解析。
    }
    // tokenID => FT
    mapping(uint256 => FT) public FTMap;
    // tokenID => buyers
    mapping(uint256 => address[]) public buyers;

    // 这里的baseXXX()函数仅仅将数据记录在了图片的相关数据结构中，并没有记录在用户的相关数据结构中
    // 但是事件是可以记录了的
    function _baseMint(
        string calldata _tokenURI,
        address payable _owner,
        uint256 _price,
        string calldata _description
    ) internal view returns (FT memory ft) {
        require(_owner != address(0), "owner is address(0)");
        ft = FT(
            _tokenURI,
            _owner,
            false,
            0,
            _price,
            block.timestamp,
            _description
        );
    }

    function _bindTokenID(FT memory ft) internal returns (uint256) {
        uint256 newTokenID = _tokenIds.current();
        FTMap[newTokenID] = ft;
        emit AddFT(ft, newTokenID);

        _tokenIds.increment();
        return newTokenID; // 返回的是当前绑定的ID
    }

    function _baseBuy(uint256 _tokenID, address _account) internal {
        address[] storage _buyers = buyers[_tokenID];
        _buyers.push(_account);
        emit Buy(_tokenID, _account);
    }

    function alertPrice(uint256 _tokenID, uint256 _newPrice) external {
        FT storage ft = FTMap[_tokenID];
        require(ft.owner == msg.sender, "You are not this FT's owner");
        ft.price = _newPrice;

        emit AlertPrice(_tokenID, _newPrice, block.timestamp);
    }

    function alertDescription(uint256 _tokenID, string calldata _newDes)
        external
    {
        FT storage ft = FTMap[_tokenID];
        require(ft.owner == msg.sender, "You are not this FT's owner");
        ft.description = _newDes;

        emit AlertDescription(_tokenID, _newDes, block.timestamp);
    }
}

contract Person is Auth {
    event AlertPER_items(address indexed account, string newItems);
    event AlertPER_ad(address indexed account, string newAd);
    event ReducePER_credit(address indexed admin, address indexed account);
    event RevokeReduce(address indexed admin, address indexed account);
    // 用户信息
    mapping(address => string) public PER_items; // string化的json数据，存储个人信息
    mapping(address => string) public PER_ad; // 设置广告等级和广告图片链接，exp:1$http://www.example.com/pic.png
    mapping(address => int8) public PER_credit; // 信誉值 -100~0, 只有减少和撤销减少
    mapping(address => uint256[]) public PER_ownedFT; // FT只增不删
    mapping(address => uint256[]) public PER_boughtFT;
    mapping(address => address[]) public PER_fans;
    mapping(address => address[]) public PER_follow; // 取关可能消耗很多gas

    // 每位管理员对同一位用户只能减少一次信誉分，这里表示是否已经修改过
    mapping(address => mapping(address => bool)) private AlertedCreditLog;
    // 不能重复关注和重复取关，这里记录是否关注
    mapping(address => mapping(address => bool)) internal isFollowed;

    // 只能自己修改自己的信息
    function alertPER_items(string calldata _items) external onlyRole(USER) {
        PER_items[msg.sender] = _items;
        emit AlertPER_items(msg.sender, _items);
    }

    function alertPER_ad(string calldata _ad) external onlyRole(USER) {
        PER_ad[msg.sender] = _ad;
        emit AlertPER_ad(msg.sender, _ad);
    }

    function reducePER_credit(address _account) external onlyRole(ADMIN) {
        require(
            !AlertedCreditLog[msg.sender][_account], // 需要未操作过
            "Cannot repeat operation for the same user"
        );
        require(PER_credit[_account] >= -100, "It's already the minimum");
        PER_credit[_account]--; // 每次只能减一分
        AlertedCreditLog[msg.sender][_account] = true; // 表示已经修改过了
        emit ReducePER_credit(msg.sender, _account);
    }

    function revokeReduce(address _account) external onlyRole(ADMIN) {
        require(
            AlertedCreditLog[msg.sender][_account], // 需要操作过
            "No operation for this user, cannot revoke"
        );
        PER_credit[_account]++;
        AlertedCreditLog[msg.sender][_account] = false;
        emit RevokeReduce(msg.sender, _account);
    }
}

contract Copyright is Photo, Person {
    event Submit(uint256 tokenID, uint256 time);
    event Report(
        address indexed reporter,
        uint256 indexed tokenID,
        uint256 time
    );
    event Approve(address indexed admin, uint256 indexed tokenID, uint256 time);
    event Reject(address indexed admin, uint256 indexed tokenID, uint256 time);
    event Ignore(address indexed admin, uint256 indexed tokenID, uint256 time);
    event Pirate(uint256 tokenID, uint256 time);
    event Buy(address sender, address account, uint256 tokenID, uint256 time);
    // 有两类消息：1.盗版认证消息，2.盗版申述消息（算了，不要2，直接增加盗版认证的难度就可以了）
    // tokenID -> [reporters]
    mapping(uint256 => address[]) public MES_reporters; // 举报人集合
    // tokenID -> reporter -> 是否举报过
    mapping(uint256 => mapping(address => bool)) public isReported; // 是否举报过一次
    // 已经提交的认证消息--提交的时间
    mapping(uint256 => uint256) public messageTime;
    uint256[] public reportedTokenID;
    // tokenID -> 多少管理员同意了，有可能为负，代表拒绝的多一点
    mapping(uint256 => int32) public approveCount;
    // tokenID -> admin -> bool 管理员是否已经处理过该消息了
    mapping(uint256 => mapping(address => bool)) public isProcessed;

    function _submit(uint256 _tokenID) internal {
        reportedTokenID.push(_tokenID);
        messageTime[_tokenID] = block.timestamp;
        emit Submit(_tokenID, block.timestamp);
    }

    modifier greaterFansNum(uint256 _tokenID) {
        address owner = FTMap[_tokenID].owner;
        uint256 fans = PER_fans[owner].length;
        require(fans >= REQUIRED_FANS, "less required fans");
        _;
    }

    function report(address _reporter, uint256 _tokenID)
        external
        onlyRole(USER)
        greaterFansNum(_tokenID)
    {
        // 只能举报超过规定粉丝数的博主
        require(!isReported[_tokenID][_reporter], "already reported");
        MES_reporters[_tokenID].push(_reporter);
        // ==在刚好达到这个数时只执行一次
        if (MES_reporters[_tokenID].length == REQUIRED_REPOERTER) {
            _submit(_tokenID);
        }
        isReported[_tokenID][_reporter] = true;
        emit Report(_reporter, _tokenID, block.timestamp);
    }

    modifier notProcessed(uint256 _tokenID, address _admin) {
        require(!isProcessed[_tokenID][_admin], "already processed");
        _;
    }

    function approve(uint256 _tokenID)
        external
        onlyRole(ADMIN)
        notProcessed(_tokenID, msg.sender)
    {
        if (
            ++approveCount[_tokenID] == REQUIRED_ADMIN &&
            !FTMap[_tokenID].status
        ) {
            // 盗版认证成功
            FTMap[_tokenID].status = true;
            emit Pirate(_tokenID, block.timestamp);
        }
        isProcessed[_tokenID][msg.sender] = true;
        emit Approve(msg.sender, _tokenID, block.timestamp);
    }

    function reject(uint256 _tokenID)
        external
        onlyRole(ADMIN)
        notProcessed(_tokenID, msg.sender)
    {
        approveCount[_tokenID]--;
        isProcessed[_tokenID][msg.sender] = true;
        emit Reject(msg.sender, _tokenID, block.timestamp);
    }

    function ignore(uint256 _tokenID)
        external
        onlyRole(ADMIN)
        notProcessed(_tokenID, msg.sender)
    {
        isProcessed[_tokenID][msg.sender] = true;
        emit Ignore(msg.sender, _tokenID, block.timestamp);
    }

    // 传入地址可以为别人购买
    function buy(uint256 _tokenID, address _account)
        external
        payable
        onlyRole(USER)
    {
        // 1.计算平台费+售价
        uint256 price = FTMap[_tokenID].price;
        uint256 fee = price / FEE;
        uint256 totalPrice = price + fee;
        // 2.比较用户支付金额与totalPrice，多退少弃
        require(
            msg.value >= totalPrice,
            "Transaction failed because of lack of ether."
        );
        uint256 refund = msg.value - totalPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        // 3.交易(先转给合约，再由合约抽取费用后转给卖家)
        address payable owner = FTMap[_tokenID].owner;
        owner.transfer(price);
        // 4.记录在FT中
        _baseBuy(_tokenID, _account);
        // 5.记录在PER_boughtFT中
        PER_boughtFT[_account].push(_tokenID);

        emit Buy(msg.sender, _account, _tokenID, block.timestamp);
    }

    function addFT(
        string calldata _tokenURI,
        address payable _owner,
        uint256 _price,
        string calldata _description
    ) external onlyRole(USER) {
        FT memory ft = _baseMint(_tokenURI, _owner, _price, _description);
        uint256 newTokenID = _bindTokenID(ft);
        PER_ownedFT[_owner].push(newTokenID);
        // bind 里面已经触发了事件了
    }

    fallback() external payable {}

    receive() external payable {}
}

contract Community is Copyright {
    event Follow(address indexed sender, address indexed account);
    event CancelFollow(address indexed sender, address indexed account);

    function follow(address _account) external onlyRole(USER) {
        require(!isFollowed[msg.sender][_account], "already followed");
        // 双方数组互相添加
        PER_fans[_account].push(msg.sender);
        PER_follow[msg.sender].push(_account);

        isFollowed[msg.sender][_account] = true;
        emit Follow(msg.sender, _account);
    }

    function cancelFollow(address _account) external onlyRole(USER) {
        require(isFollowed[msg.sender][_account], "already not followed");
        // 双方数组互相删除
        ArrayLib.removeByVal(PER_fans[_account], msg.sender);
        ArrayLib.removeByVal(PER_follow[msg.sender], _account);

        isFollowed[msg.sender][_account] = false;
        emit CancelFollow(msg.sender, _account);
    }
}

contract FouTou is Community {
    constructor(
        uint16 _ADMIN_NUM,
        int32 _REQUIRED_ADMIN,
        uint256 _REQUIRED_REPOERTER,
        uint256 _REQUIRED_FANS,
        bool _IS_TEST_VERSION
    ) {
        ADMIN_NUM = _ADMIN_NUM;
        REQUIRED_ADMIN = _REQUIRED_ADMIN;
        REQUIRED_REPOERTER = _REQUIRED_REPOERTER;
        REQUIRED_FANS = _REQUIRED_FANS;
        IS_TEST_VERSION = _IS_TEST_VERSION;
    }
}
