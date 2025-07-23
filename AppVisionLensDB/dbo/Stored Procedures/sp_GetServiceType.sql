/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[dbo].[sp_GetServiceType] 2,19100
CREATE PROCEDURE [dbo].[sp_GetServiceType]  
	@ServiceID VARCHAR(MAX) = NULL ,            
    @ProjectID INT =0 
AS   
	BEGIN  --SP BEGIN
BEGIN TRY
BEGIN TRAN
		SET NOCOUNT ON;  
		DECLARE @IsMainspringConfig CHAR;  
			--IF @ProjectID > 0
			--	BEGIN -- IF Projectid>0 Begin
			--		SET @IsMainspringConfig=(SELECT IsMainSpringConfigured FROM AVL.MAS_ProjectMaster   
			--			WHERE ProjectID=@ProjectID)  
			--	  --Mainspring Integration Code  
			--		IF @IsMainspringConfig = 'Y'  
			--			BEGIN  
			--			   SELECT distinct ServiceTypeName  as  ServiceType
			--			   FROM avl.TK_MAS_ServiceTypeMaster 
			--			   WHERE IsDeleted = 0  
			--			   AND ServiceTypeName !='MPS'  
			--			   ORDER BY ServiceTypeName  
	  
			--			END  
			--		 ELSE  
			--			BEGIN  
			--			  SELECT distinct ServiceTypeName  as  ServiceType
			--			  FROM avl.TK_MAS_ServiceTypeMaster   
			--			  WHERE IsDeleted = 0   
			--			  ORDER BY ServiceTypeName  
			--		END  
			--	END -- IF Projectid>0 End
			--ELSE
			--	BEGIN  -- IF Projectid>0  ESLE Begin
			set @IsMainspringConfig = (Select ISNULL(IsMainSpringConfigured,'N') from AVL.MAS_ProjectMaster where ProjectID = @ProjectID)
			
				IF(@IsMainspringConfig = 'Y')
				BEGIN
					  SELECT distinct ServiceTypeName  as  ServiceType   
					  FROM avl.TK_MAS_ServiceType    
					  WHERE IsDeleted = 0   and ServiceTypeName not in ('MPS')
					  ORDER BY ServiceTypeName  
				END
				ELSE
				BEGIN
					  SELECT distinct ServiceTypeName  as  ServiceType   
					  FROM avl.TK_MAS_ServiceType    
					  WHERE IsDeleted = 0  
					  ORDER BY ServiceTypeName  
				END
				--END   -- IF Projectid>0  ESLE End
 
		SET NOCOUNT OFF; 
		COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'dbo.sp_GetServiceType ', @ErrorMessage, 0 ,@ProjectID
		
	END CATCH   
END  --SP END
