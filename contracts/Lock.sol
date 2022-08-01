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

    bool[3] repayments = [false, false, false];

    address public usdCaddress = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F; // for goreli testnet

    struct borrowRequest {
        uint16 amount;
        string token;
    }
    
    mapping(address => borrowRequest) borrowerRequests; // borrower -> amount
    mapping(address => address[]) lendersRequested; // lender -> borrowers array

    // user contacts

    event borrowRequested(address indexed lender, address indexed borrower, uint32 amount);
    event moneyLent(address indexed lender, address borrower, uint32 amount, string token);

    // ask for borrowing money
    function initiateBorrowRequest(
        address from,
        uint16 _amount,
        string memory tokentype
    ) public {
        lendersRequested[from].push(msg.sender);

        borrowerRequests[msg.sender] = borrowRequest(
            _amount,
            tokentype
        );
        emit borrowRequested(from, msg.sender, _amount);
    }

    function getBorrowerRequests(address _borrower) public view returns (uint16, string memory) {
        return (borrowerRequests[_borrower].amount, borrowerRequests[_borrower].token);
    }

    function getBorrowers() public view returns (address[] memory) {
        // a lender can view who has requested for loan
        return lendersRequested[msg.sender];
    }

    // approve borrow request and send tokens
    function lendTokens(
        address _borrower,
        string memory tokentype
    ) public payable {
            require(
                IERC20Token(usdCaddress).transferFrom(msg.sender, _borrower, borrowerRequests[_borrower].amount),
                "Transaction couldn't be completed"
            );
            emit moneyLent(msg.sender, _borrower, borrowerRequests[_borrower].amount, "USDc");
    }

    function sendETHToken(address _borrower) public payable {
        emit moneyLent(msg.sender, _borrower, borrowerRequests[_borrower].amount, "ETH");
    }
    /*
        If borrowRequest for a user is greater than 0, and borrowedFrom for the same user is true,
        that means the money has been sent and now the borrower must repay the debt.
        So we know a borrower needs to repay if ->

        Without requesting a loan, a person cannot send money to anyone.
    */

    // Next comes the repayment functions.

    // function payBack() public {

    // }
}