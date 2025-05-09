# Library-Management-Sql-Project
## Project Objective
- Create and work with a relational database structure for a library management system.
- Write SQL queries to manage book issues, returns, overdue tracking, and inventory.
- Identify the most borrowed books and the most active members.
- Track the availability status of books and manage borrow-return records.
- Perform data analysis to generate insights on borrowing trends and member activity.
- Strengthen SQL skills with JOINs, GROUP BY, aggregate functions, subqueries, and date functions.

## Dataset used
- <a href="https://github.com/puvvaditeja/library-management-sql-project/blob/main/library_management_dataset.sql">Dataset</a>

## Database Schema
![Screenshot 2025-05-09 182918](https://github.com/user-attachments/assets/4ef0e255-508b-43e2-a89b-5782f32c26b6)

## Questions
- Find Members Whose Name Starts with 'A' or 'B'
- Find Books Whose Title Contains the Word 'Lord' (case-insensitive)
- Find the most issued book
- List books along with how many times each was issued
- Find members whose registration date is the earliest
- List books issued and returned on the same day
- Find members who have never returned a book
- Retrieve books along with issue and return counts
- List employees whose salary is above branch average
- Get total number of late returns per member
- List Members Who Have Issued More Than One Book
- Find the top 3 most active members based on books issued
- Rank employees by number of books issued
- Find members who borrowed more than 5 books but returned fewer than 3
- Number of days each member took to return each issued book
- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
- Retrieves all the books currently borrowed by a specific member.
- Retrieves a list of members who have borrowed a specific book.
- Issueing a book to a member.
- Prevents the insertion of a new record into issued_status if the book being issued is not currently 'Available' in the books table.

## Project Insights
- Animal Farm book is the most issued book
- 22 members who have never returned a book
- 4 employees whose salary is above branch average
- Ivy Martinez, Jack Wilson are the members who returns the book late everytime
- Alice Johnson is the first member who issued first registration in library
- There is no book which take same day and return on same day
- Michelle Ramirez, Laura Martinez employees who sales more books 

## Conclusion
This project effectively demonstrates how SQL can manage, monitor, and analyze operations in a library management system. By answering common business queries, the project reveals insights like top borrowed books, active members, and overdue patterns. It also enhances skills in database management, relational querying, and data analysis — offering valuable experience for working on real-world data systems.
