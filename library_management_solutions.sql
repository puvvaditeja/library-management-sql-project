-- 1.Find Members Whose Name Starts with 'A' or 'B'
SELECT member_id, member_name
FROM members
WHERE member_name REGEXP '^(A|B)';

-- 2.Find Books Whose Title Contains the Word 'Lord' (case-insensitive)
SELECT isbn, book_title
FROM books
WHERE book_title REGEXP '[Ll][Oo][Rr][Dd]';

-- 3.Find the most issued book
SELECT 
	issued_book_name, COUNT(*) AS issue_count
FROM 
	issued_status
GROUP BY issued_book_name
ORDER BY issue_count DESC
LIMIT 1;

-- 4.List books along with how many times each was issued
SELECT 
	b.book_title, COUNT(i.issued_id) AS total_issues
FROM 
	books b
LEFT JOIN issued_status i 
ON b.isbn = i.issued_book_isbn
GROUP BY b.book_title;

-- 5.Find members whose registration date is the earliest
SELECT 
	*
FROM 
	members
WHERE reg_date = 
(
	SELECT 
		MIN(reg_date) 
	FROM 
		members);
        
-- 6.List books issued and returned on the same day
SELECT 
	i.issued_book_name, m.member_name
FROM 
	issued_status i
JOIN return_status r 
	ON i.issued_id = r.issued_id
JOIN members m 
	ON i.issued_member_id = m.member_id
WHERE i.issued_date = r.return_date;

-- 7.Find members who have never returned a book
SELECT 
	m.member_name
FROM 
	members m
LEFT JOIN issued_status i 
	ON m.member_id = i.issued_member_id
LEFT JOIN return_status r 
	ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;

-- 8.Retrieve books along with issue and return counts
SELECT b.book_title,
       (SELECT 
			COUNT(*) 
		FROM 
			issued_status i 
		WHERE i.issued_book_isbn = b.isbn) AS issues,
       (SELECT 
			COUNT(*) 
		FROM 
			return_status r 
		WHERE r.return_book_isbn = b.isbn) AS returns
FROM books b;

-- 9.List employees whose salary is above branch average
SELECT 
	e.emp_name, e.salary, e.branch_id
FROM 
	employees e
JOIN (
  SELECT 
	branch_id, AVG(salary) AS avg_salary
  FROM 
	employees
  GROUP BY branch_id
) 
AS branch_avg 
ON e.branch_id = branch_avg.branch_id
WHERE e.salary > branch_avg.avg_salary;

-- 10.Get total number of late returns per member
SELECT 
	m.member_name, COUNT(r.return_id) AS late_returns
FROM 
	members m
JOIN issued_status i 
	ON m.member_id = i.issued_member_id
JOIN return_status r 
	ON i.issued_id = r.issued_id
WHERE DATEDIFF(r.return_date, i.issued_date) > 14
GROUP BY m.member_name;

-- 11.List Members Who Have Issued More Than One Book
SELECT 
    ist.issued_emp_id,e.emp_name
FROM 
	issued_status AS ist
JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
GROUP BY ist.issued_emp_id, e.emp_name
HAVING COUNT(ist.issued_id) > 1;

-- 12.Find the top 3 most active members based on books issued
SELECT 
	member_name, COUNT(i.issued_id) AS total_issues
FROM 
	members m
JOIN 
	issued_status i 
ON m.member_id = i.issued_member_id
GROUP BY member_name
ORDER BY total_issues DESC
LIMIT 3;

-- 13.Rank employees by number of books issued
SELECT 
	emp_name, COUNT(i.issued_id) AS total_issues,RANK() OVER (ORDER BY COUNT(i.issued_id) DESC) AS issue_rank
FROM 
	employees e
LEFT JOIN issued_status i 
ON e.emp_id = i.issued_emp_id
GROUP BY e.emp_name;

-- 14.Find members who borrowed more than 5 books but returned fewer than 3
SELECT 
	m.member_name,COUNT(DISTINCT i.issued_id) AS total_issued,COUNT(DISTINCT r.return_id) AS total_returned
FROM 
	members m
LEFT JOIN issued_status i 
ON m.member_id = i.issued_member_id
LEFT JOIN return_status r 
ON i.issued_id = r.issued_id
GROUP BY m.member_name
HAVING total_issued > 5 AND total_returned < 3;

