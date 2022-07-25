// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./utils/ArrayLibAddress.sol";
import "./utils/ArrayLibUint.sol";

// todo 需要重构event存储时间，因为有可能事件发生的时间可以直接查询到
// todo 不知道事件两个参数是不是可以不用加indexed，如果是，则又需要更改
// todo 记得加一个提钱的方法
// * 虽然我可以通过事件查询到是谁创造了FT，但是我们还是应该将其记录在FT结构体的记录中
contract Auth {
    // * 查询管理员有哪些就是Grant-Revoke，这里根据社区合约部分，也合并一下...
    // event GrantAdmin(address account);
    // event RevokeAdmin(address account);
    event TransferAdmin(address indexed account, bool indexed grantOrRevoke);
    event TransferSUPER_ADMIN(address oldAccount, address newAccount);
    event Register(address indexed admin, address account);
    // role -> account -> bool : 判断某个账户是否属于该角色
    mapping(bytes32 => mapping(address => bool)) public roles;

    bytes32 internal constant SUPER_ADMIN =
        keccak256(abi.encodePacked("SUPER_ADMIN"));
    bytes32 internal constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 internal constant USER = keccak256(abi.encodePacked("USER"));

    // 设置一些定量以后使用
    uint16 public ADMIN_NUM = 30; // 预计管理员数量
    int32 public REQUIRED_ADMIN = 15; // 多少管理员同意才能完成盗版认证
    uint256 public REQUIRED_REPORTER = 100; // 多少用户举报才会提交申请
    uint public REPORT_ETHER = 1000000000;  // 举报需要花费的ether
    uint public REPORT_FEEDBACK = 1000000000;  // 那么举报成功了就应该有嘉奖，这里先退还
    uint256 public REQUIRED_FANS = 500; // 多少粉丝数才有被举报的功能
    uint256 internal FEE = 20; // 除以100，代表5%
    bool public IS_TEST_VERSION = true; // 是否公开注册

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "1");
        _;
    }

    constructor() {
        roles[SUPER_ADMIN][msg.sender] = true;
        roles[ADMIN][msg.sender] = true;
        roles[USER][msg.sender] = true;
        // LOG中零地址到某个地址代表：记录部署合约的人成为超级管理员的事件
        emit TransferSUPER_ADMIN(address(0), msg.sender);
    }

    function setConfig(
        uint16 _ADMIN_NUM,
        int32 _REQUIRED_ADMIN,
        uint256 _REQUIRED_REPOERTER,
        uint _REPORT_ETHER,
        uint _REPORT_FEEDBACK,
        uint256 _REQUIRED_FANS,
        bool _IS_TEST_VERSION
    ) external onlyRole(SUPER_ADMIN) {
        ADMIN_NUM = _ADMIN_NUM;
        REQUIRED_ADMIN = _REQUIRED_ADMIN;
        REQUIRED_REPORTER = _REQUIRED_REPOERTER;
        REPORT_ETHER = _REPORT_ETHER;
        REPORT_FEEDBACK = _REPORT_FEEDBACK;ƒ
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

    function _USER2ADMIN(address _account) private {
        require(!roles[ADMIN][_account], "2");
        roles[ADMIN][_account] = true;
        emit TransferAdmin(_account, true);
    }

    function USER2ADMIN(address _account) external onlyRole(SUPER_ADMIN) {
        _USER2ADMIN(_account);
    }

    function _ADMIN2USER(address _account) private {
        require(roles[ADMIN][_account], "3");
        roles[ADMIN][_account] = false;
        emit TransferAdmin(_account, false);
    }

    function ADMIN2USER(address _account) external onlyRole(SUPER_ADMIN) {
        _ADMIN2USER(_account);
    }

    function registerByAdmin(address _account) external onlyRole(ADMIN) {
        require(!roles[USER][_account], "4");
        roles[USER][_account] = true;
        emit Register(msg.sender, _account);
    }

    function publicRegister(address _account) external {
        require(!IS_TEST_VERSION, "5");
        require(!roles[USER][_account], "4");
        roles[USER][_account] = true;
        emit Register(address(0), _account);
    }
}

