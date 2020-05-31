pragma solidity ^0.4.17;

contract Data {
    address public owner;
    address public utility;
    uint public entries;
    uint public loadBalancing;
    mapping(string => uint) electricity;


    //only the utility can see the information
    modifier restrictedUtility() {
        require(msg.sender == utility);
        _;
    }

    //only the owner can see the information
    modifier restrictedOwner() {
        require(msg.sender == owner);
        _;
    }

    function Data(address utilityAdd, address creator) public {
        owner = creator;
        utility = utilityAdd;
        loadBalancing = 0;
    }

    //send the Data
    //timestamp should follow certain convention yyyymdhm
    function sendData(string timestamp, uint value) public restrictedOwner {
        electricity[timestamp] = value;
        entries++;
    }

    //check this data
    function lookupData(string timestamp) view returns (uint) {
        return electricity[timestamp];
    }

    //utility
    //send load balancing data
    //will be enumerator 0->decrease 1->increase ....
    function fixData(uint value) public restrictedUtility {
        loadBalancing = value;
    }
}