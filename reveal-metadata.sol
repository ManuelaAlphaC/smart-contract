// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
 
import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
 
 
contract Test is ERC721A, Ownable, ReentrancyGuard {
 
 using Strings for uint256;
 
 string public preRevealURI;
 string public postRevealURI;

 uint256 public price = 0.1 ether;
 uint256 public maxSupply = 10;
 uint256 public maxMintPerUser = 2;
 
 bool public paused = true;
 bool public revealed = false;
 
 
 constructor(string memory _prePreRevealURI) ERC721A("Name", "Symbol") {
     preRevealURI = _prePreRevealURI;
     setPreRevealURI(_prePreRevealURI);
 }
 
  /* ==================Modifiers======================= */
 modifier checksBeforeMint(uint256 _mintAmount) {
   require(_mintAmount > 0 && _mintAmount <= maxMintPerUser, "Invalid mint amount!");
   require(totalSupply() + _mintAmount <= maxSupply, "Max supply exceeded!");
   _;
 }
 
 modifier mintPrice(uint256 _mintAmount) {
   require(msg.value >= price * _mintAmount, "Insufficient funds!");
   _;
 }
 
 /* ===================Functions======================= */
 function mint(uint256 _mintAmount) public payable checksBeforeMint(_mintAmount) mintPrice(_mintAmount) {
   require(!paused, "The contract is paused!");
 
   _mint(_msgSender(), _mintAmount);
 }
 
 function _startTokenId() internal view virtual override returns (uint256) {
   return 1;
 }
 
 function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
   require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
 
   if (revealed == false) {
     return preRevealURI;
   }
 
   string memory currentBaseURI = _baseURI();
   return bytes(currentBaseURI).length > 0
       ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), ".json"))
       : '';
 }
 
 /* ==================Set functions OnlyOwner=================== */
 function setRevealed(bool _state) public onlyOwner {
   revealed = _state;
 }
 
 function setPreRevealURI(string memory _newPreRevealURI) public onlyOwner {
   preRevealURI = _newPreRevealURI;
 }

 function setPostRevealURI(string memory _newPostRevealURI) public onlyOwner {
     postRevealURI = _newPostRevealURI;
 }
 
 function setPaused(bool _state) public onlyOwner {
   paused = _state;
 }

 function _baseURI() internal view virtual override returns (string memory) {
   return postRevealURI;
 }

/* =====================Withdraw your founds========================== */
 function withdraw() public payable onlyOwner {
       (bool success, ) = payable(msg.sender).call{value:( address(this).balance)}("");
       require(success, "Transfer failed.");
   }
 
}
