// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.0;
 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
contract AVO is ERC721Enumerable, Ownable {
   using Strings for uint256;
 
   uint256 public maxSupply = 10;
   uint256 public maxPerAddress = 2;
   uint256 public price = 0.0005 ether; //public mint
   uint256 public cost = 0.0003 ether;  //wl mint
 
   string public baseURI;
   bool paused = false;
   bool onlyWLmint = true;
 
   address[] public WlAddresses;
 
   constructor() ERC721("AVO", "AVOnft"){
   }
  
   function mint(uint256 amount) public payable {
       require(!paused);
       uint256 supply = totalSupply();
       require(amount > 0);
       require(amount <= maxPerAddress);
       require(supply + amount <= maxSupply);
      
       if (msg.sender != owner()) {
           if (onlyWLmint == true){
               require(iswhiteListed(msg.sender),"User is not whitelisted.");
               uint256 ownerTokenCount = balanceOf(msg.sender);
               require(ownerTokenCount < maxPerAddress);
           }
       require(msg.value >= price * amount);
       }
      
       for (uint256 i = 1; i <= amount; i++) {
           _safeMint(msg.sender, supply + i);
       }
   }
  
   function iswhiteListed(address _user) public view returns (bool) {
       for (uint256 i = 0; i < WlAddresses.length; i++) {
           if (WlAddresses[i] == _user) { //se l'indirizzo dell'utente inserito coincide con quello nella funzione allora ci restituisce vero
           return true;
           }
       }
       return false;  //altrimenti esce dal ciclo for e ci restituisce falso
   }
   function walletOfOwner(address _owner) public view returns (uint256[] memory) {
       uint256 ownerTokenCount = balanceOf(_owner);
       uint256[] memory tokenIds = new uint256[](ownerTokenCount);
       for (uint256 i; i < ownerTokenCount; i++) {
           tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
       }
       return tokenIds;
   }
   function setBaseURI(string memory baseURI_) external onlyOwner() {
      baseURI = baseURI_;
   }
   function _baseURI() internal view virtual override returns (string memory) {
      return baseURI;
   }
   function pause(bool _state) public onlyOwner {
       paused = _state;
   }
   function setOnlyWhitelisted(bool state) public onlyOwner{
       onlyWLmint = state;
   }
 
   function whitelistUsers(address[] calldata _users ) public onlyOwner {
       delete WlAddresses;
       WlAddresses = _users;
   }
   function withdraw() public payable onlyOwner {
       (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
       require(success);
   }
}
