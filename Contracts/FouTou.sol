// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract Auth {
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);
    event TransferSUPER_ADMIN(address oldAccount, address newAccount);
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

    function transferSUPER_ADMIN(address _account) external onlyRole(SUPER_ADMIN){
        roles[SUPER_ADMIN][_account] = true;
        roles[SUPER_ADMIN][msg.sender] = false;  // only one superadmin
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
}

contract Photo {}

contract Copyright {}

contract Community {}

contract Person {}

contract FouTou {}
