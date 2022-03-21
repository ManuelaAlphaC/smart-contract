// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
contract AVOLAB is ERC721, Ownable {
  using Counters for Counters.Counter;
  using Strings for uint256 ;
  Counters.Counter _tokenIds;
 
  mapping(uint256 => string) _tokenURIs;
  
  struct RenderToken {
      uint256 id;
      string uri;
  }
   constructor() ERC721("AVOTAR", "AVT") {}
  function _setTokenURI(uint256 tokenId, string memory _tokenURI)internal {
      _tokenURIs[tokenId]= _tokenURI;
  }
  
  function tokenURI(uint256 tokenId) public view virtual override returns(string memory) {
      require(_exists(tokenId));
      string memory _tokenURI = _tokenURIs[tokenId];
      return _tokenURI;
  }
 
  function getAllowTokens() public view returns (RenderToken[] memory) {
      uint256 lastesId = _tokenIds.current();
      uint256 counter = 0;
      RenderToken[] memory res = new RenderToken[](lastesId);
      for (uint256 i=0; i < lastesId; i++) {
          if(_exists(counter)){
              string memory uri = tokenURI(counter);
              res[counter] = RenderToken(counter, uri);
          }
          counter++;
      }
      return res;
  }
 
 // enter the address of the recipient and the uri of the metadata
  function Mint(address recipient, string memory uri) public onlyOwner() returns (uint256) {
      uint256 newId = _tokenIds.current();
      _mint(recipient, newId);
// after each mint increment the token Id automatically
      _tokenIds.increment();
      _setTokenURI(newId, uri);
      return newId;
   }
}

//before to deploy your smart contract concerns the dependencies,
//comments that may have indications owned by the creator of the addiction
