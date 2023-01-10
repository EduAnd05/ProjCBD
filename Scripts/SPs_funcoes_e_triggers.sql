/********************************************
 *	UC: Complementos de Bases de Dados 2022/2023
 *
 *		Projeto de Época Normal 
 *		Miguel Pintado (202002226)
 *		Eduardo Andrade (202000906)
 *		Turma: 2ºL_EI-SW-05 - sala F157 (16:30h - 18:30h)
 *	
 ********************************************/

--============================================================================= 
-- Etapa 1
--============================================================================= 

-- -------------------------------------------
-- 2.1.2) Programação
-- -------------------------------------------

-- Todos os requisitos apresentados deverão ser implementados através da solução apropriada e 
-- justificada. No entanto devem ser criados obrigatoriamente os store procedures (SP), user defined 
-- functions (UDF) e triggers que implementem os seguintes processos de negócio:

-- • Implementação dos requisitos relativos aos pontos 2 e 3 da secção 2.1.1 (gestão de 
-- utilizadores e promoções);

-- • Criar uma venda;
-- Novo invoice
-- Recebe ambas as datas, o id do cliente e da cidade e gera um id para o novo invoice
use WWI_Global
drop procedure if exists spNovaVenda
GO
create procedure spNovaVenda
	@deliverydate date,
	@customerid int,
	@cityid int,
	@employeeid int

AS
BEGIN
--	declare @invoiceid int;
--	set @invoiceid = NEWID();

declare @invoicedate date;
set @invoicedate = GETDATE();

declare @invoiceid int;
select @invoiceid = count(InvoiceID)+1 from Invoice
	
	insert into dbo.Invoice(InvoiceID, InvoiceDate, DeliveryDate, CustomerID, CityID, EmployeeID)
		values(@invoiceid, @invoicedate, @deliverydate, @customerid, @cityid, @employeeid);
END

select * from Customer
select * from City
select * from Employee


declare @delivery date;
set @delivery = GETDATE();
exec spNovaVenda @delivery, '30', '30', '3';

-- • Adicionar um produto a uma venda;
-- Novo sale
-- Recebe a quantidade, pacote, profit, id do produto, id do desconto
drop procedure if exists spAddProduct
GO
create procedure spAddProduct
	@quantity int, 
	@package nvarchar(50),
	@totalexcludingtax int,
	@taxamount decimal,
	@totalchilleritems int,
	@totaldryitems int,
	@profit decimal, 
	@productid int, 
	@invoiceid int
AS
BEGIN
	declare @saleid bigint;
	declare @totalincludingtax decimal;

	set @totalincludingtax = @totalexcludingtax + (@totalexcludingtax*@taxamount)

	select @saleid = count(SaleID)+1 from Sale

	insert into dbo.Sale(Quantity, SaleID, Package, TotalExcludingTax, TaxAmount, TotalIncludingTax, TotalChillerItems, TotalDryItems, Profit, ProductID, InvoiceID)
		values(@quantity, @saleid, @package, @totalexcludingtax, @taxamount, @totalincludingtax, @totalchilleritems, @totaldryitems, @profit, @productid, @invoiceid);
	
END

declare @quantityTest int;
set @quantityTest = 5;
declare @packageTest nvarchar(50);
set @packageTest = 'test package'
declare @totalexcludingtaxTest decimal;
set @totalexcludingtaxTest = '100'
declare @taxTest decimal
set @taxTest = 0.1
declare @totalchillerItemsTest int
set @totalchillerItemsTest = 1
declare @totaldryitemsTest int
set @totaldryitemsTest = 0
declare @profitTest decimal
set @profitTest = 0.3
declare @productidTest int
set @productidTest = 1
declare @invoiceidTest int
set @invoiceidTest = 1

exec spAddProduct @quantityTest, @packageTest, @totalexcludingtaxTest, @taxTest, @totalchillerItemsTest, @totaldryitemsTest,
@profitTest, @productidTest, @invoiceidTest


-- • Alterar a quantidade de um produto numa venda;
-- Recebe o id do produto a alterar e a nova quantidade do mesmo, fazendo posteriormente um update à tabela de vendas
drop procedure if exists spUpdateQuantity
GO
create procedure spUpdateQuantity
	@saleid bigint,
	@newquantity int
