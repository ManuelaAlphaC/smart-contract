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
    mapping(uint256 => specialIncentive[]) public _incentives;

    mapping(address => bool) public _onlySellers;

/************************************* EVENTS **********************************/
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

    event WasCreatedSpecialIncentive(
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

    event WasCreatedIncentive(
        uint256 indexed IdIncentive,
        address indexed creator,
        string name,
        string description,
        string incentiveURI,
        uint256 price
    );
 /************************************** STRUCTS *******************************************/

 /*
   * @notice i dati necessari per creare un'account seller
   *
   * @param name --> Il nome utente
   * @param profileImage --> Immagine profilo dell'utente
   * @param bio --> Una breve descrizione sul seller
   * @param seller --> L'address del proprietario di questo profilo, coincide con il mitente 
   * @param IdAccount --> L'id dell'account appena creato, viene impostato automaticamente
 */ 
    struct SellerAccount{
        string name;
        string profileImage;
        string bio;
        address seller;
        uint256 IdAccount;
    }

 /*
   * @notice i dati necessari per creare un'account buyer
   *
   * @param name --> Il nome utente
   * @param profileImage --> Immagine profilo dell'utente
   * @param preferences --> Le preferenze dell'utente (cucina vegana, mediterranea, cinese)
   * @param buyer --> L'address del proprietario di questo profilo, coincide con il mitente 
   * @param IdAccount --> L'id dell'account appena creato, viene impostato automaticamente
 */ 
    struct BuyerAccount{
        string name;
        string profileImage;
        string preferences;
        address buyer;
        uint256 IdAccount;
    }

 /*
   * @notice incentivo al quale si applica uno sconto
   *
   * @param name --> Il nome del piato
   * @param description --> descrizione del piato
   * @param incentiveURI --> Immagine/video che rappresenta il piato
   * @param price --> Il prezzo iniziale del piato
   * @param discount --> Lo sconto da applicare al piato, senza percentuale 20 = 20%
   * @param IdIncentive --> L'id dell'incentivo appena creato, viene impostato automaticamente
   * param creator --> L'address del account seller e deve coincidere con il mitente
 */ 
    struct specialIncentive{
        string name;
        string description;
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
 */
    struct Incentive {
        string name;
        string description;
        string incentiveURI;
        uint256 price;
        uint256 IdIncentive;
        address creator;
    }

/******************************** ARRAYS *************************************/
    SellerAccount[] public sellers;
    BuyerAccount[] public buyers;
    specialIncentive[] public specialIncentives;
    Incentive[] public incentives;

    constructor() ERC721("Incentive", "V2"){}

/*
    modifier onlySellers {
        require(_onlySellers[msg.sender]);
        _;
    }
*/
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
    function createSpecialIncentive(
        string memory name,
        string memory description,
        string memory incentiveURI,
        uint256 price,
        uint256 discount,
        address creator
    ) public {
        uint256 IdIncentive = _tokenIdCounter.current();
        uint256 newprice = price - (price * (discount/100));
        uint256 save = price * (discount/100);
        specialIncentives.push(specialIncentive(name, description, incentiveURI, price, discount, IdIncentive, creator));
        _tokenIdCounter.increment();
        _mint(msg.sender, IdIncentive);
        _setTokenURI(IdIncentive, incentiveURI);

        emit WasCreatedSpecialIncentive(
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

    function createIncentive(
        string memory name,
        string memory description,
        string memory incentiveURI,
        uint256 price,
        address creator
    ) public {
        uint256 IdIncentive = _tokenIdCounter.current();
        incentives.push(Incentive(name, description, incentiveURI, price, IdIncentive, creator));
        _tokenIdCounter.increment();
        _mint(msg.sender, IdIncentive);
        _setTokenURI(IdIncentive, incentiveURI);

        emit WasCreatedIncentive(
            IdIncentive,
            creator,
            name,
            description,
            incentiveURI,
            price
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

    function getIncentives() public view returns(specialIncentive[] memory) {
        return specialIncentives;
    }
 /************************************************************************/

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
