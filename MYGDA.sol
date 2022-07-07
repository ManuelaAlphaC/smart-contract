// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol"; // done
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract MYGDA is ERC721A, Ownable, ERC2981, ERC721ABurnable, ReentrancyGuard {
    using SafeMath for uint256;

 // ==============VARIABLES================ //
    uint256 public MAX_SUPPLY = 10000;
    uint256 public MAX_PER_ADDRESS = 5;
    uint256 public PUBLIC_PRICE = 0 ether;
    uint256 public WL_PRICE = 0 ether;

    string public preRevealURI; // done
    string public postRevealURI;  // done
    string public levelUpURI;  // done

    bool public isMembersMint = true; // 1
    bool public isWlistMint = false;  // 2
    bool public isPublicMint = false; // 3
    
    address public royaltyToMembers;

    mapping(uint256 => bool) public userLevelUp;
    mapping(address => bool) public isWlMember;

    constructor(
        string memory _preRevealURI,
        address _royaltyToMembers
    ) ERC721A ("NAME","SYMBOL") {
        preRevealURI = _preRevealURI;
        royaltyToMembers = _royaltyToMembers;
    }

 // =====================Only Owner============================ //
    function setPreRevealURI(string memory newPreReveal) public onlyOwner {
        preRevealURI = newPreReveal;
    }

    function setPostRevealURIs(string memory newPostRevealURI, string memory newLevelUpURI) public onlyOwner {
        postRevealURI = newPostRevealURI;
        levelUpURI = newLevelUpURI;
    }

    function setIsWlistMint(bool _state) public onlyOwner {
        isWlistMint = _state;
    }

    function setIsPublicMint(bool _isStart) public onlyOwner {
        isPublicMint = _isStart;
    }

  // ------If the user levels up in the MYGDA app, his nft will be updated------
    function setUserIsLevelUp(uint256 tokenID, bool isLevelUp) public onlyOwner {
        require(!_exists(tokenID),"Nonexistent token");
        userLevelUp[tokenID] = isLevelUp;
    }
   
   /* -----------Pausable contract------------
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
  */

  // ===============Internal functions===================
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return '';
    }
  //
  
    function tokenURI(uint256 tokenID) public view virtual override returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = userLevelUp[tokenID] ? levelUpURI : postRevealURI;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _toString(tokenID))) : preRevealURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC721A, ERC721A, ERC2981)
        returns (bool)
    {
        return
            ERC2981.supportsInterface(interfaceId) ||
            super.supportsInterface(interfaceId);
    }


}