contract Photo {
    event CreateFT(address indexed account, uint256 indexed tokenID, FT ft);
    event AlertPrice(uint256 indexed tokenID, uint256 newPrice);
    event AlertDescription(uint256 indexed tokenID, string newDes);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct FT {
        string tokenURI; // 必须是ipfs
        address payable owner;
        bool status; // false: 正常，ture: 盗版
        uint256 reportCount; // 举报数
        uint256 price;
        string description; // string化的json数组，由前端解析。
    }
    // tokenID => FT
    mapping(uint256 => FT) public FTMap;
    // tokenID => buyers
    mapping(uint256 => address[]) private buyers;

    function getBuyers(uint256 _tokenID)
        external
        view
        returns (address[] memory)
    {
        return buyers[_tokenID];
    }

    // 这里的baseXXX()函数仅仅将数据记录在了图片的相关数据结构中，并没有记录在用户的相关数据结构中
    function _baseMint(
        string calldata _tokenURI,
        address payable _owner,
        uint256 _price,
        string calldata _description
    ) internal pure returns (FT memory ft) {
        require(_owner != address(0), "6");
        ft = FT(_tokenURI, _owner, false, 0, _price, _description);
    }

    function _bindTokenID(FT memory ft) internal returns (uint256) {
        uint256 newTokenID = _tokenIds.current();
        FTMap[newTokenID] = ft;
        emit CreateFT(msg.sender, newTokenID, ft);

        _tokenIds.increment();
        return newTokenID; // 返回的是当前绑定的ID
    }

    function _baseBuy(uint256 _tokenID, address _account) internal {
        buyers[_tokenID].push(_account);
    }

    function alertPrice(uint256 _tokenID, uint256 _newPrice) external {
        FT storage ft = FTMap[_tokenID];
        require(ft.owner == msg.sender, "7");
        ft.price = _newPrice;

        emit AlertPrice(_tokenID, _newPrice);
    }

    function alertDescription(uint256 _tokenID, string calldata _newDes)
        external
    {
        FT storage ft = FTMap[_tokenID];
        require(ft.owner == msg.sender, "7");
        ft.description = _newDes;

        emit AlertDescription(_tokenID, _newDes);
    }
}

contract Person is Auth {
    event AlertPER_items(address indexed account, string newItems);
    event AlertPER_ad(address indexed account, string newAd);
    // 这类事件其实都可以合并一下
    // event ReducePER_credit(address indexed admin, address indexed account);
    // event RevokeReduce(address indexed admin, address indexed account);
    event AlertCredit(
        address indexed admin,
        address indexed account,
        bool reduceOrRevoke
    );
    // 用户信息
    mapping(address => string) public PER_items; // string化的json数据，存储个人信息
    mapping(address => string) public PER_ad; // 设置广告等级和广告图片链接，exp:1$http://www.example.com/pic.png
    mapping(address => int8) public PER_credit; // 信誉值 -100~0, 只有减少和撤销减少
    mapping(address => uint256[]) internal PER_ownedFT; // FT只增不删
    mapping(address => uint256[]) internal PER_boughtFT;
    mapping(address => address[]) internal PER_fans;
    mapping(address => address[]) internal PER_follow; // 取关可能消耗很多gas

    // 每位管理员对同一位用户只能减少一次信誉分，这里表示是否已经修改过
    mapping(address => mapping(address => bool)) private AlertedCreditLog;
    // 不能重复关注和重复取关，这里记录是否关注
    mapping(address => mapping(address => bool)) internal isFollowed;

    function getPER_ownedFT(address _account)
        external
        view
        returns (uint256[] memory)
    {
        return PER_ownedFT[_account];
    }

    function getPER_boughtFT(address _account)
        external
        view
        returns (uint256[] memory)
    {
        return PER_boughtFT[_account];
    }

    function getPER_fans(address _account)
        external
        view
        returns (address[] memory)
    {
        return PER_fans[_account];
    }

    function getPER_follow(address _account)
        external
        view
        returns (address[] memory)
    {
        return PER_follow[_account];
    }

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
            "8"
        );
        require(PER_credit[_account] >= -100, "9");
        PER_credit[_account]--; // 每次只能减一分
        AlertedCreditLog[msg.sender][_account] = true; // 表示已经修改过了
        emit AlertCredit(msg.sender, _account, true);
    }

    function revokeReduce(address _account) external onlyRole(ADMIN) {
        require(
            AlertedCreditLog[msg.sender][_account], // 需要操作过
            "10"
        );
        PER_credit[_account]++;
        AlertedCreditLog[msg.sender][_account] = false;
        emit AlertCredit(msg.sender, _account, false);
    }
}

