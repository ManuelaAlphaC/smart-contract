// SPDX-License-Identifier: MIT
 
/**
     °°     °°         °°     °°°     #########     ###         #######      ######.
    °°°°     °°       °°   °°    °°      ##       ##  ##        ##    ##    ##   
   °°  °°     °°     °°    °°     °°     ##      ##    ##       #######       ####
  °°°°°°°°     °°   °°     °°     °°     ##     ## #### ##      ## ##              ##
 °°      °°     °° °°       °°   °°      ##    ##        ##     ##   ##     .       #
°°        °°     °°°          °°°        ##   ##          ##    ##    ##     ######
*/
 
 
pragma solidity ^0.8.7;
 
import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
 
 
contract AVOTARS is ERC721A, Ownable, ReentrancyGuard {
 
 using Strings for uint256;
 
 bytes32 public merkleRoot;
 mapping(address => bool) public whitelisted;
 
 string public baseURI = "ipfs://QmQzHtuMZxLJiFdALzxXrEtypwG5q7sj4ADb8UGY4xx3zm/";

 uint256 public price;
 uint256 public maxAmountForAddress;
 uint256 public maxSupply = 10;
 
 bool public paused = false;
 bool public revealed = false;
 bool public whitelistMintEnabled = false;
 
 constructor() ERC721A("AVOTAR", "AVT") {}
 
 // imposta prezzo
 function setPrice (uint256 _price) public onlyOwner {
   price = _price;
 }

 function setMaxAmounthForAddress (uint256 _maxAmountForAddress) public onlyOwner {
   maxAmountForAddress = _maxAmountForAddress;
 }
 
 // un tipo di funzione che controlla prima se la quantità data in input rispetta i limiti imposti
 // questa funzione verà richiamata nelle funzioni di mint
 modifier mintCompliance(uint256 _mintAmount) {
   require(_mintAmount > 0 && _mintAmount <= maxAmountForAddress, "Invalid mint amount!");
   require(totalSupply() + _mintAmount <= maxSupply, "Max supply exceeded!");
   _;
 }
 
 // un tipo di funzione che verifica se i fonfi presenti nel wallet sono suficienti per acquistare la quantità scelta di nft
 // questa funzione verà richiamata nelle funzioni di mint
 modifier mintPriceAVOTAR(uint256 _mintAmount) {
   require(msg.value >= price * _mintAmount, "Insufficient funds!");
   _;
 }
 
 // la funzione permette di mintare solo a chi è nella WL
 function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) mintPriceAVOTAR(_mintAmount) {
   require(!paused, "The contract is paused!");
   require(whitelistMintEnabled, "The whitelist sale is not enabled!");
   require(!whitelisted[_msgSender()], "Address already claimed!");
   bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
   require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof!");
 
   whitelisted[_msgSender()] = true; // il mitente è nella WL 
   _safeMint(_msgSender(), _mintAmount); // viene salvata la quantità del mint
 }
 
 // la funzione è riservata al mint publico
 function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceAVOTAR(_mintAmount) {
   require(!paused, "The contract is paused!");
 
   _safeMint(_msgSender(), _mintAmount);
 }
     
     //ONLY OWNER

 // la funzione è riservata per il mint del proprietario
  function Owner_mint(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
   _safeMint(_receiver, _mintAmount);
 }

 // imposta l'uri dei metadata nascosti
 function _baseURI() internal view override returns (string memory) {
   return baseURI;
 }
 
 // una volta clicato reveal gli nft vengono rivelati e non è possibile nasconderli più
 function reveal(bool _revealed) public onlyOwner {
   revealed = _revealed;
 }

 function changeBaseURI(string memory changeURI) public onlyOwner {
   baseURI = changeURI;
 } 

 function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory changeURI = _baseURI();

        if (revealed) {
          return bytes(changeURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
        }
        else {
          return string(abi.encodePacked(changeURI, ".json"));
        } 
    }
 
 // imposta lo stato del contratto se è in pausa allora paused = true e viceversa
 function setPaused(bool _state) public onlyOwner {
   paused = _state;
 }
 
 // imposta la radice dell'albero di Markle contenente gli hash degli address di collloro che sono nella WL
 function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
   merkleRoot = _merkleRoot;
 }
 
 // imposta lo stato del mint per chi è nella WL abile = true e viceversa
 function setWhitelistMintEnabled(bool _state) public onlyOwner {
   whitelistMintEnabled = _state;
 }


  // tipica funzione di ERC721A che verifica il balance del address dato in output
 // alla variabile ownerTokenCount viene attribuito il valore del balans del address dato in input
 // viene memorizzata la quantità dei token con il loro id presenti nel balanc del address dato in input
 function walletOfOwner(address _owner) public view returns (uint256[] memory) {
   uint256 ownerTokenCount = balanceOf(_owner);
   uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
   uint256 currentTokenId = _startTokenId();
   uint256 ownedTokenIndex = 0;
   address latestOwnerAddress;
   
   // mentre vengono rispettate le condizioni vengono memorizzati i correnti token id
   while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
     TokenOwnership memory ownership = _ownerships[currentTokenId];
     
     // se la proprieta viene bruciata e l'address del proprietario è diverso da 0
     // allora il valore dell'address del proprietario che ha brucciato viene passato alla variabile dell'address più recente del proprietario 
     if (!ownership.burned && ownership.addr != address(0)) {
       latestOwnerAddress = ownership.addr;
     }
 
    // se l'address più recente del proprietari è = all'address del proprietario
    // allora l'id e il suo index viene passato alla variabile currentTokenId
     if (latestOwnerAddress == _owner) {
       ownedTokenIds[ownedTokenIndex] = currentTokenId;
 
       ownedTokenIndex++;
     }
 
     currentTokenId++;
   }
 
   return ownedTokenIds;
 }
 
 // il token id parte da 1 e non da 0
 function _startTokenId() internal view virtual override returns (uint256) {
   return 1;
 }
 
}
