// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BookRental is Ownable, Pausable, ReentrancyGuard {
    struct Book {
        string title;
        address owner;
        uint96 deposit;
        uint96 rentFee;
        bool listed;
    }

    struct Rental {
        address renter;
        uint64 dueDate;
        bool returned;
    }

    constructor() Ownable(msg.sender) {}

    uint256 public rentalDuration = 7 days;
    uint256 public latePenaltyPerDay = 0.001 ether;
    uint256 public maxLateDays = 30;

    uint256 public bookCount;

    mapping(uint256 => Book) public books;
    mapping(uint256 => Rental) public rentals;
    mapping(address => uint256) public pendingWithdrawals;

    /* -------------------- EVENTS -------------------- */
    event BookListed(uint indexed bookId, string title);
    event BookUnlisted(uint indexed bookId);
    event BookUpdated(uint indexed bookId, uint96 newRentFee, uint96 newDeposit);
    event BookRented(uint indexed bookId, address indexed renter, uint dueDate);
    event BookReturned(uint indexed bookId, address indexed renter, uint penalty);
    event Withdrawal(address indexed user, uint amount);

    /* -------------------- MODIFIERS -------------------- */
    modifier validBook(uint bookId) {
        require(bookId < bookCount, "Invalid book ID");
        _;
    }

    modifier onlyBookOwner(uint bookId) {
        require(books[bookId].owner == msg.sender, "Not book owner");
        _;
    }

    /* -------------------- CORE FUNCTIONS -------------------- */

    function listBook(
        string calldata title,
        uint96 rentFee,
        uint96 deposit
    ) external whenNotPaused {
        books[bookCount] = Book(title, msg.sender, deposit, rentFee, true);
        emit BookListed(bookCount, title);
        bookCount++;
    }

    function rentBook(
        uint bookId
    ) external payable whenNotPaused nonReentrant validBook(bookId) {
        Book storage book = books[bookId];
        require(book.listed, "Book not available");
        require(msg.value == book.deposit + book.rentFee, "Incorrect payment");

        rentals[bookId] = Rental(
            msg.sender,
            uint64(block.timestamp + rentalDuration),
            false
        );

        book.listed = false;
        pendingWithdrawals[book.owner] += book.rentFee;

        emit BookRented(bookId, msg.sender, block.timestamp + rentalDuration);
    }

    function returnBook(
        uint bookId
    ) external nonReentrant validBook(bookId) {
        Rental storage rental = rentals[bookId];
        Book storage book = books[bookId];

        require(rental.renter == msg.sender, "Not renter");
        require(!rental.returned, "Already returned");

        rental.returned = true;
        book.listed = true;

        uint penalty = _calculatePenalty(bookId);
        uint refund = book.deposit - penalty;

        // ✅ FIX #1: Proper deposit & penalty accounting
        pendingWithdrawals[msg.sender] += refund;
        pendingWithdrawals[book.owner] += penalty;

        // ✅ FIX #2: Clear rental state
        delete rentals[bookId];

        emit BookReturned(bookId, msg.sender, penalty);
    }

    function withdraw() external nonReentrant {
        uint amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    /* -------------------- OWNER / BOOK OWNER ACTIONS -------------------- */

    function unlistBook(
        uint bookId
    ) external validBook(bookId) onlyBookOwner(bookId) {
        books[bookId].listed = false;
        emit BookUnlisted(bookId);
    }

    function updateBook(
        uint bookId,
        uint96 newRentFee,
        uint96 newDeposit
    ) external validBook(bookId) onlyBookOwner(bookId) {
        books[bookId].rentFee = newRentFee;
        books[bookId].deposit = newDeposit;
        emit BookUpdated(bookId, newRentFee, newDeposit);
    }

    /* -------------------- INTERNAL -------------------- */

    function _calculatePenalty(uint bookId) internal view returns (uint) {
        Rental memory rental = rentals[bookId];
        if (block.timestamp <= rental.dueDate) return 0;

        uint lateDays = (block.timestamp - rental.dueDate) / 1 days;
        if (lateDays > maxLateDays) lateDays = maxLateDays;

        return lateDays * latePenaltyPerDay;
    }

    /* -------------------- ADMIN -------------------- */

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
