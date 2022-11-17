// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract incentiveV1 is ERC721, ERC721Enumerable, ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(address => SellerAccount[]) public _sellers;
    mapping(address => BuyerAccount[]) public _buyers;
    mapping(uint256 => Incentive[]) public _incentives;

    mapping(address => bool) public _onlySellers;

    event WasCreatedSellerAccount(
        uint256 indexed IdAccount,
        string name,
        string profileImage,
        string bio,
        address indexed seller
    );

    event WasCreatedBuyerAccount(
        uint256 indexed IdAccount,
        string name,
        string profileImage,
        string preferences,
        address indexed buyer
    );

    event WasCreatedIncentive(
        uint256 indexed IdIncentive,
        address indexed creator,
        string name,
        string description,
        string incentiveURI,
        uint256 price,
        uint256 discount,
        uint256 newprice,
        uint256 save
    );

    struct SellerAccount{
        string name;
        string profileImage;
        string bio;
        address seller;
        uint256 IdAccount;
    }

    struct BuyerAccount{
        string name;
        string profileImage;
        string preferences;
        address buyer;
        uint256 IdAccount;
    }

    struct Incentive{
        string name;
        string description;
        string incentiveURI;
        uint256 price;
        uint256 discount; // numero senza percentuale 20 = 20%
        uint256 IdIncentive;
        address creator;
    }

    SellerAccount[] public sellers;
    BuyerAccount[] public buyers;
    Incentive[] public incentives;

    constructor() ERC721("Incentive", "V1"){}

    modifier onlySellers {
        require(_onlySellers[msg.sender]);
        _;
    }

  /******************* SELLER *************************/
    function createSellerProfile(
        string memory name,
        string memory profileImage,
        string memory bio,
        address seller
    ) public {
        uint256 IdAccount = _tokenIdCounter.current();
        sellers.push(SellerAccount(name, profileImage, bio, seller, IdAccount));
        _onlySellers[seller] = true;
        _tokenIdCounter.increment();
        _mint(seller, IdAccount);
        _setTokenURI(IdAccount, profileImage);

        emit WasCreatedSellerAccount(
            IdAccount,
            name,
            profileImage,
            bio,
            seller
        );
    }

 /******************* INCENTIVE *************************/
    function createIncentive(
        string memory name,
        string memory description,
        string memory incentiveURI,
        uint256 price,
        uint256 discount,
        address creator
    ) public onlySellers {
        uint256 IdIncentive = _tokenIdCounter.current();
        uint256 newprice = price - (price * (discount/100));
        uint256 save = price * (discount/100);
        incentives.push(Incentive(name, description, incentiveURI, price, discount, IdIncentive, creator));
        _tokenIdCounter.increment();
        _mint(msg.sender, IdIncentive);
        _setTokenURI(IdIncentive, incentiveURI);

        emit WasCreatedIncentive(
            IdIncentive,
            creator,
            name,
            description,
            incentiveURI,
            price,
            discount,
            newprice,
            save 
        );
    }

 /******************* BUYER *************************/
    function createBuyerAccount(
        string memory name,
        string memory profileImage,
        string memory preferences,
        address buyer
    ) public {
        uint256 IdAccount = _tokenIdCounter.current();
        buyers.push(BuyerAccount(name, profileImage, preferences, buyer, IdAccount));
        _tokenIdCounter.increment();
        _mint(buyer, IdAccount);
        _setTokenURI(IdAccount, profileImage);

        emit WasCreatedBuyerAccount(
            IdAccount,
            name,
            profileImage,
            preferences,
            buyer 
        );
    }

 /************************** GET FUNCTIONS *********************************/
    function getSellersAccounts() public view returns(SellerAccount[] memory) {
        return sellers;
    }

    function getBuyersAccounts() public view returns(BuyerAccount[] memory) {
        return buyers;
    }

    function getIncentives() public view returns(Incentive[] memory) {
        return incentives;
    }
 /************************************************************************/

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
