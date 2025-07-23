/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [PP].[SaveBestPracticeDetail]
@ProjectID BIGINT,
@EmployeeID NVARCHAR(20),
@BPOtherAttributeValues as [PP].[TVP_ProjectOtherAttributeValues] READONLY,
@BPAttributeValues as [PP].[TVP_ProjectAttributeValues] READONLY,
@BPExtendedDetail as [PP].[TVP_BestPracticeDetails] READONLY
AS 
  BEGIN 
	BEGIN TRY  
	   BEGIN TRAN
		SET NOCOUNT ON;



		-- insert project attribute value based on Hosted environment in App Inventory 
	
			
	DECLARE @Result BIT;		
	
	 

	--Inserts the Best Practice Details >Start<
	MERGE PP.BestPractices BP 
    using @BPExtendedDetail AS Temp 
    ON BP.ProjectID = @ProjectID 
    WHEN matched THEN 
      UPDATE SET 	
				   BP.KEDBOwnedId               = CASE WHEN temp.KEDBOwnedId=0 THEN NULL ELSE temp.KEDBOwnedId END 
				  ,BP.ExternalKEDB			    = temp.ExternalKEDB
				  ,BP.IsApplensAsKEDB			= temp.IsApplensAsKEDB
				  ,BP.IsReqBaselined			= temp.IsReqBaselined
				  ,BP.IsAcceptanceDefined		= temp.IsAcceptanceDefined
				  ,BP.ScopeChangeControlId		=CASE WHEN temp.ScopeChangeControlId=0 THEN NULL ELSE temp.ScopeChangeControlId END 
				  ,BP.IsVelocityMeasured		= temp.IsVelocityMeasured
				  ,BP.UOM						= temp.UOM
				  ,BP.IsDevOrMainByCog			= temp.IsDevOrMainByCog
				  ,BP.IntegratedServiceId		=CASE WHEN temp.IntegratedServiceId=0 THEN NULL ELSE temp.IntegratedServiceId END 
				  ,BP.StatusReportId			=CASE WHEN temp.StatusReportId=0 THEN NULL ELSE temp.StatusReportId END 
				  ,BP.ExplicitRisks				= temp.ExplicitRisks
				  ,BP.ModifiedBy                = @EmployeeID
				  ,BP.ModifiedDate               = getdate()
    WHEN NOT matched THEN 
      INSERT ( 
			      ProjectID
			     ,KEDBOwnedId           
			     ,ExternalKEDB			
			     ,IsApplensAsKEDB		
			     ,IsReqBaselined		
			     ,IsAcceptanceDefined	
			     ,ScopeChangeControlId	
			     ,IsVelocityMeasured	
			     ,UOM					
			     ,IsDevOrMainByCog		
			     ,IntegratedServiceId	
			     ,StatusReportId		
			     ,ExplicitRisks		
			     ,IsDeleted
	             ,CreatedBy
	             ,CreatedDate
	             ,ModifiedBy
	             ,ModifiedDate         
			  )
			   values
			   ( 
				  @ProjectID
				,CASE WHEN temp.KEDBOwnedId=0 THEN NULL ELSE temp.KEDBOwnedId END
				,temp.ExternalKEDB		
				,temp.IsApplensAsKEDB
				,temp.IsReqBaselined
				,temp.IsAcceptanceDefined
				,CASE WHEN temp.ScopeChangeControlId=0 THEN NULL ELSE temp.ScopeChangeControlId END 
				,temp.IsVelocityMeasured
				,temp.UOM
				,temp.IsDevOrMainByCog
				,CASE WHEN temp.IntegratedServiceId=0 THEN NULL ELSE temp.IntegratedServiceId END 
				,CASE WHEN temp.StatusReportId=0 THEN NULL ELSE temp.StatusReportId END
				,temp.ExplicitRisks
				 ,0
				 ,@EmployeeID 
				 ,getdate() 
				 ,null
			     ,null
				 );
	--Inserts the Best Practice Details >End<

	--Inserts the Attribute values >Start<
	
	UPDATE  PP.ProjectAttributeValues  SET 
    ModifiedBy                 = @EmployeeID,  
    ModifiedDate               = getdate(),  
    IsDeleted     =1  where AttributeID in(40,41) and ProjectID = @ProjectID;
		
	MERGE PP.ProjectAttributeValues PA 
    using @BPAttributeValues AS Temp 
    ON PA.ProjectID = @ProjectID  and PA.AttributeValueID = Temp.AttributeValueID and PA.AttributeID = Temp.AttributeID
    WHEN matched THEN 
      UPDATE SET PA.AttributeValueID         = Temp.AttributeValueID,
				 PA.ModifiedBy                 = @EmployeeID,
				 PA.ModifiedDate               = getdate(),
				 PA.IsDeleted					=0
    WHEN NOT matched THEN 
      INSERT ( 
			   ProjectID
	          ,AttributeValueID
	          ,AttributeID
			  ,IsDeleted
	          ,[CreatedBy] 
	          ,[CreatedDate] 
	          ,[ModifiedBy]
	          ,[ModifiedDate]
			  )
			   values
			   ( 
			      @ProjectID
			     ,Temp.AttributeValueID           
				 ,Temp.AttributeID	
				 ,0
				 ,@EmployeeID 
				 ,getdate() 
				 ,null
			     ,null
				 
				 );

		--Inserts the Attribute values >End<

		--Inserts the 'Others' Attribute values >Start<
		
	UPDATE  PP.OtherAttributeValues  SET 
    ModifiedBy                 = @EmployeeID,  
    ModifiedDate               = getdate(),  
    IsDeleted     =1  where AttributeValueID in (198,242) and ProjectID = @ProjectID;
     
	MERGE PP.OtherAttributeValues OA   
    using @BPOtherAttributeValues AS Temp   
    ON OA.ProjectID = @ProjectID  and OA.AttributeValueID = Temp.AttributeValueID 
    WHEN matched THEN   
      UPDATE SET 
	 OA.AttributeValueID           = Temp.AttributeValueID,  
	 OA.OtherFieldValue			=Temp.OtherFieldValue,
     OA.ModifiedBy                 = @EmployeeID,  
     OA.ModifiedDate               = getdate(),  
     OA.IsDeleted     =0  
    WHEN NOT matched THEN   
      INSERT 
	  (   
		  ProjectID,
		  AttributeValueID  ,
		  OtherFieldValue  ,
		  IsDeleted  ,
		  CreatedBy ,  
		  CreatedDate ,
		  ModifiedBy,
		  ModifiedDate 
	  )  
      values  
      (   
         @ProjectID ,
		 Temp.AttributeValueID,
		 Temp.OtherFieldValue,
		 0,  
		 @EmployeeID ,
		 getdate(),
		 null,
		 null  
      );
			--Inserts the 'Others' Attribute values >End<

UPDATE PP.ScopeOfWork SET IsSubmit=1 where ProjectID=@ProjectID



			SET @Result = 1
			Select @Result as Result

			EXEC [PP].[ProjectAttributeBasedOnCloudService] @ProjectID,NULL,@EmployeeID
		COMMIT TRAN
	END TRY 

    BEGIN CATCH 
		SET @Result = 0
		Select @Result as Result
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[SaveBestPracticeDetail]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
