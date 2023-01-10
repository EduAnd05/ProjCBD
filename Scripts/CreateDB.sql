/********************************************
 *	UC: Complementos de Bases de Dados 2022/2023
 *
 *		Projeto de Época Normal 
 *		Miguel Pintado (202002226)
 *		Eduardo Andrade (202000906)
 *		Turma: 2ºL_EI-SW-05 - sala F157 (16:30h - 18:30h)
 *	
 ********************************************/

-- Script de criação da nova base de dados

use WWI_DS;
drop database if exists WWI_Global;
create database WWI_Global;
use WWI_Global;

CREATE TABLE City
(
  CityID INT IDENTITY(1, 1) NOT NULL,
  Name NVARCHAR(100) NOT NULL,
  LatestRecordedPopulation INT NOT NULL,
  PRIMARY KEY (CityID)
);

CREATE TABLE Product
(
  ProductID INT NOT NULL,
  UnitPrice DECIMAL(18, 2) NOT NULL,
  Color NVARCHAR(20) NOT NULL,
  SellingPackage NVARCHAR(50) NOT NULL,
  BuyingPackage NVARCHAR(50) NOT NULL,
  Brand NVARCHAR(20) NOT NULL,
  Size NVARCHAR(20) NOT NULL,
  QuantityPerOuter INT NOT NULL,
  IsChillerStock BIT NOT NULL,
  Product NVARCHAR(100) NOT NULL,
  LeadTimeDays INT NOT NULL,
  Barcode NVARCHAR(50) NOT NULL,
  TaxRate DECIMAL(18, 3) NOT NULL,
  RecommendedRetailPrice DECIMAL(18, 2) NOT NULL,
  TypicalWeightPerUnit DECIMAL(18, 3) NOT NULL,
  PRIMARY KEY (ProductID)
);

CREATE TABLE Discount
(
  DiscountID INT NOT NULL,
  Percentage DECIMAL(18, 2) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE NOT NULL,
  ProductID INT NOT NULL,
  PRIMARY KEY (DiscountID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE Account
(
  AccountID INT NOT NULL,
  Username NVARCHAR(50) NOT NULL,
  Password NVARCHAR(50) NOT NULL,
  PRIMARY KEY (AccountID)
);

CREATE TABLE PasswordRecovery
(
  PasswordRecoveryID INT NOT NULL,
  Token VARCHAR(50) NOT NULL,
  IssuedAt DATE NOT NULL,
  AccountID INT NOT NULL,
  PRIMARY KEY (PasswordRecoveryID),
  FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

CREATE TABLE Category
(
  CategoryID INT NOT NULL,
  Name NVARCHAR(50) NOT NULL,
  PRIMARY KEY (CategoryID)
);

CREATE TABLE Continent
(
  ContinentID INT IDENTITY(1, 1) NOT NULL,
  Name NVARCHAR(50) NOT NULL,
  PRIMARY KEY (ContinentID)
);

CREATE TABLE BuyingGroup
(
  BuyingGroupID INT IDENTITY(1, 1) NOT NULL,
  Name NVARCHAR(50) NOT NULL,
  PRIMARY KEY (BuyingGroupID)
);

CREATE TABLE Customer
(
  CustomerID INT NOT NULL,
  WWICustomerID INT NOT NULL,
  Customer NVARCHAR(100) NOT NULL,
  BillToCustomer INT,
  PrimaryContact NVARCHAR(50) NOT NULL,
  AccountID INT,
  CategoryID INT,
  BuyingGroupID INT,
  PostalCode INT NOT NULL,
  PRIMARY KEY (CustomerID),
  FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
  FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
  FOREIGN KEY (BuyingGroupID) REFERENCES BuyingGroup(BuyingGroupID),
  FOREIGN KEY (BillToCustomer) REFERENCES Customer(CustomerID)
);

CREATE TABLE Employee
(
  EmployeeID INT NOT NULL,
  IsSalesperson BIT NOT NULL,
  Photo VARBINARY(MAX),
  PreferredName NVARCHAR(50) NOT NULL,
  Employee NVARCHAR(50) NOT NULL,
  PRIMARY KEY (EmployeeID)
);

CREATE TABLE Country
(
  CountryID INT IDENTITY(1, 1) NOT NULL,
  Name NVARCHAR(50) NOT NULL,
  ContinentID INT NOT NULL,
  PRIMARY KEY (CountryID),
  FOREIGN KEY (ContinentID) REFERENCES Continent(ContinentID)
);

CREATE TABLE State
( 
  StateID INT IDENTITY(1, 1) NOT NULL,
  Name NVARCHAR(50) NOT NULL,
  Code NVARCHAR(5) NOT NULL,
  CountryID INT NOT NULL
  PRIMARY KEY (StateID),
  FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
);


CREATE TABLE City_State
(
  CityStateID INT NOT NULL,
  StateID INT NOT NULL,
  CityID INT NOT NULL,
  PRIMARY KEY (CityStateID),
  FOREIGN KEY (StateID) REFERENCES State(StateID),
  FOREIGN KEY (CityID) REFERENCES City(CityID)
);

CREATE TABLE Invoice
(
  InvoiceID INT /*IDENTITY(1, 1) NOT NULL*/,
  InvoiceDate DATE /*NOT NULL*/,
  DeliveryDate DATE,
  CustomerID INT /*NOT NULL*/,
  CityID INT /*NOT NULL*/,
  TotalExcludingTax DECIMAL(18, 2),
  TotalIncludingTax DECIMAL(18, 2),
  EmployeeID int /*NOT NULL*/,
  PRIMARY KEY (InvoiceID),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (CityID) REFERENCES City_State(CityStateID),
  FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
);

CREATE TABLE Sale
(
  Quantity INT NOT NULL,
  SaleID BIGINT NOT NULL,
  Package NVARCHAR(50) NOT NULL,
  TotalExcludingTax DECIMAL(18, 2) NOT NULL,
  TaxAmount DECIMAL(18, 2) NOT NULL,
  TotalIncludingTax DECIMAL(18, 2) NOT NULL,
  TotalChillerItems INT NOT NULL,
  TotalDryItems INT NOT NULL,
  Profit DECIMAL(18, 2) NOT NULL,
  ProductID INT NOT NULL,
  DiscountID INT,
  InvoiceID INT NOT NULL,
  PRIMARY KEY (SaleID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
  FOREIGN KEY (DiscountID) REFERENCES Discount(DiscountID),
  FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID)
);