contract Copyright is Photo, Person {
    event Submit(uint256 tokenID);
    event Report(address indexed reporter, uint256 indexed tokenID);
    // action: 1->approve, 2->reject, 3->ignore
    event ProcessAction(
        address indexed admin,
        uint256 indexed tokenID,
        uint8 approve1reject2ignore3
    );
    // event Approve(address indexed admin, uint256 indexed tokenID);
    // event Reject(address indexed admin, uint256 indexed tokenID);
    // event Ignore(address indexed admin, uint256 indexed tokenID);
    event Pirate(uint256 tokenID);
    event BuyFT(
        address indexed sender,
        address indexed account,
        uint256 indexed tokenID,
        FT ft
    );
    // 有两类消息：1.盗版认证消息，2.盗版申述消息（算了，不要2，直接增加盗版认证的难度就可以了）
    // tokenID -> [reporters]
    mapping(uint256 => address[]) private MES_reporters; // 举报人集合
    // tokenID -> reporter -> 是否举报过
    mapping(uint256 => mapping(address => bool)) private isReported; // 是否举报过一次
    uint256[] private reportedTokenID;  // 举报失败呢，没有，所以还要增加举报的难度，举报需要钱（已加）
    // tokenID -> 多少管理员同意了，有可能为负，代表拒绝的多一点
    mapping(uint256 => int32) public approveCount;
    mapping(uint => bool) private isSubmited;   // 是否已经提交过了，如果是，则不能再举报了
    // tokenID -> admin -> bool 管理员是否已经处理过该消息了
    mapping(uint256 => mapping(address => bool)) public isProcessed;
    mapping(address => uint256[]) private processed; // 获取某位管理员处理过的所有消息(tokenID)

    function getProcessed(address _admin)
        external
        view
        returns (uint256[] memory)
    {
        return processed[_admin];
    }

    function getMES_reporters(uint256 _tokenID)
        external
        view
        returns (address[] memory)
    {
        return MES_reporters[_tokenID];
    }
    // 数组的获取不能用public，而要单独写一个函数返回（一般来说，这个数组会很小）
    function getReportedTokenID() external view returns (uint256[] memory) {
        return reportedTokenID;
    }

    function _submit(uint256 _tokenID) private {
        reportedTokenID.push(_tokenID);
        // 提交后不可再举报
        isSubmited[_tokenID] = true;
        emit Submit(_tokenID);
    }

    modifier greaterFansNum(uint256 _tokenID) {
        address owner = FTMap[_tokenID].owner;
        uint256 fans = PER_fans[owner].length;
        require(fans >= REQUIRED_FANS, "11");
        _;
    }

    function report(uint256 _tokenID)
        external
        payable 
        onlyRole(USER)
        greaterFansNum(_tokenID)
    {
        // greaterFansNum:只能举报超过规定粉丝数的博主
        require(msg.value >= REPORT_ETHER,  "14");
        require(!isReported[_tokenID][msg.sender], "12");
        require(!isSubmited[_tokenID], "17");
        MES_reporters[_tokenID].push(msg.sender);
        // ==在刚好达到这个数时只执行一次
        if (MES_reporters[_tokenID].length == REQUIRED_REPOERTER) {
            _submit(_tokenID);
        }
        isReported[_tokenID][msg.sender] = true;
        emit Report(msg.sender, _tokenID);
    }

    modifier notProcessed(uint256 _tokenID, address _admin) {
        require(!isProcessed[_tokenID][_admin], "13");
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
            // 从消息中删除
            ArrayLibUint.removeByVal(reportedTokenID, _tokenID);
            // 发送铸币给举报者，嘉奖，这里需要钱够
            address[] memory arr = MES_reporters[_tokenID];
            for(uint i = 0; i < arr.length; i++){
                payable(arr[i]).transfer(REPORT_FEEDBACK);
            }
            emit Pirate(_tokenID);
        }
        isProcessed[_tokenID][msg.sender] = true;
        processed[msg.sender].push(_tokenID);

        emit ProcessAction(msg.sender, _tokenID, 1);
    }

    function reject(uint256 _tokenID)
        external
        onlyRole(ADMIN)
        notProcessed(_tokenID, msg.sender)
    {
        approveCount[_tokenID]--;
        isProcessed[_tokenID][msg.sender] = true;
        processed[msg.sender].push(_tokenID);

        emit ProcessAction(msg.sender, _tokenID, 2);
    }

    function ignore(uint256 _tokenID)
        external
        onlyRole(ADMIN)
        notProcessed(_tokenID, msg.sender)
    {
        isProcessed[_tokenID][msg.sender] = true;
        processed[msg.sender].push(_tokenID);

        emit ProcessAction(msg.sender, _tokenID, 3);
    }

    // 传入地址可以为别人购买
    function buyFT(uint256 _tokenID, address _account)
        external
        payable
        onlyRole(USER)
    {
        // 1.计算平台费+售价
        uint256 price = FTMap[_tokenID].price;
        uint256 fee = price / FEE;
        uint256 totalPrice = price + fee;
        // 2.比较用户支付金额与totalPrice，多退少弃
        require(msg.value >= totalPrice, "14");
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

        emit BuyFT(msg.sender, _account, _tokenID, FTMap[_tokenID]);
    }

    function createFT(
        string calldata _tokenURI,
        address payable _owner,
        uint256 _price,
        string calldata _description
    ) external onlyRole(USER) {
        PER_ownedFT[_owner].push(
            _bindTokenID(_baseMint(_tokenURI, _owner, _price, _description))
        );
        // bind 里面已经触发了事件了
    }

    fallback() external payable {}

    receive() external payable {}
}

