// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract TestRole {
    bytes32 public constant SUPER_ADMIN =
        keccak256(abi.encodePacked("SUPER_ADMIN"));
    bytes32 public constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 public constant USER = keccak256(abi.encodePacked("USER"));
}
// SUPER_ADMIN:0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
// ADMIN:0xd980155b32cf66e6af51e0972d64b9d5efe0e6f237dfaa4bdc83f990dd79e9c8
// USER:0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96