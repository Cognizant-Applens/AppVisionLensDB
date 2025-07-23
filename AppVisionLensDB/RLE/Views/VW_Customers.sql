
CREATE VIEW [RLE].[VW_Customers]
AS
SELECT CustomerID, CustomerName, Esa_AccountId ESACustomerID FROM AVL.Customer Where IsDeleted = 0
