/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE  [AVL].[Insert_hierarchy]  
@CustomerID bigint,
@EmployeeID nvarchar(50),
@Hierarchy1 nvarchar(50),
@Hierarchy2 nvarchar(50),
@Hierarchy3 nvarchar(50),
@Hierarchy4 nvarchar(50),
@Hierarchy5 nvarchar(50),
@Hierarchy6 nvarchar(50)
AS        
BEGIN  
BEGIN TRY 
BEGIN TRAN

--Hierarchy1     
insert into [AVL].[BusinessCluster] values(@Hierarchy1,null,1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)



--Hierarchy2
insert into [AVL].[BusinessCluster] values(@Hierarchy2,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy1 and CustomerID=@CustomerID),1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL) 

--Hierarchy3
if(@Hierarchy4=null or @Hierarchy4='')
	begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy3,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy2 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL) 

	end
	else
	begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy3,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy2 and CustomerID=@CustomerID),1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL) 

	end

--Hierarchy4
if(@Hierarchy4!=null or @Hierarchy4!='')
begin
	if(@Hierarchy5=null or @Hierarchy5='')
	begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy4,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy3 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL) 

	end
	else
	begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy4,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy3 and CustomerID=@CustomerID),1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL) 

	end
end

--Hierarchy5

if(@Hierarchy5!=null or @Hierarchy5!='')
begin
	if(@Hierarchy6=null or @Hierarchy6='')
	begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy5,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy4 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL) 

	end
	else
	begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy5,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy4 and CustomerID=@CustomerID),1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL) 

	end
end

--Hierarchy6
if(@Hierarchy6!=null or @Hierarchy6!='')
begin
	insert into [AVL].[BusinessCluster] values(@Hierarchy6,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy5 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)	

end
/*progress*/

IF NOT EXISTS(SELECT * from avl.PRJ_ConfigurationProgress WHERE ScreenID=1 AND CustomerID=@CustomerId)
			BEGIN
			INSERT INTO avl.PRJ_ConfigurationProgress(CustomerID,ScreenID,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
			VALUES(@CustomerId,1,25,0,@EmployeeID,GETDATE())
			END


COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Insert_hierarchy]', @ErrorMessage, 0,@CustomerID
		
	END CATCH  
END
