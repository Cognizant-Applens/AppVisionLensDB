/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ================================================
-- Description : Insert UsecaseDetails and coresponding child tables
-- Author:		<Author,Arulkumar>
-- Create date: <Create Date,01/14/2020>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [AVL].[CreateUsecaseDetail]
	@usecaseid nvarchar(50)=null,
	@usecasetitle nvarchar(250)=null,
	@buid bigint=null,
    @customerid bigint=null,
	@referenceid nvarchar(50)=null,
	@applicationid bigint=null,
    @technologyid bigint=null,
	@businessprocessid bigint=null,
    @subbusinessprocessid bigint=null,
	@toolname nvarchar(25)=null,
	@serviceid int=null,
    @automationfeasibility decimal(18,2)=null,
    @overalleffortspent decimal(18,2)=null,
    @usecasestatusid int=null,
    @ismanuallycreated bit=null,
	@createdby nvarchar(50)=null,
	@tags nvarchar(255)=null,
	@solutiontypeids nvarchar(255)=null,
	@servicelevelids nvarchar(255)=null

AS
BEGIN
	BEGIN TRY
		DECLARE @isdeleted INT;		
		DECLARE @CategoryForIdGeneration VARCHAR(2) = 'UC'
		DECLARE @usecasedetailid INT
		DECLARE @UseCaseTags AS NVARCHAR(3000)
		DECLARE @UseCaseSolnType AS NVARCHAR(3000)
		DECLARE @UseCaseServiceLevel AS NVARCHAR(3000)
		SET @isdeleted=0;
		IF @usecaseid IS  NULL OR @usecaseid = ''
		BEGIN
			SET @usecaseid = (SELECT [dbo].[GetNextUseCaseID] (@buid,@customerid))
			

			-- Insert UseCaseDetails
			INSERT INTO [AVL].[UseCaseDetails]
				   ([UseCaseId],[UseCaseTitle],[BUID],[CustomerID],[ReferenceID],[ApplicationID],[TechnologyID],[BusinessProcessID]
				   ,[SubBusinessProcessID],[ToolName],[ServiceID],[AutomationFeasibility],[OverAllEffortSpent],[UseCaseStatusId]
				   ,[IsManuallyCreated],[IsDeleted],[CreatedBy],[CreatedOn])
			 VALUES
				   (@usecaseid,@usecasetitle,@buid,@customerid,@referenceid,@applicationid,@technologyid,@businessprocessid,
				   @subbusinessprocessid,@toolname,@serviceid,@automationfeasibility,@overalleffortspent,@usecasestatusid
				   ,@ismanuallycreated,@isdeleted,@createdby,GETDATE());
	
			set @usecasedetailid = @@IDENTITY;

			UPDATE AVL.TK_MAP_AHIDGeneration SET NextId = NextId + 1  WHERE Category =@CategoryForIdGeneration

			END
		ELSE
			BEGIN		
				UPDATE [AVL].[UseCaseDetails]
				SET
					[UseCaseTitle] = @usecasetitle,
					[BUID] = @buid,
					[CustomerID] = @customerid,
					[ReferenceID] = @referenceid,
					[ApplicationID] = @applicationid,
					[TechnologyID] = @technologyid,
					[BusinessProcessID] = @businessprocessid,
					[SubBusinessProcessID] = @subbusinessprocessid,
					[ToolName] =@toolname,
					[ServiceID] = @serviceid,
					[AutomationFeasibility]=@automationfeasibility,
					[OverAllEffortSpent] = @overalleffortspent,
					[UseCaseStatusId] = @usecasestatusid,
					ModifiedBy = @createdby,
					ModifiedOn = GETDATE()
				WHERE 
					[UseCaseId] = @usecaseid
					
				SET @usecasedetailid = (SELECT ID FROm [AVL].[UseCaseDetails] WHERE [UseCaseId] = @usecaseid)

				DELETE FROM [AVL].[UseCaseTagDetail] WHERE UseCaseDetailId = @usecasedetailid
				DELETE FROM [AVL].[UseCaseSolutionTypeDetail] WHERE UseCaseDetailId = @usecasedetailid
				DELETE FROM [AVL].[UseCaseServiceLevelDetails] WHERE UseCaseDetailId = @usecasedetailid
			END

			INSERT INTO [AVL].[UseCaseTagDetail]
					([UseCaseDetailId],[Tag],[IsDeleted],[CreatedBy],[CreatedDate])
					select @usecasedetailid,tag.item,@isdeleted,@createdby,GETDATE()
					from dbo.SplitString(@tags, ',') tag where tag.Item is not null;
		

			INSERT INTO [AVL].[UseCaseSolutionTypeDetail]
					([UseCaseDetailId],[SolutionTypeID],[IsDeleted],[CreatedBy],[CreatedDate])
					select @usecasedetailid,solutiontypeid.item,@isdeleted,@createdby,GETDATE()
					from dbo.SplitString(@solutiontypeids, ',') solutiontypeid;
		
			INSERT INTO [AVL].[UseCaseServiceLevelDetails]
					([UseCaseDetailId],[ServiceLevelID],[IsDeleted],[CreatedBy],[CreatedDate])
					select @usecasedetailid,servicelevelid.item,@isdeleted,@createdby,GETDATE()
					from dbo.SplitString(@servicelevelids, ',') servicelevelid;

			
			SET @UseCaseTags = (SELECT DISTINCT STUFF((SELECT DISTINCT ', ' + t1.Tag 
								FROM [AVL].[UseCaseTagDetail] t1
								WHERE t1.UseCaseDetailId = @usecasedetailid
								FOR XML PATH('')),1,2,'') tags
								FROM [AVL].[UseCaseTagDetail] t );

			SET @UseCaseSolnType =(SELECT DISTINCT STUFF((SELECT DISTINCT ', ' + CAST(t1.SolutionTypeID AS VARCHAR(20)) 
									FROM [AVL].[UseCaseSolutionTypeDetail] t1
									WHERE t1.UseCaseDetailId = @usecasedetailid
									FOR XML PATH('')),1,2,'') tags
									FROM [AVL].[UseCaseSolutionTypeDetail] t );
			
			SET @UseCaseServiceLevel = (SELECT DISTINCT STUFF((SELECT DISTINCT ', ' + CAST(t1.ServiceLevelID  AS VARCHAR(20)) 
										FROM [AVL].[UseCaseServiceLevelDetails] t1
										WHERE t1.UseCaseDetailId = @usecasedetailid
										FOR XML PATH('')) ,1,2,'') tags
										FROM [AVL].[UseCaseServiceLevelDetails] t );
			
			SELECT 	UseCaseId
					,UseCaseTitle
					,Buid 
					,CustomerId
					,ReferenceId
					,ApplicationId
					,TechnologyId
					,BusinessProcessid
					,SubBusinessProcessid
					,ToolName
					,ServiceId
					,AutomationFeasibility
					,OverallEffortSpent
					,UseCaseStatusid
					,IsManuallyCreated
					,CreatedBy			
					,@UseCaseTags					
					,@UseCaseSolnType
					,@UseCaseServiceLevel			
			
			
			FROM [AVL].[UseCaseDetails] WHERE Id=@usecasedetailid

	END TRY
	BEGIN CATCH 
	   DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 
          --ROLLBACK TRAN 

          -- Insert Error     
          EXEC AVL_INSERTERROR '[avl].[CreateUsecaseDetail]',@ErrorMessage,0,0 
	  END CATCH
END
