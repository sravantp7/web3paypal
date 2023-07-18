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

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Error: Invalid Owner");
        _;
    }

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
    }
}