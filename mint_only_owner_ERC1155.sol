// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
 
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
 
contract AVOHOUSES is ERC1155, Ownable, ERC1155Burnable {
  
//declares the variables, name and symbol
   string public name;
   string public symbol;
 
   mapping(uint256 => string) public tokenURI;
 
   constructor() ERC1155("") {
       name = "AVOHOUSES";
       symbol = "AVHs";
   }
 
//only owner can mint AVOHOUSES
   function mint(address _to, uint _id, uint _amount) public onlyOwner {
       _mint(_to, _id, _amount, "");
   }
 
   function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) public onlyOwner {
       _mintBatch(_to, _ids, _amounts, "");
   }
 
//the function allows you to burn the NFT, choose the ID and the quantity to burn
   function burn(uint _id, uint _amount) public {
       _burn(msg.sender, _id, _amount);
   }
 
   function burnBatch(uint[] memory _ids, uint[] memory _amounts) public {
       _burnBatch(msg.sender, _ids, _amounts);
   }
 
   function burnForMint(address _from, uint[] memory _burnIds, uint[] memory _burnAmounts, uint[] memory _mintIds, uint[] memory _mintAmounts) public onlyOwner {
       _burnBatch(_from, _burnIds, _burnAmounts);
       _mintBatch(_from, _mintIds, _mintAmounts, "");
   }

// set the id and uri of the nft
   function setURI(uint _id, string memory _uri) public onlyOwner {
       tokenURI[_id] = _uri;
       emit URI(_uri, _id);
   }
  
   function uri(uint _id) public override view returns (string memory) {
       return tokenURI[_id];
   }
}
