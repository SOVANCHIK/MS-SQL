CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

ALTER DATABASE LibraryDB ADD FILEGROUP ActiveGroup; 
ALTER DATABASE LibraryDB ADD FILEGROUP ArchiveGroup; 
GO

ALTER DATABASE LibraryDB 
ADD FILE (
    NAME = ActiveDataFile,
    FILENAME = 'C:\SQLData\ActiveDataFile.ndf', 
    SIZE = 5MB
) TO FILEGROUP ActiveGroup;

ALTER DATABASE LibraryDB 
ADD FILE (
    NAME = ArchiveDataFile,
    FILENAME = 'C:\SQLData\ArchiveDataFile.ndf', 
    SIZE = 5MB
) TO FILEGROUP ArchiveGroup;
GO

CREATE TABLE Authors
(
    AuthorID int IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    BirthDate DATE NULL,
    Country NVARCHAR(100) NULL
) ON ArchiveGroup;
GO

CREATE TABLE Publishers
(
    PublisherID int IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    City NVARCHAR(100) NULL,
    Website NVARCHAR(255) NULL
) ON ArchiveGroup;
GO

CREATE TABLE Genres
(
    GenreID int IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
) ON ArchiveGroup;
GO

CREATE TABLE Books
(
    BookID int IDENTITY(1,1) PRIMARY KEY,
    PublisherID int NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    ISBN NVARCHAR(20) NOT NULL UNIQUE,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PageCount int NULL,
    PublishYear int NOT NULL,

    CONSTRAINT FK_Books_Publishers
        FOREIGN KEY (PublisherID)
        REFERENCES Publishers(PublisherID),

    CONSTRAINT CK_Books_Price
        CHECK (Price >= 0)
) ON ActiveGroup;
GO

CREATE TABLE BookAuthors
(
    BookID int NOT NULL,
    AuthorID int NOT NULL,

    CONSTRAINT PK_BookAuthors PRIMARY KEY (BookID, AuthorID),
    
    CONSTRAINT FK_BookAuthors_Books FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT FK_BookAuthors_Authors FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
) ON ActiveGroup;
GO

CREATE TABLE BookGenres
(
    BookID int NOT NULL,
    GenreID int NOT NULL,

    CONSTRAINT PK_BookGenres PRIMARY KEY (BookID, GenreID),
    
    CONSTRAINT FK_BookGenres_Books FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT FK_BookGenres_Genres FOREIGN KEY (GenreID) REFERENCES Genres(GenreID)
) ON ActiveGroup;
GO

CREATE TABLE Readers
(
    ReaderID int IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    RegistrationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
) ON ActiveGroup;
GO

CREATE TABLE Sales
(
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ReaderID int NOT NULL,
    BookID int NOT NULL,
    SaleDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Quantity int NOT NULL DEFAULT 1,
    TotalAmount DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Sales_Readers FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    CONSTRAINT FK_Sales_Books FOREIGN KEY (BookID) REFERENCES Books(BookID),
    
    CONSTRAINT CK_Sales_Quantity CHECK (Quantity > 0)
) ON ActiveGroup;
GO

CREATE NONCLUSTERED INDEX IX_Books_Title 
ON Books(Title);
GO

CREATE NONCLUSTERED INDEX IX_Books_Expensive 
ON Books(Price) 
WHERE Price > 1000;
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Sales_Columnstore 
ON Sales (BookID, ReaderID, TotalAmount, SaleDate);
GO

INSERT INTO Authors (FirstName, LastName, BirthDate, Country)
VALUES (N'Лев', N'Толстой', '1828-09-09', N'Россия');

INSERT INTO Publishers (Name, City, Website)
VALUES (N'Эксмо', N'Москва', N'https://eksmo.ru');

INSERT INTO Genres (Name)
VALUES (N'Классика');

INSERT INTO Books (PublisherID, Title, ISBN, Price, PageCount, PublishYear)
VALUES (1, N'Война и мир', N'978-5-04-116000-0', 1500.00, 1300, 1869);

INSERT INTO BookAuthors (BookID, AuthorID)
VALUES (1, 1);

INSERT INTO BookGenres (BookID, GenreID)
VALUES (1, 1);

INSERT INTO Readers (FullName, Email)
VALUES (N'Иван Иванов', N'ivan@mail.com');

INSERT INTO Sales (ReaderID, BookID, Quantity, TotalAmount)
VALUES (1, 1, 1, 1500.00);
GO

SELECT * FROM Books;
SELECT * FROM Sales;