AS
BEGIN
	UPDATE Sale
	set Quantity = @newquantity
	from dbo.Sale
	where SaleID = @saleid
END

declare @saleidtest bigint
set @saleidtest = 1
declare @newquantitytest int
set @newquantitytest = 3
exec spUpdateQuantity @saleidtest, @newquantitytest

-- • Remover um produto de uma venda. Recebe um parâmetro que indica se a venda é removida 
-- no caso de não ter mais produtos associados;
-- Remove Sale
-- Recebe o id do produto a remover e aplica o delete ao mesmo
drop procedure if exists spRemoveProduct
GO
create procedure spRemoveProduct
	@saleid bigint
AS
BEGIN
	DELETE Sale
	from dbo.Sale
	where SaleID = @saleid
END

declare @saleidtest bigint
set @saleidtest = 1
exec spRemoveProduct @saleidtest

select * from Sale

-- • Calcular o preço total de uma venda;
drop function if exists fnTotalVenda
GO
create function fnTotalVenda(@invoiceID int)
returns float
AS
BEGIN
	declare @total float
	set @total = 0
	select @total = sum(s.TotalIncludingTax)
	from dbo.Sale s, dbo.Product p
	where @invoiceID = s.InvoiceID and s.ProductID = p.ProductID
	return (@total)
END
GO

select dbo.fnTotalVenda(1)


-- • Implementar a regra de negócio que verifique se a data de entrega está de acordo com o 
-- tempo previsto de entrega de um produto (“Lead Time Days”);


-- • Não permitir uma venda conter produtos com e sem “Chiller Stock”.



-- • Alterar a data de início de uma promoção
drop procedure if exists spUpdatePromotionStart
GO
create procedure spUpdatePromotionStart
	@discountid int,
	@startdate date
AS
BEGIN
	UPDATE Discount
	set StartDate = @startdate
	from dbo.Discount
	where DiscountID = @discountid
END

declare @discountidtest int
set @discountidtest = 1
declare @startdatetest date
set @startdatetest = getdate();

exec spUpdatePromotionStart @discountidtest, @startdatetest


-- • Alterar a data de fim de uma promoção
drop procedure if exists spUpdatePromotionEnd
GO
create procedure spUpdatePromotionEnd
	@discountid int,
	@enddate date
AS
BEGIN
	UPDATE Discount
	set EndDate = @enddate
	from dbo.Discount
	where DiscountID = @discountid
END

declare @discountidtest int
set @discountidtest = 1
declare @enddatetest date
set @enddatetest = getdate();

exec spUpdatePromotionEnd @discountidtest, @enddatetest

-- -------------------------------------------
-- 2.1.3) Verificação da nova BD
-- -------------------------------------------

-- Produza um conjunto de queries que dirigindo às duas bases de dados permita verificar a 
-- conformidade dos dados no novo face aos dados originalmente fornecidos.

-- • Nº de “Customers”
SELECT count(Customer) as 'Numero de Clientes' from WWI_Global.dbo.Customer
UNION
SELECT count([WWI Customer ID]) as 'Numero de Clientes' from WWI_DS.dbo.Customer

-- • Nº de “Customers” por “Category”
SELECT count(c.Customer) as 'Numero de Clientes Nova DB', c.CategoryID as 'ID da Categoria'
from WWI_Global.dbo.Customer c
group by c.CategoryID

SELECT count(c.[WWI Customer ID]) as  'Numero de Clientes DB antiga', c.Category
from WWI_DS.dbo.Customer c group by Category


-- • Total de vendas por “Employee”
SELECT count(i.InvoiceID) as 'Total de Vendas NEW', e.EmployeeID as 'Employee ID'
from WWI_Global.dbo.Invoice i, WWI_Global.dbo.Employee e
where i.EmployeeID = e.EmployeeID
group by e.EmployeeID

SELECT count(*) as 'Total de Vendas OLD', s.[Salesperson Key] as 'Employee ID'
from WWI_DS.dbo.Sale s
group by s.[Salesperson Key]

-- • Total monetário de vendas por “Stock Item”
--OLD
SELECT sum(s.Quantity * s.[Unit Price]) as 'Total Monetário', s.[Stock Item Key] as 'StockItem Key'
from WWI_DS.dbo.Sale s
group by s.[Stock Item Key]
--NEW
SELECT sum(p.QuantityPerOuter * p.UnitPrice) as 'Total Monetário', p.ProductID as 'Product ID'
from WWI_Global.dbo.Product p
group by p.ProductID


