// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

interface IERC20Token {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Digitalcard {
    struct Uni3_card {
        uint256 card_id;
    }

    address public usdCaddress = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;
    

    // user contacts
    mapping(address => address[]) public contacts;
    mapping(address => mapping(address => uint32)) public borrowRequests; // borrower -> from -> amount
    mapping(address => mapping(address => bool)) public borrowedFrom; // lender -> borrower -> loan given (true) or not (false)

    event contactAdded(address user, address new_contact);
    event borrowed(address user, address lender, uint32 amount);

    // this is not preventing duplicate contacts currently
    function addContact(address _contact) public {
        contacts[msg.sender].push(_contact);
    }

    function getContact() public view returns (address[] memory) {
        contacts[msg.sender];
    }

    function initiateBorrowRequest(
        address from,
        uint32 _amount
    ) public {
        borrowRequests[msg.sender][from] = _amount;
    }

    function sendERC20Tokens(
        address to,
        uint256 _amount
    ) public payable {
        require(
            borrowRequests[to][msg.sender] > 0,
            "The loan wasn't requested"
        );
        require(
            IERC20Token(usdCaddress).transferFrom(msg.sender, to, _amount),
            "Transaction couldn't be completed"
        );
        borrowedFrom[msg.sender][to] = true; // money sent successfully to the borrow request
    }
    /*
        If borrowRequest for a user is greater than 0, and borrowedFrom for the same user is true,
        that means the money has been sent and now the borrower must repay the debt.
        So we know a borrower needs to repay if ->
        borrowRequests[msg.sender][from] > 0 and borrwedFrom[msg.sender][to] == true -> means the loan is requested and given. Now start repayment process
        borrowRequests[msg.sender][from] > 0 and borrwedFrom[msg.sender][to] == false -> means the loan is requested but is still pending to be given

        Without requesting a loan, a person cannot send money to anyone.
    */

    // Next comes the repayment functions.
}

// contract Lock {
//     uint256 public unlockTime;
//     address payable public owner;

//     event Withdrawal(uint256 amount, uint256 when);

//     constructor(uint256 _unlockTime) payable {
//         require(
//             block.timestamp < _unlockTime,
//             "Unlock time should be in the future"
//         );

//         unlockTime = _unlockTime;
//         owner = payable(msg.sender);
//     }

//     function withdraw() public {
//         // Uncomment this line to print a log in your terminal
//         // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

//         require(block.timestamp >= unlockTime, "You can't withdraw yet");
//         require(msg.sender == owner, "You aren't the owner");

//         emit Withdrawal(address(this).balance, block.timestamp);

//         owner.transfer(address(this).balance);
//     }
// }
