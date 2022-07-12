// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

// 对address数组进行操作
library ArrayLibAddress {
    // 在给定数组中找到对应元素的索引
    function find(address[] storage arr, address v)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == v) {
                return i;
            }
        }
        revert("not found");
    }

    // 根据索引删除元素（不保证顺序）
    function removeByIndex(address[] storage arr, uint256 _index) internal {
        require(_index < arr.length, "index out of bound");
        arr[_index] = arr[arr.length - 1];
        arr.pop();
    }

    // 根据值是否相等删除第一个相等的元素（不保证顺序）
    function removeByVal(address[] storage arr, address val) internal {
        uint256 _index = find(arr, val);
        removeByIndex(arr, _index);
    }

    // 固定切12个
    function slice12(address[] memory arr, uint256 page)
        internal
        pure
        returns (address[12] memory)
    {
        uint256 end = page + 12;
        if (end >= arr.length) {
            end = arr.length;
        }
        address[12] memory res;
        for (uint256 i = page; i < end; i++) {
            res[i] = arr[i];
        }
        return res;
    }
}