-- • Total monetário de vendas por ano por “Stock Item”
--OLD
SELECT sum(s.Quantity * s.[Unit Price]) as 'Total Monetário', s.[Stock Item Key] as 'StockItem Key', 
YEAR(s.[Delivery Date Key]) as 'Ano'
from WWI_DS.dbo.Sale s
group by YEAR(s.[Delivery Date Key]), s.[Stock Item Key]
order by YEAR(s.[Delivery Date Key]) ASC
--NEW
SELECT sum(p.QuantityPerOuter * p.UnitPrice) as 'Total Monetário', p.ProductID as 'Product ID',
YEAR(i.DeliveryDate) as 'Ano'
from WWI_Global.dbo.Product p, WWI_Global.dbo.Sale s, WWI_Global.dbo.Invoice i
where p.ProductID = s.ProductID and s.InvoiceID = i.InvoiceID
group by YEAR(i.DeliveryDate), p.ProductID
order by YEAR(i.DeliveryDate)

select * from Invoice
select * from Product

-- • Total monetário de vendas por ano por “City”
--OLD
SELECT sum(s.Quantity * s.[Unit Price]) as 'Total Monetário', s.[City Key] as 'City Key',
YEAR(s.[Delivery Date Key]) as 'Ano'
from WWI_DS.dbo.Sale s
group by s.[City Key], YEAR(s.[Delivery Date Key])
order by YEAR(s.[Delivery Date Key]) ASC
--NEW
SELECT sum(p.QuantityPerOuter * p.UnitPrice) as 'Total Monetário', p.ProductID as 'Product ID',
YEAR(i.DeliveryDate) as 'Ano'
from WWI_Global.dbo.Product p, WWI_Global.dbo.Sale s, WWI_Global.dbo.Invoice i
where p.ProductID = s.ProductID and s.InvoiceID = i.InvoiceID
group by YEAR(i.DeliveryDate), p.ProductID
order by YEAR(i.DeliveryDate) ASC

-- Notas: 
-- • Apenas deve ser contabilizada uma venda, mesmo que esta contenha vários produtos associados;
-- • Valor monetário obtido por quantity*Unit Price;
-- • O ano deve ser retirado da coluna “Delivery Date Key”


-- -------------------------------------------
-- 2.1.4) Catálogos/Metadados
-- -------------------------------------------

-- • Espaço ocupado por registo de cada tabela;
-- • Espaço ocupado por cada tabela com o número atual de registos
EXEC sp_spaceused 'Account' -- Tabela Account
EXEC sp_spaceused 'Category' -- Tabela Category
EXEC sp_spaceused 'City' -- Tabela City
EXEC sp_spaceused 'City_State' -- Tabela City_State
EXEC sp_spaceused 'Continent' -- Tabela Continent
EXEC sp_spaceused 'Country' -- Tabela Country
EXEC sp_spaceused 'Customer' -- Tabela Customer
EXEC sp_spaceused 'Discount' -- Tabela Discount
EXEC sp_spaceused 'Employee' -- Tabela Employee
EXEC sp_spaceused 'Invoice' -- Tabela Invoice
EXEC sp_spaceused 'PasswordRecovery' -- Tabela PasswordRecovery
EXEC sp_spaceused 'Product' -- Tabela Product
EXEC sp_spaceused 'Sale' -- Tabela Sale
EXEC sp_spaceused 'State' -- Tabela State

-- • Propor uma taxa de crescimento por tabela (inferindo dos dados existentes);


-- • Dimensionar o nº e tipos de acesso


-- -------------------------------------------
-- 2.1.5) Layout da BD
-- -------------------------------------------

-- • um stored procedure por tabela referida que implementa a operação de insert;
drop procedure if exists spAddCustomer
GO
create procedure spAddCustomer
	@wwicustomerid int,
	@customer nvarchar(100),
	@billtocustomer nvarchar(100),
	@primarycontact nvarchar(50),
	@accountid int,
	@categoryid int,
	@postalcode int
