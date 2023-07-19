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
    }
}