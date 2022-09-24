// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract Send {

    event Deposit(address _deposit, uint256 _amount);

    mapping(address => uint256) public balance;

    function deposit(uint256 _amount) public payable {
        require(msg.value >= _amount);
        balance[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function balanceOf(address _address) public view returns(uint256) {
        return balance[_address];
    }

    function _transfer(address from, address to, uint256 amount) private {
        balance[from] -= amount;
        balance[to] += amount;
    }

    function transfer(address _withdrow, uint256 amount) public {
        require(balance[_withdrow] >= amount);
        require(_withdrow != msg.sender);

        uint256 startBalance = balance[_withdrow];
        _transfer(_withdrow, msg.sender, amount);

        require(balance[_withdrow] == startBalance - amount);

    }

    function withdrow(address _withdrow, uint256 amount) public payable {
        require(balance[_withdrow] >= amount);
        require(msg.sender != _withdrow);
        payable(msg.sender).transfer(amount);
        balance[_withdrow] -= amount;
        balance[msg.sender] += amount;
    }
}
