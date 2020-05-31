pragma solidity ^0.4.17;

contract Factory {
    address[] public deployedDataContracts;
    address public utility;
    uint public numberContracts;

    event Deployed(address indexed _add);

    function Factory() public {
        utility = msg.sender;
    }

    //create the factory contract
    function createDataContract() public returns (address){
        address c = new Data(utility, msg.sender);
        deployedDataContracts.push(c);
        numberContracts++;

        Deployed(c);
        return c;
    }

    //get addresses for all contracts
    function getDeployedDataContracts() public view returns(address[]) {
        return deployedDataContracts;
    }
}