// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

// @author Manuelita

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol"; // done
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MYGDA is ERC721A, Ownable, ERC2981, ERC721ABurnable, ReentrancyGuard {
    using SafeMath for uint256;
    using Strings for uint256;

 // ==============VARIABLES================ //
    uint256 public MAX_SUPPLY = 10000;
    uint256 public MAX_PER_ADDRESS = 5;
    uint256 public PUBLIC_PRICE = 0 ether;
    uint256 public WL_PRICE = 0 ether;

    string public preRevealURI; // done
    string public postRevealURI;  // done
    string public levelUpURI;  // done
    
    bool public reveal = false;
    bool public isMembersMint = true; // 1
    bool public isWlistMint = false;  // 2
    bool public isPublicMint = false; // 3
    
    address public royaltyToMembers;

    mapping(uint256 => bool) private userIsLevelUp;
    mapping(address => bool) public isWlMember;

    constructor(
        string memory _preRevealURI,
        address _royaltyToMembers
    ) ERC721A ("NAME","SYMBOL") {
        preRevealURI = _preRevealURI;
        royaltyToMembers = _royaltyToMembers;
    }

 // =====================Only Owner============================ //
    function setRevealed(bool _isReveal) public onlyOwner {
        reveal = _isReveal;
    }

    function setPreRevealURI(string memory newPreReveal) public onlyOwner {
        preRevealURI = newPreReveal;
    }

    function setPostRevealURIs(string memory newPostRevealURI) public onlyOwner {
        postRevealURI = newPostRevealURI;
    }

    function setLevelUpURI(string memory newLevelUpURI) public onlyOwner {
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
        userIsLevelUp[tokenID] = isLevelUp;
    }
   
   // -----------Pausable contract------------
    function pause() public onlyOwner {
        pause();
    }

    function unpause() public onlyOwner {
        unpause();
    }
  //

  // ===============Internal functions===================

    function tokenURI(uint256 tokenID) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = userIsLevelUp[tokenID] ? levelUpURI : postRevealURI;
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


  // ==========================Royalty============================
   /**
     * @dev Update the royalty percentage (500 = 5%)
     */
    function setRoyaltyInfo(uint96 newRoyaltyPercentage) public onlyOwner {
        _setDefaultRoyalty(royaltyToMembers, newRoyaltyPercentage);
    }

   /**
     * @dev Update the royalty wallet address
     */
    function setRoyaltyToMembers(address payable newAddress) public onlyOwner {
        require(newAddress == address(0), "Royalty To Members address cannot be 0");
        royaltyToMembers = newAddress;
    }


}
