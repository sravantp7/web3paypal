// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Paypal {
    address public owner;

    struct request {
        address requestor;
        uint256 amount;
        string message;
        string name;
    }

    struct sendReceive {
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct userName {
        string name;
        bool hasName;
    }

    mapping(address => userName) names;
    mapping(address => request[]) requests;
    mapping(address => sendReceive[]) history;

    event UserNameAdded(address indexed user, string indexed name);

    constructor() {
        owner = msg.sender; // set the owner of the contract
    }

    // modifier used to check whether the caller is owner or not
    modifier onlyOwner() {
        require(msg.sender == owner, "Error: Invalid Owner");
        _;
    }

    // function that allow owner of the contract to revoke the his ownership
    function revokeOwnerShip() external onlyOwner {
        owner = address(0);
    }

    /**
     * @dev This function allow user to set a name to their address
     * @param _name Name of the user
     */
    function addName(string memory _name) external {
        names[msg.sender] = userName({
            name: _name,
            hasName: true
        });
        emit UserNameAdded(msg.sender, _name);
    }

    /**
     * @dev This function allow people to create a request to some other account for getting eth
     * @param _user Address of the user who will receive this request (target address)
     * @param _amount Amount of eth requested
     * @param _message Message that appended with the request
     */
    function createRequest(address _user, uint256 _amount, string memory _message) external {
        request memory newRequest;
        newRequest.requestor = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        if (names[msg.sender].hasName) {
            newRequest.name = names[msg.sender].name;
        }
        requests[_user].push(newRequest);
    }

    /**
     * @dev allow user to pay the requests
     * @param _request index of the request that want to pay
     */
    function payRequest(uint256 _request) external payable {
        require(_request < requests[msg.sender].length, "Invalid Request");
        request[] storage myRequets = requests[msg.sender]; // loading the request array of the msg.sender to storage
        request memory payableRequest = myRequets[_request];

        myRequets[_request] = myRequets[myRequets.length - 1]; // assigning last request to _request position
        myRequets.pop(); // deleting the last request since it is copied to _request location.

        require(msg.value >= payableRequest.amount, "Insufficient Amount");
        (bool success, ) = payable(payableRequest.requestor).call{value: payableRequest.amount}("");
        require(success, "Transfer Failed");

        addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);
    }

    /**
     * @dev this function add the request details to history array for the sender
     * @param _sender address of the person who pay the request
     * @param _receiver person who requested for fund in the first place
     * @param _amount requested amount
     * @param _message message associated with the request
     */
    function addHistory(address _sender, address _receiver, uint256 _amount, string memory _message) private {
        // adds history for the sender
        sendReceive memory newSend;
        newSend.action = "-"; // - indicates paying
        newSend.amount = _amount;
        newSend.message = _message;
        newSend.otherPartyAddress = _receiver;
        if (names[_receiver].hasName) {
            newSend.otherPartyName = names[_receiver].name;
        }
        
        // pushing new history to history array of the sender
        history[_sender].push(newSend);

        // adds history for receiver
        sendReceive memory newReceive;
        newReceive.action = "+"; // + means receiving fund
        newReceive.amount = _amount;
        newReceive.message = _message;
        newReceive.otherPartyAddress = _sender;
        if (names[_sender].hasName) {
            newReceive.otherPartyName = names[_sender].name;
        }

        // adding history for the receiver
        history[_receiver].push(newReceive);
    }

    function getMyRequests(address _user) external view returns (address[] memory, uint256[] memory, string[] memory, string[] memory) {
        // creating temp arrays of size requests[_user].length
        address[] memory addr = new address[](requests[_user].length);
        uint256[] memory amt = new uint256[](requests[_user].length);
        string[] memory message = new string[](requests[_user].length);
        string[] memory name = new string[](requests[_user].length);

        for (uint256 i = 0; i < requests[_user].length; i++) {
            request memory myRequest = requests[_user][i];
            addr[i] = myRequest.requestor;
            amt[i] = myRequest.amount;
            message[i] = myRequest.message;
            name[i] = myRequest.name;
        }

        return (addr, amt, message, name);
    }

    // function used to get all the requests send to the provided address
    function getHistory(address _user) external view returns (sendReceive[] memory) {
        return history[_user];
    }

    // function return the name of the _user address
    function getMyName(address _user) external view returns (userName memory) {
        return names[_user];
    }
}