AS
BEGIN
	declare @customerid int
	select @customerid = c.CustomerID+1 from Customer c

	insert into dbo.Customer(CustomerID, WWICustomerID, Customer, BillToCustomer, PrimaryContact, AccountID, CategoryID, PostalCode)
		values(@customerid, @wwicustomerid, @customer, @billtocustomer, @primarycontact, @accountid, @categoryid, @postalcode);
END

declare @wwicustomeridtest int;
select @wwicustomeridtest = count(c.WWICustomerID)+1 from Customer c;
declare @customertest nvarchar(100);
set @customertest = 'Jose Maria';
declare @billtocustomertest nvarchar(100)
set @billtocustomertest = '1'
declare @primarycontacttest nvarchar(50)
set @primarycontacttest = 'Test'
declare @accountidtest int
set @accountidtest = null
declare @categoryidtest int
set @categoryidtest = 1
declare @postalcodetest int
set @postalcodetest = 90410

exec dbo.spAddCustomer @wwicustomeridtest,  @customertest, @billtocustomertest, @primarycontacttest, @accountidtest, @categoryidtest, @postalcodetest

select * from Customer

-- • um stored procedure por tabela referida que implementa a operação de update;
drop procedure if exists spUpdateCustomer
GO
create procedure spUpdateCustomer
	@customerid int,
	@wwicustomerid int,
	@customer nvarchar(100),
	@billtocustomer nvarchar(100),
	@primarycontact nvarchar(50),
	@accountid int,
	@categoryid int,
	@postalcode int
AS
BEGIN
	UPDATE Customer
	set WWICustomerID = @wwicustomerid, Customer = @customer, BillToCustomer = @billtocustomer,
	PrimaryContact = @primarycontact, AccountID = @accountid, CategoryID = @categoryid, PostalCode = @postalcode
	from dbo.Customer
	where CustomerID = @customerid
END

declare @customeridtest int;
select @customeridtest = count(c.CustomerID) from Customer c
declare @wwicustomeridtest int;
select @wwicustomeridtest = count(c.WWICustomerID) from Customer c;
declare @customertest nvarchar(100);
set @customertest = 'Jose Maria';
declare @billtocustomertest nvarchar(100)
set @billtocustomertest = '1'
declare @primarycontacttest nvarchar(50)
set @primarycontacttest = 'Test'
declare @accountidtest int
set @accountidtest = null
declare @categoryidtest int
set @categoryidtest = 1
declare @postalcodetest int
set @postalcodetest = 90410

exec spUpdateCustomer @customeridtest, @wwicustomeridtest,  @customertest, @billtocustomertest, @primarycontacttest, @accountidtest, @categoryidtest, @postalcodetest

-- • um stored procedure por tabela referida que implementa a operação de delete.
drop procedure if exists spRemoveCustomer
GO
create procedure spRemoveCustomer
	@customerid int
AS
BEGIN
	DELETE Customer
	from dbo.Customer
	where CustomerID = @customerid
END

declare @customeridtest int
select @customeridtest = count(c.CustomerID) from Customer c

exec spRemoveCustomer @customeridtest

-- • Uma stored procedure que recorra ao catalogo para gerar entradas numa tabela(s)
-- dedicada(s) onde deve constar a seguinte informação relativa à base de dados: todos os 
-- campos de todas as tabelas, com os seus tipos de dados, tamanho respetivo e restrições
-- associadas. Deverá manter histórico de alterações do esquema da BD nas sucessivas 
-- execuções da sp.

-- • Uma view que disponibilize os dados relativos à execução mais recente, presentes na tabela 
-- do ponto anterior.

-- • Uma stored procedure que registe, também em tabela dedicada, por cada tabela da base de 
-- dados o seu número de registos e estimativa mais fiável do espaço ocupado.
-- Deverá manter histórico dos resultados das sucessivas execuções da sp.


use WWI_Global

drop table if exists TamanhoRegistos
Create table TamanhoRegistos(
	RegistosID int not null,
	NomeTabela nvarchar(20),
	NumeroRegistos int,
	EspacoOcupado int,
	primary key (RegistosID)
)
/*
select * from TamanhoRegistos

drop procedure if exists spRegisterTable
GO
create procedure spRegisterTable
	@nometabela nvarchar(20)
AS
BEGIN
	declare @registosid int
	select @registosid = count(RegistosID) from TamanhoRegistos

END
*/