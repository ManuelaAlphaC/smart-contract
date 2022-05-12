pragma solidity 0.7.5;

import "./avoOwnable.sol";
import "./avoDestroyable.sol";

interface GovernmentInterface {
    function addTransaction(address _from, address _to, uint _amount) external;
}

contract Bank is avoOwnable, avoDestroyable {

    GovernmentInterface governmentInstance = GovernmentInterface(0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D);
    mapping(address => uint) balance;

    event depositDone(uint amount, address indexed depositedTo);

    function deposit() public payable returns(uint){
        balance[msg.sender] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return balance[msg.sender];
    }
 
    function getBalance() public view returns (uint){
        return balance[msg.sender];
    }

    function withraw(uint amount) public returns (uint){
        require(balance[msg.sender] >= amount, "You cannot withdraw more than you have");
        msg.sender.transfer(amount);
        balance[msg.sender]-= amount;
        return balance[msg.sender];
    }
  
    function transfer(address recipient, uint amount) public {
        require(balance[msg.sender] >= amount, "Insufficient balance");
        require(msg.sender != recipient, "Don't transfer money to yourself");

        uint previousSenderBalance = balance[msg.sender];
        _transfer(msg.sender, recipient, amount);

        governmentInstance.addTransaction(msg.sender, recipient, amount);

        assert(balance[msg.sender] == previousSenderBalance - amount);
    }

    function _transfer(address from, address to, uint amount) private {
        balance[from] -= amount;
        balance[to] += amount;
    }
}
