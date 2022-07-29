// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

contract Digitalcard {
    struct Uni3_card {
        uint256 card_id;
    }
    
    // user contacts
    mapping (address => address[]) public contacts;
    mapping (address => mapping(address => uint32)) public borrowedFrom;

    event contactAdded(address user, address new_contact);
    event borrowed(address user, address lender, uint32 amount);

    // this is not preventing duplicate contacts currently
    function addContact(address _contact) public {
        contacts[msg.sender].push(_contact);
    }
    function getContact() public view returns (address[]) {
        contacts[msg.sender];
    }


}

contract Lock {
    uint public unlockTime;
    address payable public owner;

    event Withdrawal(uint amount, uint when);

    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    function withdraw() public {
        // Uncomment this line to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }
}
