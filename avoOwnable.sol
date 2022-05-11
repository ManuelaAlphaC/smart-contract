contract avoOwnable {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner, "You aren't the owner of the contract!");
        _; // esegui la funzione
    }

    constructor() {
        owner = msg.sender;
    }
}
