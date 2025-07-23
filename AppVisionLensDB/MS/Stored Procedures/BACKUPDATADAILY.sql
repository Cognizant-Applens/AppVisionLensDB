/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
-- EXEC [MS].[BACKUPDATADAILY]

CREATE PROCEDURE [MS].[BACKUPDATADAILY]
AS
BEGIN
BEGIN TRY
     SET NOCOUNT ON
	INSERT INTO [MS].[TRN_ProjectStaging_TillDateBaseMeasure_DAILYDATAPUSH]
	SELECT * FROM MS.TRN_ProjectStaging_TillDateBaseMeasure WITH (NOLOCK)

	TRUNCATE TABLE MS.TRN_ProjectStaging_TillDateBaseMeasure

	INSERT INTO [MS].[TRN_ProjectStaging_TillDateBaseMeasure_DAILYDATAPUSH]
	SELECT * FROM MS.TRN_ProjectStaging_TillDateBaseMeasure_LoadFactor WITH (NOLOCK)


		
	TRUNCATE TABLE MS.TRN_ProjectStaging_TillDateBaseMeasure_LoadFactor

END TRY  
BEGIN CATCH  
		
    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT; 

    SELECT @ErrorMessage = ERROR_MESSAGE()
    SELECT @ErrorSeverity = ERROR_SEVERITY()
    SELECT @ErrorState =  ERROR_STATE()

	--INSERT Error    
	EXEC AVL_InsertError '[MS].[BACKUPDATADAILY]', @ErrorMessage, 0,0
                                
    -- Use RAISERROR inside the CATCH block to return error  
    -- information about the original error that caused  
    -- execution to jump to the CATCH block.  
    RAISERROR (@ErrorMessage, -- Message text.  
                                        @ErrorSeverity, -- Severity.  
                                        @ErrorState -- State.  
                                        );     
                                        
END CATCH
SET NOCOUNT OFF
END



