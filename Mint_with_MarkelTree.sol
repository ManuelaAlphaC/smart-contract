// SPDX-License-Identifier: MIT
 
/**
     °°     °°         °°     °°°     #########     ###         #######      ######.
    °°°°     °°       °°   °°    °°      ##       ##  ##        ##    ##    ##   
   °°  °°     °°     °°    °°     °°     ##      ##    ##       #######       ####
  °°°°°°°°     °°   °°     °°     °°     ##     ## #### ##      ## ##              ##
 °°      °°     °° °°       °°   °°      ##    ##        ##     ##   ##     .       #
°°        °°     °°°          °°°        ##   ##          ##    ##    ##     ######
*/
 
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

contract TheGreateDolls is Ownable, ERC721A {

  using Strings for uint256;
  
  string public baseURI;

  uint256 private constant MAX_SUPPLY = 10000;
  uint256 private constant MAX_GIFT = 100;
  uint256 public price;
  uint256 public AVTperAddress;

  bytes32 public merkleRoot;

  bool public WlSaleStrt = true;
  bool public publicSaleStart = false;
  bool public reveal = false;
  bool public paused = false;
  bool public giftTime = false;

  mapping(address => uint) public amountNFTsperWlAddress;


  constructor(bytes32 _merkleRoot, string memory _baseURI) ERC721A("The Greate Dolls", "TGD") {
    merkleRoot = _merkleRoot;
    baseURI = _baseURI;
  }

  modifier callerIsUser() {
    require(tx.origin == msg.sender, "The caller is another contract!");
    _;
  }
  
  // URI
  function setBaseUri(string memory _baseURI) public onlyOwner {
    baseURI = _baseURI;
  }

  function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), "URI query for nonexistent token");

    return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
  }

  // Set onlyOwner
  function setNewPrice (uint256 _newPrice) public onlyOwner {
    price = _newPrice;
  }

  function setNewAmountPerAddress (uint256 _newAmount) public onlyOwner {
    AVTperAddress = _newAmount;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setWlSaleStart (bool _isStart) public onlyOwner {
    WlSaleStrt = _isStart;
  }

  function setGiftTime (bool _isGiftTime) public onlyOwner {
    giftTime = _isGiftTime;
  }
 

  // Wl/ public and gift Mint
  function whitelistMint(address _account, uint _amount, bytes32[] calldata _proof) public payable callerIsUser {
    require(!paused, "The contract is paused!");
    require(!WlSaleStrt, "Whitelist Sale has not started yet");
    require(isWhiteListed(msg.sender, _proof), "User is not in the WL!");
    require(price != 0, "Price is 0!");
    require(amountNFTsperWlAddress[msg.sender] + _amount <= AVTperAddress, "You can only get 1 NFT on the Whitelist Sale");
    require(totalSupply() + _amount <= MAX_SUPPLY + MAX_GIFT, "Max supply exceeded");
    require(msg.value >= price * _amount, "Not enought funds");
    amountNFTsperWlAddress [msg.sender] += _amount;
    _safeMint(_account, _amount);
  }


  function publicSaleMint(address _account, uint256 _amount) public payable callerIsUser {
    require(!paused, "The contract is paused!");
    require(!publicSaleStart, "Whitelist Sale has not started yet");
    require(price != 0, "Price is 0");
    require(totalSupply() + _amount <= MAX_SUPPLY + MAX_GIFT, "Max supply exceeded");
    require(msg.value >= price * _amount, "Not enought funds");
    _safeMint(_account, _amount);
  }

  function giftAVT(address _address, uint256 _amount) public onlyOwner {
    require(!paused,"The contract is paused!");
    require(!giftTime, "Gift is after the public sale!");
    require(totalSupply() + _amount <= MAX_SUPPLY, "Reached max Supply");
    _safeMint(_address, _amount);
  }
 
  //Markel Tree
  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function leaf(address _account) internal pure returns(bytes32) {
    return keccak256(abi.encodePacked(_account));
  }

  function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
    return MerkleProof.verify(_proof, merkleRoot, _leaf);
  }

  function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
    return _verify(leaf(_account), _proof);
  }

  //withrow
  function withdraw() public onlyOwner {
    uint256 sendAmount = address(this).balance;
    address n1 = payable(0xF3689b002C44cE96f0519E94F6A918DB69d5f8b7);
    address n2 = payable(0xfb4F84D869d13de13D4E0294D88EeEb41aa4b173);
    bool success;
      
    (success, ) = n1.call{value: (sendAmount * 800/1000)}("");
    require(success, "Transaction Unsuccessful");
  
    (success, ) = n2.call{value: (sendAmount * 200/1000)}("");
    require(success, "Transaction Unsuccessful");
  }
 
}
