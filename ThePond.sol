// SPDX-License-Identifier: MIT

// @author ThePond

/**
                                                                                 
                  .,,*,,,,,**                   ,,,,,,,*,,,                      
               .,,,,,      *,,*,             ,,,,,       *,,,,                   
              ,*,             ,*,,         .,,,             *,,,                 
            .,,        ,@@@     ,,,       *,,       /@@       ,,,                
            ,,       (@@@(       ,,*      ,*       @@@@        *,,               
           ,,,       @@@@@     @ ,,,,,,,,,,*      .@@@@@@%#@@@ *,,               
           ,,,       @@@@@@@@@@/ *,,,,,,,,,,       @@@@@@@@@@  ,,,               
           .,,,       *@@@@@@@   ,,,,,,,,,,,,        @@@@@@   *,,,,              
        *,,,,,,*               *,,,,,,,,,,,,,,               ,,,,,,,,*           
      ,,,,,,,,,,,,*         .,,,,,,,,,,,,,,,,,,,*         *,,,,,,,,,,,,,         
    ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,       
   ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.     
  ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,***,,,,,/**,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,     
 ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**//*,,,*//**,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,   
 .,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,    
  ,,,,,,,,,,,,,,,,, ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,. ,,,,,,,,,,,,,,,,,,,     
   ,,,,,,,,,,,,,,,,,,   *,,,,,,,,,,,,,,,,,,,,,,,,,,*   *,,,,,,,,,,,,,,,,,,,      
     ,,,,,,,,,,,,,,,,,,       *,,,,,,,,,,,,,,,,,     ,*,,,,,,,,,,,,,,,,,,.       
       ,,,,,,,,,,,,,,,,,**                         *,,,,,,,,,,,,,,,,,,,          
         .*,,,,,,,,,,,,,,,,,*   **************. .,,,,,,,,,,,,,,,,,,*,            
             ,,,,,,,,,,,,,,,,,,,,************,,,,,,,,,,,,,,,,,,,*                
                  .,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,                     
                          .*,,,,,,,,,,,,,,,,,,,,,,*.                             
                                                                                
*/


pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ThePond is ERC721, Ownable, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public maxSupply = 100;

    constructor() ERC721("The pond", "Tp") {}

    function Mint(address to, string memory uri) public onlyOwner {
        require(totalSupply() < maxSupply, "Connt mint more");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function transferOwnership(address newOwner) public override(Ownable) onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }
}
