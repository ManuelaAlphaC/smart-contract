// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract incentiveV1 is ERC721, ERC721Enumerable, ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 comments;

    mapping(address => SellerAccount) public _sellers;  // returns all the information of a seller
    mapping(address => BuyerAccount) public _buyers;  // returns all information about a buyer
    mapping(uint256 => specialIncentive) public _specilaIncentives;  // returns all the information of a specific specialIncentive
    mapping(uint256 => Incentive) public _incentive;  // returns all the information of a specific Incentive
    mapping(address => uint256) public commentsPerBuyer;  // returns the number of comments left by a specific user
    mapping(address => bool) public _isSeller;  // returns TRUE if the address is owned by the Seller
    mapping(address => bool) public _isBuyer;  // returns TRUE if the address is owned by the Buyer


/************************************* EVENTS **********************************/
    event WasCreatedSellerAccount(
        uint256 indexed IdAccount,
        string profileImage,
        address indexed seller
    );

    event WasCreatedBuyerAccount(
        uint256 indexed IdAccount,
        string profileImage,
        address indexed buyer
    );

    event WasCreatedSpecialIncentive(
        uint256 indexed IdIncentive,
        address indexed creator,
        string incentiveURI,
        uint256 price,
        uint256 discount,
        uint256 newprice,
        uint256 save
    );

    event WasCreatedIncentive(
        uint256 indexed IdIncentive,
        address indexed creator,
        string incentiveURI,
        uint256 price
    );

    event NewComment(
        address indexed from,
        uint256 tokenId,
        string _comment,
        uint256 timestamp
    );
/************************************** STRUCTS *******************************************/

 /**
  * @notice The data needed to create a seller account
  * 
  * @param profileImage Profile image of the Seller
  * @param seller The address of the owner of this profile coincides with the sender
  * @param IdAccount The account Id
  */
    struct SellerAccount{
        string profileImage;
        address seller;
        uint256 IdAccount;
    }

 /**
  * @notice The data needed to create a seller account
  * 
  * @param profileImage Profile image of the Buyer
  * @param buyer The address of the owner of this profile coincides with the sender
  * @param IdAccount The account Id
  */
    struct BuyerAccount{
        string profileImage;
        address buyer;
        uint256 IdAccount;
    }

 /**
  * @notice Incentive to which a discount is applied
  * 
  * @param incentiveURI Image/video representing the incentive
  * @param price The starting price of the incentive
  * @param discount The discount to be applied to the incentive, without percentage 20 = 20%
  * @param IdIncentive The account Id
  * @param creator The address of the seller account and must coincide with the sender
  */
    struct specialIncentive{
        string incentiveURI;
        uint256 price;
        uint256 discount;
        uint256 IdIncentive;
        address creator;
    }

 /**
  * @notice Incentive with fixed price
  * 
  * @param incentiveURI Image/video representing the incentive
  * @param price The fixed price of the incentive
  * @param IdIncentive The account Id
  * @param creator The address of the creator account and must coincide with the seller
  */
    struct Incentive {
        string incentiveURI;
        uint256 price;
        uint256 IdIncentive;
        address creator;
    }

 /**
  * @notice Comments left by Buyers
  * 
  * @param from The address of who writes the comment
  * @param tokenId The tokenId of the incentive you want to comment
  * @param _comment The content of the comment
  * @param timestamp The time the comment was released
  */

    struct CommentIncentive{
        address from;
        uint256 tokenId;
        string _comment;
        uint256 timestamp;
    }

/******************************** ARRAYS *************************************/
    SellerAccount[] sellers; // returns all Seller accounts
    BuyerAccount[] buyers; // return all Buyer accounts
    specialIncentive[] specialIncentives; // returns all specialIncentives
    Incentive[] incentives; // returns all fixed price incentives
    CommentIncentive[] allComments; // return all comments

    constructor() ERC721("Incentive", "V1"){}


  /******************* SELLER *************************/
    function createSellerProfile(
        string memory profileImage,
        address seller
    ) public {
        uint256 IdAccount = _tokenIdCounter.current();
        sellers.push(SellerAccount(profileImage, seller, IdAccount));
        _isSeller[seller] = true;
        _tokenIdCounter.increment();
        _mint(seller, IdAccount);
        _setTokenURI(IdAccount, profileImage);

        emit WasCreatedSellerAccount(
            IdAccount,
            profileImage,
            seller
        );
    }

 /******************* INCENTIVE *************************/
    function createSpecialIncentive(
        string memory incentiveURI,
        uint256 price,
        uint256 discount,
        address creator
    ) public  {
        uint256 IdIncentive = _tokenIdCounter.current();
        uint256 newprice = price - (price * (discount/100));
        uint256 save = price * (discount/100);
        specialIncentives.push(specialIncentive(incentiveURI, price, discount, IdIncentive, creator));
        _tokenIdCounter.increment();
        _mint(msg.sender, IdIncentive);
        _setTokenURI(IdIncentive, incentiveURI);

        emit WasCreatedSpecialIncentive(
            IdIncentive,
            creator,
            incentiveURI,
            price,
            discount,
            newprice,
            save 
        );
    }

    function createIncentive(
        string memory incentiveURI,
        uint256 price,
        address creator
    ) public  {
        uint256 IdIncentive = _tokenIdCounter.current();
        incentives.push(Incentive(incentiveURI, price, IdIncentive, creator));
        _tokenIdCounter.increment();
        _mint(msg.sender, IdIncentive);
        _setTokenURI(IdIncentive, incentiveURI);

        emit WasCreatedIncentive(
            IdIncentive,
            creator,
            incentiveURI,
            price
        );
    }

 /******************************** BUYER *********************************/
    function createBuyerAccount(
        string memory profileImage,
        address buyer
    ) public {
        uint256 IdAccount = _tokenIdCounter.current();
        buyers.push(BuyerAccount(profileImage, buyer, IdAccount));
        _isBuyer[buyer] = true;
        _tokenIdCounter.increment();
        _mint(buyer, IdAccount);
        _setTokenURI(IdAccount, profileImage);

        emit WasCreatedBuyerAccount(
            IdAccount,
            profileImage,
            buyer 
        );
    }

    function WriteComment(
        string memory _myComment,
        uint256 tokenId
        ) public {
        allComments.push(CommentIncentive(msg.sender, tokenId, _myComment, block.timestamp));
        comments ++;
        commentsPerBuyer[msg.sender] ++;

        emit NewComment(
            msg.sender,
            tokenId,
            _myComment,
            block.timestamp
        );
    }

 /************************** GET FUNCTIONS *********************************/

  // returns all Seller Accounts
    function getSellersAccounts() public view returns(SellerAccount[] memory) {
        return sellers;
    }

  // return all Buyer Accounts
    function getBuyersAccounts() public view returns(BuyerAccount[] memory) {
        return buyers;
    }

  // returns all fixed price Incentives
    function getIncentives() public view returns(Incentive[] memory) {
        return incentives;
    }
  
  // returns all discounted Incentives
    function getSpecialIncentives() public view returns(specialIncentive[] memory) {
        return specialIncentives;
    }
  
  // return all comments
    function getAllComments() public view returns(CommentIncentive[] memory){
        return allComments;
    }

  // return the total (number) of comments
    function getTotalComments() public view returns(uint256) {
        return comments;
    }

  /***************************************************************************/

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override (ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
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
