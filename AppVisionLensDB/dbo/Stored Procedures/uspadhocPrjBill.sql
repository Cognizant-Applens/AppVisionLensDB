


CREATE PROCEDURE [dbo].[uspadhocPrjBill]
AS
Begin

       IF EXISTS (SELECT TOP 1 [Project_ID] FROM [$(AVMCOEESADB)].[dbo].[vw_GMSPMO_Project])
       BEGIN
       DELETE FROM [dbo].[GMSPMO_ProjectBill]

       INSERT INTO [dbo].[GMSPMO_ProjectBill]
       SELECT [Project_ID]
      ,[ACCOUNT_ID]
      ,[ACCOUNT_NAME]
      ,[Customer_ID]
      ,[Billability_Type]
      ,[Project_Start_Date]
      ,[Project_End_Date]
 	  ,getdate() as refreshdate
	  ,'uspadhocPrjBill' as createdby
       FROM [$(AVMCOEESADB)].[dbo].[vw_GMSPMO_Project] 
	   END
End