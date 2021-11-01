pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Owner.sol";

contract BookLibrary is Owner {
    struct Book {
        string name;
        uint copies;
        uint borrowedCopies;
    }
    
    struct Borrow {
        uint bookId;
        uint borrowDate;
        address userAdddress;
    }
    
    mapping (string => bool) bookExists;
    mapping (uint => Borrow[]) bookBorrows;
    mapping (string => bool) userBorrowABook;
    mapping (string => uint) bookNameToId;
    
    Book[] public books;
    
    function addNewBook(string memory _name, uint _copies) public isOwner {
        require(!bookExists[_name], "This book already exists");
        
        books.push(Book(_name, _copies, 0));
        uint id  = books.length - 1;
        bookExists[_name] = true;
        bookNameToId[_name] = id;
    }
    
    function listAvailableBooks() public view returns(Book[] memory) {
        return books;
    }
    
    function borrowBook(uint _bookId) public {
        Book storage book = books[_bookId];
        string memory borrowUID = string(abi.encodePacked(msg.sender, _bookId));
        require(book.borrowedCopies < book.copies, "No available copies of this book");
        require(userBorrowABook[borrowUID] == false, "User already borrow this book");
        
        Borrow memory borrow = Borrow(_bookId, block.timestamp, msg.sender);
        bookBorrows[_bookId].push(borrow);
        userBorrowABook[borrowUID] = true;
        books[_bookId].borrowedCopies++;
    }
    
    function returnBook(uint _bookId) public {
        string memory borrowUID = string(abi.encodePacked(msg.sender, _bookId));
        
        books[_bookId].borrowedCopies--;
        userBorrowABook[borrowUID] = false;
    }
    
    function bookBorrowsHistory(uint _bookId) public view returns(Borrow[] memory) {
        return bookBorrows[_bookId];
    }
}
