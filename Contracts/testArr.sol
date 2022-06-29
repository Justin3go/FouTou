// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract testArr{
    uint[] public arr = [0,11,22,33,44];
    function getArr() external view returns (uint[] memory){
        return arr;
    }
}