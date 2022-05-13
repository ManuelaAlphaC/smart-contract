pragma solidity 0.7.5;
pragma abicoder v2;

import "./avoOwnable.sol";

contract MultisigWallet is avoOwnable{
    address[]public owners;
    uint limit; // quante firme

    struct Transfer{
        uint amount; // quantità che si vuole trasferire
        address payable receiver; // chi riceverà il trasferimento
        uint approvals;
        bool hasBeenSent;
        uint id;
    }

    event TransferRequestCreate(uint _id, uint _amunt, address _from, address _receiver);
    event ApprovalReseived(uint _id, uint _approvals, address _approver);
    event TransferApproved(uint _id);

    Transfer[] transferRequest;
   
   // mapping[address][transferId] = bool
   // mapping[msg.sender][5] = true;
    mapping(address => mapping(uint => bool)) approvals;

    modifier onlyOwners(){
        bool owner = false;
        for (uint i=0; i < owners.length; i++){
            if(owners[i] == msg.sender){
                owner = true;
            }
        }
        require(owner = true); // se è stato verificato che il mitente fa marte dell'array dei proprietari 
        // allora la funzione può essere eseguita
        _;
        
    }

    constructor(address[] memory _owners, uint _limit){
        owners = _owners;
        limit = _limit; // la richiesta di firme da parte dei proprietari
    }

    function deposit() public payable {}

    function createTransfer(uint _amount, address payable _receiver) public onlyOwners{
        emit TransferRequestCreate(transferRequest.length, _amount, msg.sender, _receiver);
        transferRequest.push(
             Transfer(_amount, _receiver, 0, false, transferRequest.length)
        );     
    }

    function approve(uint _id) public onlyOwners {
        require(approvals[msg.sender][_id] == false);
        require(transferRequest[_id].hasBeenSent == false);

        approvals[msg.sender][_id] = true;
        transferRequest[_id].approvals++;

        emit ApprovalReseived(_id, transferRequest[_id].approvals, msg.sender);

        if(transferRequest[_id].approvals >= limit){
            transferRequest[_id].hasBeenSent = true;
            transferRequest[_id].receiver.transfer(transferRequest[_id].amount);
            emit TransferApproved(_id);
        }
    }

    function getTransferRequests() public view returns (Transfer[] memory) {
        return transferRequest;
    }
}
