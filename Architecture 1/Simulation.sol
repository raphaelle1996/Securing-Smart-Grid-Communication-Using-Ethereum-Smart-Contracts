pragma solidity ^0.4.17;

contract Simulation {
    address public utility;
    uint public countNodes;

    //request for node
    struct Node {
        string smId;
        string mac;
        address add;
        bool complete;
    }
    Node[] public requestedNodes; //to be added to network by utility

    mapping(address => bool) hasRequested;
    mapping(address => bool) isDeployed;
    mapping(address => bool) hasContract;

    //only the utility can see the information
    modifier restrictedUtility() {
        require(msg.sender == utility);
        _;
    }

    //only called once by utility
    //since deployed by utility
    function Simulation() public {
        utility = msg.sender;
        countNodes = 0;
    }

    //node requests access to network
    //must be accepted by utility
    function requestEntry(string smId, string mac) public {
        //shouldn't be the utility AND shouldn't be a requestor AND shouldn't already be a Node
        require(msg.sender != utility && !hasRequested[msg.sender] && !isDeployed[msg.sender]);

        Node memory r = Node(smId, mac, msg.sender, false);
        requestedNodes.push(r);
        hasRequested[msg.sender] = true;
    }

    //can only add node if the utility accepts
    function acceptNode(uint index) public restrictedUtility {
        //the node requested
        Node storage r = requestedNodes[index];

        //check if this node is valid
        //based on smId db at utility
        //done manually by calling verify function -> comparing values to values they have -> making the call

        //shouldn't already be a Node
        require(r.complete != true);

        //add node to list that needs to create a contract
        isDeployed[r.add] = true;
        countNodes ++;

        //mark as complete in request
        //for ui:
        //when complete true the row is disabled
        r.complete = true;
    }

    //utility can remove a node from network
    function removeNode(uint index) public restrictedUtility {
        //the node requested
        Node storage r = requestedNodes[index];

        //should already be a Node
        require(isDeployed[r.add]);

        countNodes --;
        hasRequested[r.add] = false;
        isDeployed[r.add] = false;
        hasContract[r.add] = false;
    }

    //number of requests
    //for ui
    function getRequestsCount() public view returns (uint) {
        return requestedNodes.length;
    }

    //the next two functions are called one after the other
    //the first is called...
    //if it evaluates to true...
    //the second is called
    //else the second isnt called

    //is node in network but does not have deployed contract
    //evaluates to true when the node is in the network (accepted by the utility)
    //and when the node has not deployed a contract yet
    function canDeploy(address add) public view returns (bool) {
        return isDeployed[add] && !hasContract[add];
    }

    //mark as not able to deploy data contract anymore
    function markDone(address add) public {
        //marking should be done by node not any other node
        require(msg.sender == add);

        hasContract[add] = true;
    }
}