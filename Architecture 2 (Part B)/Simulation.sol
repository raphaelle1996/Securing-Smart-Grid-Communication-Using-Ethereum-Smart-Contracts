pragma solidity ^0.4.17;

contract Simulation {
    uint32 public countNodes;
    string constant public publicKey = "public key";
    address public utility;

    Node[] public requestedNodes; //to be added to network by utility

    mapping(address => bool) private hasRequested;
    mapping(address => bool) public isAccepted;

    //request for node
    struct Node {
        string key;
        uint32 smId;
        address add;
        bool complete;
    }

    //node requests access to network
    //must be accepted by utility
    function requestEntry(uint32 smId, string key) public {
        //shouldn't be a requestor
        //we don't have to check if it isn't already be a Node because once accepted we do not sent hasRequested to false...
        require(!hasRequested[msg.sender]);

        Node memory r = Node(key, smId, msg.sender, false);
        requestedNodes.push(r);
        hasRequested[msg.sender] = true;
    }

    //can only add node if the utility accepts
    function acceptNode(uint32 index) public restrictedUtility {
        //the node requested
        Node storage r = requestedNodes[index];

        //check if this node is valid
        //based on smId db at utility
        //done manually by calling verify function -> comparing values to values they have -> making the call

        //shouldn't already be a Node
        require(!isAccepted[r.add]);

        //add node to list that needs to create a contract
        isAccepted[r.add] = true;
        countNodes ++;

        //mark as complete in request
        //for ui:
        //when complete true the row is disabled
        r.complete = true;
    }

    //utility can remove a node from network
    function x_removeNode(uint32 index) public restrictedUtility {
        //the node requested
        Node storage r = requestedNodes[index];

        //should already be a Node
        require(isAccepted[r.add]);

        countNodes --;
        hasRequested[r.add] = false;
        isAccepted[r.add] = false;
    }

    //number of requests
    //for ui
    function getRequestsCount() public view returns (uint) {
        return requestedNodes.length;
    }

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
}

contract Communication {
    Simulation private S;

    //events
    event DataSent(address indexed _from, bytes32 indexed _timestamp, bytes32 _value);
    event LoadBalancingSent(address indexed _to, bytes32 _value);

    //send the Data
    //timestamp should follow certain convention yyyymdhm
    function sendData(bytes32 timestamp, bytes32 value) public {
        require(S.isAccepted(msg.sender));
        DataSent(msg.sender,timestamp,value);
    }

    //utility
    //send load balancing data
    //will be enumerator 0->decrease 1->increase ....
    function fixData(address to, bytes32 value) public {
        require(msg.sender == S.utility());
        LoadBalancingSent(to, value);
    }

    function Communication(address a) public {
        S = Simulation(a);
    }
}