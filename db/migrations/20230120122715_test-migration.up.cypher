CREATE CONSTRAINT constraint_book_isbn IF NOT EXISTS
FOR (book:Book) REQUIRE book.isbn IS UNIQUE;