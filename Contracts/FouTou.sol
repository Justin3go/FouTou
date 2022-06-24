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
    bytes32 private constant SUPER_ADMIN =
        keccak256(abi.encodePacked("SUPER_ADMIN"));
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));

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
    event AddFT(FT ft, uint tokenID);
    event Buy(uint indexed tokenID, address indexed account);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct FT {
        string tokenURI; // 必须是ipfs
        address owner;
        uint8 status; // 0: 正常，1: 盗版，2: 重新认证
        uint uploadtime; 
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
        string calldata _description
    ) internal view returns (FT memory ft) {
        require(_owner != address(0), "owner is address(0)");
        ft = FT(_tokenURI, _owner, 0, block.timestamp, _description);
    }

    function _bindTokenID(FT calldata ft) internal returns (uint) {
        uint newTokenID = _tokenIds.current();
        FTMap[newTokenID] = ft;
        emit AddFT(ft, newTokenID);

        _tokenIds.increment();
        return newTokenID;  // 返回的是当前绑定的ID
    }

    function _baseBuy(uint _tokenID, address _account) internal {
        address[] storage _buyers = buyers[_tokenID];
        _buyers.push(_account);
        emit Buy(_tokenID, _account);
    }
}

contract Person is Photo {
    struct PER {
        FT ownedFT;
    }
}

contract Copyright {}

contract Community {}

contract FouTou {}
