// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "./utils/Counters.sol";

contract Auth {
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);
    event TransferSUPER_ADMIN(address oldAccount, address newAccount);
    event Register(address indexed admin, address account, uint256 time);
    // role -> account -> bool : 判断某个账户是否属于该角色
    mapping(bytes32 => mapping(address => bool)) public roles;
    //
    bytes32 internal constant SUPER_ADMIN =
        keccak256(abi.encodePacked("SUPER_ADMIN"));
    bytes32 internal constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 internal constant USER = keccak256(abi.encodePacked("USER"));

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _;
    }

    constructor() {
        roles[SUPER_ADMIN][msg.sender] = true;
        // LOG中零地址到某个地址代表：记录部署合约的人成为超级管理员的事件
        emit TransferSUPER_ADMIN(address(0), msg.sender);
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
        roles[ADMIN][_account] = true;
        emit GrantRole(ADMIN, _account);
    }

    function USER2ADMIN(address _account) external onlyRole(SUPER_ADMIN) {
        _USER2ADMIN(_account);
    }

    function _ADMIN2USER(address _account) internal {
        roles[ADMIN][_account] = false;
        emit RevokeRole(ADMIN, _account);
    }

    function ADMIN2USER(address _account) external onlyRole(SUPER_ADMIN) {
        _ADMIN2USER(_account);
    }

    function register(address _account) external onlyRole(ADMIN) {
        require(!roles[USER][_account], "This user is already registered!");
        roles[USER][_account] = true;
        emit Register(msg.sender, _account, block.timestamp);
    }
}

contract Photo {
    event AddFT(FT ft, uint256 tokenID);
    event Buy(uint256 indexed tokenID, address indexed account);
    event AlertPrice(uint256 indexed tokenID, uint256 newPrice, uint256 time);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct FT {
        string tokenURI; // 必须是ipfs
        address owner;
        uint8 status; // 0: 正常，1: 盗版，2: 重新认证
        uint reportCount;  // 举报数
        uint256 price;
        uint256 uploadtime;
        string description; // string化的json数组，由前端解析。
    }
    // tokenID => FT
    mapping(uint256 => FT) public FTMap;
    // tokenID => buyers
    mapping(uint256 => address[]) public buyers;

    // todo 之后还要记录在用户的结构体中
    // 这里的baseXXX()函数仅仅将数据记录在了图片的相关数据结构中，并没有记录在用户的相关数据结构中
    // 但是事件是可以记录了的
    function _baseMint(
        string calldata _tokenURI,
        address _owner,
        uint256 _price,
        string calldata _description
    ) internal view returns (FT memory ft) {
        require(_owner != address(0), "owner is address(0)");
        ft = FT(_tokenURI, _owner, 0, 0, _price, block.timestamp, _description);
    }

    function _bindTokenID(FT calldata ft) internal returns (uint256) {
        uint256 newTokenID = _tokenIds.current();
        FTMap[newTokenID] = ft;
        emit AddFT(ft, newTokenID);

        _tokenIds.increment();
        return newTokenID; // 返回的是当前绑定的ID
    }

    // todo 完整的还要交易铸币payable
    function _baseBuy(uint256 _tokenID, address _account) internal {
        address[] storage _buyers = buyers[_tokenID];
        _buyers.push(_account);
        emit Buy(_tokenID, _account);
    }

    function alertPrice(uint256 _tokenID, uint256 _newPrice) external {
        FT storage ft = FTMap[_tokenID];
        require(ft.owner == msg.sender, "You are not this FT's owner");
        ft.price = _newPrice;
    }
}

// todo 后续看看是否需要添加onlyRole(USER)
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
            !AlertedCreditLog[msg.sender][_account],  // 需要未操作过
            "Cannot repeat operation for the same user"
        );
        require(PER_credit[_account] >= -100, "It's already the minimum");
        PER_credit[_account]--; // 每次只能减一分
        AlertedCreditLog[msg.sender][_account] = true; // 表示已经修改过了
        emit ReducePER_credit(msg.sender, _account);
    }

    function revokeReduce(address _account) external onlyRole(ADMIN) {
        require(
            AlertedCreditLog[msg.sender][_account],  // 需要操作过
            "No operation for this user, cannot revoke"
        );
        PER_credit[_account]++;
        AlertedCreditLog[msg.sender][_account] = false;
        emit RevokeReduce(msg.sender, _account);
    }
}

contract Copyright {
    // ? 如何存储待处理版权的消息
}

contract Community {}

contract FouTou {}