-- 15.Number of days each member took to return each issued book
SELECT 
	member_name,DATEDIFF(r.return_date, i.issued_date) AS avg_return_days
FROM 
	members m
JOIN issued_status i 
ON m.member_id=i.issued_member_id
JOIN return_status r 
ON i.issued_id = r.issued_id;

-- 16.Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN 
employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN
branch AS b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN 
books AS bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id,b.manager_id;

SELECT * FROM branch_reports;

-- 17. Retrieves all the books currently borrowed by a specific member.
DELIMITER //
CREATE PROCEDURE GetMemberBorrowedBooks(IN member_id_param VARCHAR(30))
BEGIN
    SELECT
        b.isbn,
        b.book_title,
        isd.issued_date,
        rs.return_date
    FROM
		return_status rs 
	JOIN 
        issued_status isd ON rs.issued_id=isd.issued_id
    JOIN
        books b ON isd.issued_book_isbn = b.isbn
    WHERE
        isd.issued_member_id = member_id_param;
END //
DELIMITER ;
drop procedure GetMemberBorrowedBooks;

CALL GetMemberBorrowedBooks('C106');

-- 18.Retrieves a list of members who have borrowed a specific book.
DELIMITER //
CREATE PROCEDURE GetBookBorrowers(IN isbn_param VARCHAR(50))
BEGIN
    SELECT
        m.member_id,
        m.member_name,
        isd.issued_date,
        rs.return_date
    FROM
		return_status rs
	JOIN
        issued_status isd ON rs.issued_id=isd.issued_id
    JOIN
        members m ON isd.issued_member_id = m.member_id
    WHERE
        isd.issued_book_isbn = isbn_param ;
END //
DELIMITER ;
drop procedure GetBookBorrowers;

CALL GetBookBorrowers('978-0-14-118776-1');

-- 19.Issueing a book to a member.
DELIMITER //
CREATE PROCEDURE IssueBook(
    IN member_id_param INT,
    IN isbn_param VARCHAR(50),
    IN emp_id_param INT,
    IN issue_date_param DATE
)
BEGIN
    DECLARE book_status VARCHAR(20);

    SELECT status INTO book_status
    FROM books
    WHERE isbn = isbn_param;

    IF book_status = 'Available' THEN
        INSERT INTO issued_status (issued_member_id, issued_book_isbn, issued_book_name, issued_date, emp_id)
        SELECT member_id_param, isbn_param, book_title, issue_date_param, emp_id_param
        FROM books
        WHERE isbn = isbn_param;

        UPDATE books
        SET status = 'Issued'
        WHERE isbn = isbn_param;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book is not available for issuing.';
    END IF;
END //
DELIMITER ;

CALL IssueBook(101, '978-0321765723', 201, '2024-01-20');

-- 20.Prevents the insertion of a new record into issued_status if the book being issued is not currently 'Available' in the books table.
DELIMITER //
CREATE TRIGGER PreventIssuingUnavailableBook
BEFORE INSERT ON issued_status
FOR EACH ROW
BEGIN
    DECLARE book_current_status VARCHAR(20);
    SELECT status INTO book_current_status
    FROM books
    WHERE isbn = NEW.issued_book_isbn;

    IF book_current_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot issue a book that is not currently available.';
    END IF;
END //
DELIMITER ;
drop trigger PreventIssuingUnavailableBook;

INSERT INTO employees (emp_id, emp_name, position, salary, branch_id) VALUES (201, 'Employee Name', 'Librarian', 30000.00, 'BR001'); 
INSERT INTO members (member_id, member_name, member_address, reg_date) VALUES (101, 'Member Name', 'Member Address', '2024-01-01'); 
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher) VALUES ('978-0321765723', 'The Lord of the Rings', 'Fantasy', 5.99, 'Available', 'J.R.R. Tolkien', 'Allen & Unwin'); 
INSERT INTO issued_status (issued_id,issued_member_id, issued_book_isbn, issued_book_name, issued_date,issued_emp_id) VALUES ('IS141' ,101, '978-0321765723', 'The Lord of the Rings', '2024-02-01', 201);


