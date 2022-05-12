import "./avoOwnable.sol";

pragma solidity 0.7.5;

contract avoDestroyable is avoOwnable {
    
    function seflDestruct() public onlyOwner {
        address payable receiver = msg.sender;
        selfdestruct(receiver);
    }
}