contract Community is Copyright {
    // ? 如果反复横跳关注和取消关注，我该如何查询粉丝和关注者呢呢？
    // * 分别查询某个账户的这两个数组，然后根据先后顺序进行判断：比如我查询前10个，其中follow的事件那就一定是其粉丝，而其中cancelFollow的则一定不是其粉丝，需要记录。
    // todo 是不是可以把这两个事件给合到一起，用一个bool变量来标记，这样是不是更好查询？后续写前端的时候再来看看...
    // 合并了的好处就是可以根据时间（区块号）查询一定范围里面的事件

    // event Follow(address indexed sender, address indexed account);
    // event CancelFollow(address indexed sender, address indexed account);
    event AlertFollow(
        address indexed sender,
        address indexed account,
        bool indexed followOrCancel
    );

    function follow(address _account) external onlyRole(USER) {
        require(!isFollowed[msg.sender][_account], "15");
        // 双方数组互相添加
        PER_fans[_account].push(msg.sender);
        PER_follow[msg.sender].push(_account);

        isFollowed[msg.sender][_account] = true;
        emit AlertFollow(msg.sender, _account, true);
    }

    function cancelFollow(address _account) external onlyRole(USER) {
        require(isFollowed[msg.sender][_account], "16");
        // 双方数组互相删除
        ArrayLibAddress.removeByVal(PER_fans[_account], msg.sender);
        ArrayLibAddress.removeByVal(PER_follow[msg.sender], _account);

        isFollowed[msg.sender][_account] = false;
        emit AlertFollow(msg.sender, _account, false);
    }
}

contract FouTou is Community {}
