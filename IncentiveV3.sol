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

    mapping(address => SellerAccount) public _sellers;  // restituisce tutte le informazioni di un seller
    mapping(address => BuyerAccount) public _buyers;  // restituisce tutte le informazioni di un buyer
    mapping(uint256 => specialIncentive) public _specilaIncentives;  // restituisce tutte le informazioni di uno specifico specialIncentive
    mapping(uint256 => Incentive) public _incentive;  // restituisce tutte le informazioni di uno specifico Incentive
    mapping(address => uint256) public commentsPerBuyer;  // restituisce il numero di commenti lasciati da un utente specifico
    mapping(address => bool) public _isSeller;  // restituisce TRUE se l'address è di prorietà del Seller
    mapping(address => bool) public _isBuyer;  // restituisce TRUE se l'address è di prorietà del Buyer


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

 /*
   * @notice i dati necessari per creare un'account seller
   *
   * @param profileImage --> Immagine profilo dell'utente
   * @param seller --> L'address del proprietario di questo profilo, coincide con il mitente 
   * @param IdAccount --> L'id dell'account appena creato, viene impostato automaticamente
  **/ 
    struct SellerAccount{
        string profileImage;
        address seller;
        uint256 IdAccount;
    }

 /*
   * @notice i dati necessari per creare un'account buyer
   *
   * @param profileImage --> Immagine profilo dell'utente
   * @param buyer --> L'address del proprietario di questo profilo, coincide con il mitente 
   * @param IdAccount --> L'id dell'account appena creato, viene impostato automaticamente
  **/ 
    struct BuyerAccount{
        string profileImage;
        address buyer;
        uint256 IdAccount;
    }

 /*
   * @notice incentivo al quale si applica uno sconto
   *
   * @param incentiveURI --> Immagine/video che rappresenta il piato
   * @param price --> Il prezzo iniziale del piato
   * @param discount --> Lo sconto da applicare al piato, senza percentuale 20 = 20%
   * @param IdIncentive --> L'id dell'incentivo appena creato, viene impostato automaticamente
   * param creator --> L'address del account seller e deve coincidere con il mitente
  **/ 
    struct specialIncentive{
        string incentiveURI;
        uint256 price;
        uint256 discount;
        uint256 IdIncentive;
        address creator;
    }

/*
   * @notice incentivo con prezzo fisso
   *
   * @param name --> Il nome del piato
   * @param description --> descrizione del piato
   * @param incentiveURI --> Immagine/video che rappresenta il piato
   * @param price --> Il prezzo fisso del piato
   * @param IdIncentive --> L'id dell'incentivo appena creato, viene impostato automaticamente
   * param creator --> L'address del account seller e deve coincidere con il mitente
  **/
    struct Incentive {
        string incentiveURI;
        uint256 price;
        uint256 IdIncentive;
        address creator;
    }

 /*
   * @notice Commenti lasciati dai Buyers
   *
   * @param from --> L'address di chi scrive il commento
   * @param tokenId --> Il tokenId del incentivo che si vuole commentare
   * @param _comment --> Il contenuto del commento
   * @param timestamp --> L'ora in cui è stato rilasciato il commento
  **/

    struct CommentIncentive{
        address from;
        uint256 tokenId;
        string _comment;
        uint256 timestamp;
    }

/******************************** ARRAYS *************************************/
    SellerAccount[] sellers; // restituisce tutti gli account Seller
    BuyerAccount[] buyers; // restituisce tutti gli account Buyer
    specialIncentive[] specialIncentives; // restituisce tutti i specialIncentive
    Incentive[] incentives; // restituisce tutti gli incentive a prezzo fisso
    CommentIncentive[] allComments; // restituisce tutti i commenti

    constructor() ERC721("Incentive", "V3"){}


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

  // restituisce tutti i Seller Account
    function getSellersAccounts() public view returns(SellerAccount[] memory) {
        return sellers;
    }

  // restituisce tutti i Buyer Account
    function getBuyersAccounts() public view returns(BuyerAccount[] memory) {
        return buyers;
    }

  // restituisce tutti gli Incentivi a prezzo fisso
    function getIncentives() public view returns(Incentive[] memory) {
        return incentives;
    }
  
  // restituisce tutti gli Incentivi scontati
    function getSpecialIncentives() public view returns(specialIncentive[] memory) {
        return specialIncentives;
    }
  
  // restituisce tutti i commenti
    function getAllComments() public view returns(CommentIncentive[] memory){
        return allComments;
    }

  // restituisce il totale (numero) dei commenti
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
