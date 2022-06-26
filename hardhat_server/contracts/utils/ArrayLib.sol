// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

library ArrayLib{
    // 在给定数组中找到对应元素的索引
    function find(address[] storage arr, address v) internal view returns (uint) {
        for(uint i = 0; i < arr.length; i++){
          if(arr[i] == v){
            return i;
          }
        }
        revert("not found");
    }
    // 根据索引删除元素（不保证顺序）
    function removeByIndex(address[] storage arr, uint _index) internal{
      require(_index < arr.length, "index out of bound");
      arr[_index] = arr[arr.length-1];
      arr.pop();
    }
    // 根据uint值是否相等删除第一个相等的元素（不保证顺序）
    function removeByVal(address[] storage arr, address val) internal {
      uint _index = find(arr, val);
      removeByIndex(arr, _index);
    }
}