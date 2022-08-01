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

    address public usdCaddress = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F; // for goreli testnet
    

    // user contacts
    mapping(address => address[]) public contacts;
    mapping(address => mapping(address => uint32)) public borrowRequests; // borrower -> from -> amount
    mapping(address => mapping(address => bool)) public borrowedFrom; // lender -> borrower -> loan given (true) or not (false)

    event contactAdded(address user, address new_contact);
    event borrowRequested(address indexed lender, address indexed borrwoer, uint32 amount);
    event borrowed(address indexed lender, address borrower, uint32 amount);

    // this is not preventing duplicate contacts currently
    function addContact(address _contact) public {
        contacts[msg.sender].push(_contact);
    }

    function getContact() public view returns (address[] memory) {
        contacts[msg.sender];
    }

    // ask for borrowing money
    function initiateBorrowRequest(
        address from,
        uint32 _amount
    ) public {
        borrowRequests[msg.sender][from] = _amount;
        emit borrowRequested(from, msg.sender, _amount);
    }

    // approve borrow request and send tokens
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

    // function payBack() public {

    // }
}