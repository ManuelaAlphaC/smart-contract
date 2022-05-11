pragma solidity 0.7.5;

import "./avoOwnable.sol";

contract Bank is avoOwnable {
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

// solo il proprietario del contratto può ritirare i fondi
// pensato per applicare onlyOwner
    function withraw(uint amount) public onlyOwner returns (uint){
        require(balance[msg.sender] >= amount, "You cannot withdraw more than you have");
        msg.sender.transfer(amount);
        return balance[msg.sender];
    }
  
    function transfer(address to, uint amount) public {
        require(balance[msg.sender] >= amount, "Insufficient balance");
        require(msg.sender != to, "Don't transfer money to yourself");

        uint previousSenderBalance = balance[msg.sender];
        _transfer(msg.sender, to, amount);

        assert(balance[msg.sender] == previousSenderBalance - amount);
    }

    function _transfer(address from, address to, uint amount) private {
        balance[from] -= amount;
        balance[to] += amount;
    }
}
