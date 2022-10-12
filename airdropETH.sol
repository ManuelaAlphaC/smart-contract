// SPDX-License-Identifier: MIT

// @author manuelacuci

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AirdropRoyaties is Ownable {
    address[] public recipients;
    address royaltyContainer;

    event IsAirdrop(address from, uint256 amount);

    constructor(address _royaltyContainer){
        royaltyContainer = _royaltyContainer;
    }

    function recipientsAddresses(address[] memory _recipients) external onlyOwner{
        for(uint256 i=0; i < _recipients.length; i++){
            recipients.push(_recipients[i]);
        }
    }

    function Airdrop(uint256 _airdrop) external payable {
        require(msg.sender == royaltyContainer);
        require(msg.value >= _airdrop, "Insufficient funds");
        uint256 share = msg.value / recipients.length;
        for(uint256 i=0; i < recipients.length; i++){
            payable(recipients[i]).transfer(share);
        }

        emit IsAirdrop(msg.sender, msg.value);
    }

    function changeRoyaltyContainer(address _royaltyContainer) public onlyOwner{
        royaltyContainer = _royaltyContainer;
    }

    function RecipientsAddr() public view returns(address[] memory){
        return recipients;
    }

    function isRoyaltyContainer() public view returns(address){
        return royaltyContainer;
    }
}
