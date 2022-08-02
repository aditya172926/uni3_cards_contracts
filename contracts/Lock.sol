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
    address constant treasury_address = 0xd4C88BDeE3a708d6A13A7aFE3B5f93f1DA5375D8;

    struct borrowRequest {
        address lender;
        uint8 decimalPlaces;
        uint8 repayments;
        uint16 amount;
        string token;
        bool gotLoan;
    }
    
    mapping(address => borrowRequest) borrowerRequests; // borrower -> amount
    mapping(address => address[]) lendersRequested; // lender -> borrowers array

    // user contacts

    event borrowRequested(address indexed lender, address indexed borrower, uint32 amount);
    event moneyLent(address indexed lender, address borrower, uint32 amount, string token);
    event tokensRepay(address indexed from, address indexed to, uint32 borrowed_amount, uint32 amount_paid, uint8 installments);

    // ask for borrowing money
    function initiateBorrowRequest(
        address from,
        uint16 _amount,
        string memory tokentype,
        uint8 _decimals
    ) public {
        lendersRequested[from].push(msg.sender);

        borrowerRequests[msg.sender] = borrowRequest(
            from,
            _decimals,
            3,
            _amount,
            tokentype,
            false
        );
        emit borrowRequested(from, msg.sender, _amount);
    }

    function getBorrowerRequests(address _borrower) public view returns (address, uint8, uint16, string memory, uint8, bool) {
        return (borrowerRequests[_borrower].lender, 
        borrowerRequests[_borrower].decimalPlaces, 
        borrowerRequests[_borrower].amount, 
        borrowerRequests[_borrower].token, 
        borrowerRequests[_borrower].repayments,
        borrowerRequests[_borrower].gotLoan);
    }

    function getBorrowers() public view returns (address[] memory) {
        // a lender can view who has requested for loan
        return lendersRequested[msg.sender];
    }

    function _burn(uint index) internal {
        require (index < lendersRequested[msg.sender].length, "Index out of range");
        lendersRequested[msg.sender][index] = lendersRequested[msg.sender][lendersRequested[msg.sender].length - 1];
        lendersRequested[msg.sender].pop();
    }

    // approve borrow request and send tokens
    function lendTokens(
        address _borrower,
        string memory tokentype,
        uint16 amount,
        uint _index
    ) public payable {
            require(
                IERC20Token(usdCaddress).transferFrom(msg.sender, _borrower, amount),
                "Transaction couldn't be completed"
            );
        borrowerRequests[_borrower].gotLoan = true;
            emit moneyLent(msg.sender, _borrower, borrowerRequests[_borrower].amount, "USDc");
            _burn(_index);
    }

    function repay(address to, uint16 _amount, uint16 interest_payment, uint16 treasury_amount) public payable {
        // this is for ERC20 tokens like usdc
        if (borrowerRequests[msg.sender].repayments == 1) {
            require(_amount == borrowerRequests[msg.sender].amount, 
            "This is your final installment for this loan. Please pay the rest of the amount");
        }
        require(
            IERC20Token(usdCaddress).transferFrom(msg.sender, to, (_amount + interest_payment)),
            "Transfer failed"
        );
        require (
            IERC20Token(usdCaddress).transferFrom(msg.sender, treasury_address, treasury_amount),
            "Transfer failed"
        );
        // partial repayment

        if (_amount < borrowerRequests[msg.sender].amount) {
            borrowerRequests[msg.sender].amount -= _amount;
            borrowerRequests[msg.sender].repayments--;
        }
        // repay the whole
        if (_amount == borrowerRequests[msg.sender].amount) {
            borrowerRequests[msg.sender].amount -= _amount;
            borrowerRequests[msg.sender].repayments = 0;
            borrowerRequests[msg.sender].gotLoan = false;
        }

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