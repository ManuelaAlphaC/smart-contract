// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// @author Manuelita

import "erc721a/contracts/ERC721A.sol"; // done
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // done
import "@openzeppelin/contracts/security/Pausable.sol"; // done
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol"; // done
import "@openzeppelin/contracts/token/common/ERC2981.sol"; // done
import "@openzeppelin/contracts/utils/Strings.sol"; // done

contract NftContract is ERC721A, Ownable, ERC2981, ERC721ABurnable, ReentrancyGuard {
    using SafeMath for uint256;
    using Strings for uint256;

 /* -------------VARIABLES-------------- */
    uint256 public MAX_SUPPLY = 10000;
    uint256 public PUBLIC_PRICE = 0.00001 ether;
    uint256 public WL_PRICE = 0.000001 ether;

    string public preRevealURI;
    string public postRevealURI;
    
    bool public reveal = false;
    bool public isWlistMint = false;
    bool public isPublicMint = false;
    
    address public royaltyToMembers;

    bytes32 public merkleRoot;

    constructor(
        string memory _preRevealURI,
        address _royaltyToMembers,
        bytes32 _merkleRoot
    ) ERC721A ("NAME","SYMBOL") {
        preRevealURI = _preRevealURI;
        royaltyToMembers = _royaltyToMembers;
        merkleRoot = _merkleRoot;
    }

 /* --------------------------Only Owner---------------------------- */
    function setRevealed(bool _isReveal) public onlyOwner {
        reveal = _isReveal;
    }

    function setPreRevealURI(string memory newPreReveal) public onlyOwner {
        preRevealURI = newPreReveal;
    }

    function setPostRevealURIs(string memory newPostRevealURI) public onlyOwner {
        postRevealURI = newPostRevealURI;
    }


    function setIsWlistMint(bool _state) public onlyOwner {
        isWlistMint = _state;
    }

    function setIsPublicMint(bool _isStart) public onlyOwner {
        isPublicMint = _isStart;
    }

    /*-------------------------Mint-------------------------------------*/

    function WlistMint(address _address, uint256 _amount, bytes32[] calldata _proof) public payable {
        require(!isWlistMint, "Not started");
        require(isWhiteListed(msg.sender, _proof), "User is not in the WL!");
        require(totalSupply() + _amount <= MAX_SUPPLY, "Supply out of stock");
        require(msg.value >= _amount * WL_PRICE, "Insufficient funds");
        _mint(_address, _amount);
    }

    function PublicMint(address _address, uint256 _amount) public payable {
        require(!isPublicMint, "Not started");
        require(totalSupply() + _amount <= MAX_SUPPLY, "Supply out of stock");
        require(msg.value >= _amount * PUBLIC_PRICE, "Insuffucient funds");
        _mint(_address, _amount);
    }
   
   /* ------------------------Pausable contract--------------------------*/
    function pause() public onlyOwner {
        pause();
    }

    function unpause() public onlyOwner {
        unpause();
    }
  
  /* -----------------------------Merkle tree-----------------------------*/
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

  /*-----------------------------Internal functions-----------------------------*/
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function tokenURI(uint256 tokenID) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = postRevealURI;
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


  /*----------------------------Royalty----------------------------
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

  /*-------------------------------Withdraw----------------------------------*/
    function withdraw() public onlyOwner {
      (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
      require(success);
   }

}
