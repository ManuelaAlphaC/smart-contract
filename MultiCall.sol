// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

contract CallFunctions {

    function number() external pure returns(uint256) {
        return 18;
    }

    function frase() external pure returns(string memory) {
        return "Have success";
    }  

    function getDataNumber() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.number.selector);
    }

    function getDataFrase() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.frase.selector);
    }

}


contract MultiCall {

    function multiCalls(address[] calldata targets, bytes[] calldata data) 
    public view returns(bytes[] memory) 
    {
        require(targets.length == data.length, "targets.length != data.length");
        bytes[] memory results = new bytes[](data.length);
        for (uint i; i< targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "call failed");
            results[i] = result;
        }
        return results;
    }
}
