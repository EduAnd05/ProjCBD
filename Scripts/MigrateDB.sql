/********************************************
 *	UC: Complementos de Bases de Dados 2022/2023
 *
 *		Projeto de Época Normal 
 *		Miguel Pintado (202002226)
 *		Eduardo Andrade (202000906)
 *		Turma: 2ºL_EI-SW-05 - sala F157 (16:30h - 18:30h)
 *	
 ********************************************/

-- Script da migração dos dados para a nova base de dados.

use WWI_Global;

-- Inserir dados na tabela Continent
insert into WWI_Global.dbo.Continent(Name)
select distinct continent from WWI_DS.dbo.City;

-- Inserir dados na tabela Country
insert into WWI_Global.dbo.Country(Name, ContinentID)
select distinct country, ContinentID from WWI_DS.dbo.City DSCity, WWI_Global.dbo.Continent GlobalC where DSCity.Continent = GlobalC.Name collate Latin1_General_CI_AS;

-- Inserir dados na tabela City
insert into WWI_Global.dbo.City
select City, [Latest Recorded Population] from 
(select City, [Latest Recorded Population], 
ROW_NUMBER() over (partition by city order by City) rn from WWI_DS.dbo.City) a 
where rn = 1 order by City;

use WWI_Global

-- Criar tabela temporária para os dados do ficheiro State.txt
CREATE TABLE TempState
( 
  Code NVARCHAR(5),
  State NVARCHAR(50)
);

-- Inserir dados do ficheiro state.txt
-- Alterar caminho para o ficheiro
BULK INSERT WWI_Global.dbo.TempState
FROM 'C:\Users\Edu5A\Desktop\Escola\Trabalhos e Exercicios\CBD\2ª vez\Proj\Wide World Importers\states.txt'
WITH
(
        FORMAT='CSV',
		FIELDTERMINATOR = ';',
        FIRSTROW=2
)
GO

-- Inserir dados da tabela temporária na tabela State
insert into WWI_Global.dbo.State(Name, Code, CountryID)
select distinct ts.State, ts.Code, GlobalC.CountryID from WWI_Global.dbo.Country GlobalC, WWI_Global.dbo.TempState ts

-- Apagar tabela temporária
drop table TempState;

--Inserir dados na tabela City_State
insert into WWI_Global.dbo.City_State
select DSCity.[City Key], GlobalS.StateID, GlobalC.CityID from 
WWI_Global.dbo.City GlobalC, 
WWI_Global.dbo.State GlobalS, 
WWI_DS.dbo.City DSCity 
where 
GlobalC.Name = DSCity.City collate Latin1_General_CI_AS and 
GlobalS.Name = DSCity.[State Province] collate Latin1_General_CI_AS;

-- Inseir dados na tabela BuyingGroup
insert into WWI_Global.dbo.BuyingGroup
select distinct [Buying Group] from WWI_DS.dbo.Customer;

use WWI_Global

-- Criar tabela temporária para os dados do ficheiro Category.csv
CREATE TABLE TempCategory
( 
  IDCategory int,
  Name NVARCHAR(50)
);

-- Inserir dados do ficheiro Category.csv
-- Alterar caminho para o ficheiro
BULK INSERT WWI_Global.dbo.TempCategory
FROM 'C:\Users\Edu5A\Desktop\Escola\Trabalhos e Exercicios\CBD\2ª vez\Proj\Wide World Importers\Category.csv'
WITH
(
        FORMAT='CSV',
		FIELDTERMINATOR = ';',
        FIRSTROW=2
)
GO

-- Inserir dados da tabela temporária na tabela Category
insert into WWI_Global.dbo.Category
select * from WWI_Global.dbo.TempCategory;

-- Apagar tabela temporária
drop table if exists TempCategory;

-- Inserir dados na tabela Employee
insert into WWI_Global.dbo.Employee
select [Employee Key], [Is Salesperson], Photo, [Preferred Name], Employee from WWI_DS.dbo.Employee;

-- Inserir dados na tabela Customer
-- Dados null adicionados no fim do script (AccountID só é adicionado depois de serem criadas contas para os users)
insert into WWI_Global.dbo.Customer
select dsCust.[Customer Key], dsCust.[WWI Customer ID], dsCust.Customer, null, dsCust.[Primary Contact], null, null, null/*bg.BuyingGroupID*/, dsCust.[Postal Code] from 
WWI_DS.dbo.Customer dsCust;

-- Inserir dados na tabela Product
insert into WWI_Global.dbo.Product
select dsSI.[Stock Item Key], dsSI.[Unit Price], dsSI.Color, dsSI.[Selling Package], dsSI.[Buying Package], dsSI.Brand, dsSI.Size, dsSI.[Quantity Per Outer], dsSI.[Is Chiller Stock], dsSI.[Stock Item], dsSi.[Lead Time Days], dsSI.Barcode, dsSI.[Tax Rate], dsSI.[Recommended Retail Price], dsSi.[Typical Weight Per Unit] from WWI_DS.dbo.[Stock Item] dsSI

-- Inserir dados na tabela Invoice
insert into WWI_Global.dbo.Invoice(InvoiceID, InvoiceDate, DeliveryDate, CustomerID, CityID, TotalExcludingTax, TotalIncludingTax, EmployeeID)
select [WWI Invoice ID], [Invoice Date Key], [Delivery Date Key], [Customer Key], [City Key], [Total Excluding Tax], [Total Including Tax], [Salesperson Key] from 
(select [Sale Key], [WWI Invoice ID], [Invoice Date Key], [Delivery Date Key], [Customer Key], [City Key], [Total Excluding Tax], [Total Including Tax], [Salesperson Key], ROW_NUMBER() over (partition by [WWI Invoice ID] order by [Customer Key]) rn from WWI_DS.dbo.Sale) a
where rn = 1 order by a.[WWI Invoice ID];

-- Inserir dados na tabela Sale
insert into WWI_Global.dbo.Sale
select Quantity, [Sale Key], Package, [Total Excluding Tax], [Tax Amount], [Total Including Tax], [Total Chiller Items], [Total Dry Items], Profit, [Stock Item Key], null, [WWI Invoice ID] from WWI_DS.dbo.Sale

use WWI_Global

-- Inserir ID da categoria do Customer
update Customer
set CategoryID = gCat.CategoryID from Category gCat inner join WWI_DS.dbo.Customer dsCust on dsCust.Category = gCat.Name collate Latin1_General_CI_AS where Customer.CustomerID = dsCust.[Customer Key];

-- Inserir ID do Buying Group do Customer
update Customer
set BuyingGroupID = gBuy.BuyingGroupID from BuyingGroup gBuy inner join WWI_DS.dbo.Customer dsCust on dsCust.[Buying Group] = gBuy.Name collate Latin1_General_CI_AS where Customer.CustomerID = dsCust.[Customer Key];

-- Inserir ID do Bill to Customer do Customer
update customer
set BillToCustomer = case when (Customer.BuyingGroupID = 1) then 1 else 202 end
