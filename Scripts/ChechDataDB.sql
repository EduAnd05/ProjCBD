-- Numero de customers
select count(*) from WWI_Global.dbo.Customer;
select count(*) from WWI_DS.dbo.Customer;

-- Numero de customers ordenado por category
select count(*) from WWI_Global.dbo.Customer group by CategoryID;
select count(*) from WWI_DS.dbo.Customer group by Category;

-- Numero de vendas por Employee
select EmployeeID, count(*) as 'Numero de vendas' from WWI_Global.dbo.Sale as Sale inner join WWI_Global.dbo.Invoice as Invoice on Sale.InvoiceID = Invoice.InvoiceID group by EmployeeID order by EmployeeID;
select [Salesperson Key], count(*) as 'Numero de vendas' from WWI_DS.dbo.Sale group by [Salesperson Key] order by [Salesperson Key];