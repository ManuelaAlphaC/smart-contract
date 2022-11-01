// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Incentive is ERC721, ERC721Enumerable, ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(address => uint256) _incentivesCreate;

    event WasCreatedBusinessProfile(
        uint256 indexed profileId,
        address indexed to, 
        string imageProfile, 
        string name, 
        string bio
    );

    event WasCreatedUserProfile(
        uint256 indexed profileId,
        address indexed to,
        string imageProfile, 
        string name, 
        string bio
    );

    event WasCreatedIncentive(
        uint256 indexed incentiveId,
        address indexed to, 
        string contentURI,
        uint256 price,
        uint256 newprice,
        uint256 save
    );

    constructor()ERC721("Incentive","I"){}

    function createBusinessProfile(
        address to, 
        string memory imageProfile, 
        string memory name, 
        string memory bio
    ) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, imageProfile);

        emit WasCreatedBusinessProfile(
            tokenId, 
            msg.sender, 
            imageProfile,
            name,
            bio
        );
    }

    function createUserProfile(
        address to, 
        string memory imageProfile, 
        string memory name, 
        string memory bio
    ) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, imageProfile);

        emit WasCreatedUserProfile(
            tokenId, 
            msg.sender, 
            imageProfile,
            name,
            bio
        );
    }

    function createIncentive(
        address to, 
        string memory contentURI,
        uint256 price,
        uint256 discount
    ) external {
        uint256 newprice = price - (price * (discount/100));
        uint256 save = price * (discount/100);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, contentURI);
        _incentivesCreate[to] ++;

        emit WasCreatedIncentive(
            tokenId, 
            msg.sender, 
            contentURI,
            price,
            newprice,
            save
        );
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }
}
