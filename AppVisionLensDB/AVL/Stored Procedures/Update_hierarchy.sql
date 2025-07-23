/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [AVL].[Update_hierarchy] 
CREATE PROCEDURE  [AVL].[Update_hierarchy]  
@CustomerID bigint,
@EmployeeID nvarchar(50),
@Hierarchy1ID int ,
@Hierarchy2ID int ,
@Hierarchy3ID int ,
@Hierarchy4ID int ,
@Hierarchy5ID int ,
@Hierarchy6ID int ,
@Hierarchy1 nvarchar(50),
@Hierarchy2 nvarchar(50),
@Hierarchy3 nvarchar(50),
@Hierarchy4 nvarchar(50),
@Hierarchy5 nvarchar(50),
@Hierarchy6 nvarchar(50)
AS        
BEGIN   
BEGIN TRY     	

		--Hierarchy1     

		update [AVL].[BusinessCluster] set businessclustername=@Hierarchy1 where businessclusterid=@Hierarchy1ID and CustomerID=@CustomerID


		--Hierarchy2

		update [AVL].[BusinessCluster] set businessclustername=@Hierarchy2 where businessclusterid=@Hierarchy2ID and CustomerID=@CustomerID

		--Hierarchy3

		update [AVL].[BusinessCluster] set businessclustername=@Hierarchy3 where businessclusterid=@Hierarchy3ID and CustomerID=@CustomerID

		--Hierarchy4
		if(@Hierarchy4='' and @Hierarchy4ID<>0)
		begin
			
			IF EXISTS(SELECT * FROM AVL.BusinessClusterMapping WHERE BusinessClusterID = @Hierarchy4ID)
				BEGIN
					DELETE FROM AVL.BusinessClusterMapping WHERE BusinessClusterID = @Hierarchy4ID
				END

			update  [AVL].[BusinessCluster] set  IsHavingSubBusinesss = 0 where businessclusterid=@Hierarchy3ID and CustomerID=@CustomerID

			Delete [AVL].[BusinessCluster] where businessclusterid=@Hierarchy4ID


		end
		else if(@Hierarchy4<>'' and @Hierarchy4ID<>0)
		begin
		update [AVL].[BusinessCluster] set businessclustername=@Hierarchy4 where businessclusterid=@Hierarchy4ID and CustomerID=@CustomerID
		end
		else if(@Hierarchy4<>'' and @Hierarchy4ID=0 AND @Hierarchy5='' AND @Hierarchy5ID=0 and @Hierarchy6='' and @Hierarchy6ID=0)
		begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy4,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy3 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)
		update [AVL].[BusinessCluster] set  IsHavingSubBusinesss=1 where businessclusterid=@Hierarchy3ID and CustomerID=@CustomerID	
		end
		--Hierarchy5
		if(@Hierarchy5='' and @Hierarchy5ID<>0)
		begin
			
			IF EXISTS(SELECT * FROM AVL.BusinessClusterMapping WHERE BusinessClusterID = @Hierarchy5ID)
				BEGIN
					DELETE FROM AVL.BusinessClusterMapping WHERE BusinessClusterID = @Hierarchy5ID
				END

		update [AVL].[BusinessCluster] set  IsHavingSubBusinesss=0 where businessclusterid=@Hierarchy4ID and CustomerID=@CustomerID

		Delete [AVL].[BusinessCluster] where businessclusterid=@Hierarchy5ID

		end
		else if(@Hierarchy5<>'' and @Hierarchy5ID<>0)
		begin
		update [AVL].[BusinessCluster] set businessclustername=@Hierarchy5 where businessclusterid=@Hierarchy5ID and CustomerID=@CustomerID
		end
		else if(@Hierarchy4<>'' and @Hierarchy4ID<>0 and @Hierarchy5<>'' and @Hierarchy5ID=0 and @Hierarchy6='' and @Hierarchy6ID=0)
		begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy5,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy4 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)
		update [AVL].[BusinessCluster] set  IsHavingSubBusinesss=1 where businessclusterid=@Hierarchy4ID and CustomerID=@CustomerID	
		end
		--Hierarchy6
		if(@Hierarchy6='' and @Hierarchy6ID<>0)
		begin
			
			IF EXISTS(SELECT * FROM AVL.BusinessClusterMapping WHERE BusinessClusterID = @Hierarchy6ID)
				BEGIN
					DELETE FROM AVL.BusinessClusterMapping WHERE BusinessClusterID = @Hierarchy6ID
				END

		Delete [AVL].[BusinessCluster] where businessclusterid=@Hierarchy6ID

		update [AVL].[BusinessCluster] set  IsHavingSubBusinesss=0 where businessclusterid=@Hierarchy5ID and CustomerID=@CustomerID
		end
		else if(@Hierarchy6<>'' and @Hierarchy6ID<>0)
		begin
		update [AVL].[BusinessCluster] set businessclustername=@Hierarchy6 where businessclusterid=@Hierarchy6ID and CustomerID=@CustomerID
		end
		else if(@Hierarchy6<>'' and @Hierarchy6ID=0 and @Hierarchy5<>'' and @Hierarchy5ID<>0 AND @Hierarchy4<>'' and @Hierarchy4ID<>0)
		begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy6,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy5 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)
		update [AVL].[BusinessCluster] set  IsHavingSubBusinesss=1 where businessclusterid=@Hierarchy5ID and CustomerID=@CustomerID	
		end   
		
		else if(@Hierarchy4<>'' and @Hierarchy4ID=0 AND @Hierarchy5<>'' AND @Hierarchy5ID=0 AND @Hierarchy6<>'' AND @Hierarchy6ID=0)
		begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy4,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy3 and CustomerID=@CustomerID),1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)
		insert into [AVL].[BusinessCluster] values(@Hierarchy5,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy4 and CustomerID=@CustomerID),1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)
		insert into [AVL].[BusinessCluster] values(@Hierarchy6,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy5 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)
		update [AVL].[BusinessCluster] set  IsHavingSubBusinesss=1 where businessclusterid=@Hierarchy3ID and CustomerID=@CustomerID	
		END

		ELSE IF (@Hierarchy4<>'' and @Hierarchy4ID=0 AND @Hierarchy5<>'' AND @Hierarchy5ID=0 AND @Hierarchy6='' AND @Hierarchy6ID=0)
		begin
		insert into [AVL].[BusinessCluster] values(@Hierarchy4,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy3 and CustomerID=@CustomerID),1,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)
		insert into [AVL].[BusinessCluster] values(@Hierarchy5,(select  businessclusterid from [AVL].[BusinessCluster] where businessclustername=@Hierarchy4 and CustomerID=@CustomerID),0,0,@CustomerID,@EmployeeID,getdate(),NULL,NULL)		
		update [AVL].[BusinessCluster] set  IsHavingSubBusinesss=1 where businessclusterid=@Hierarchy3ID and CustomerID=@CustomerID	
		END

		  
END TRY  
BEGIN CATCH  
                DECLARE @ErrorMessage VARCHAR(MAX);

                SELECT @ErrorMessage = ERROR_MESSAGE()

                EXEC AVL_InsertError '[AVL].[Update_hierarchy] ', @ErrorMessage, @EmployeeID, @CustomerID 
                                
END CATCH
END
