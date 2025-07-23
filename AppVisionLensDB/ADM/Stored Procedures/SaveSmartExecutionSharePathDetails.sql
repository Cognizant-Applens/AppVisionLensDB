/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================  
-- Author      :   
-- Create date : 01/03/2021  
-- Description : Procedure to SourceColumn  
-- Revision    :  
-- Revised By  :  
-- =========================================================================================   
CREATE PROCEDURE [ADM].[SaveSmartExecutionSharePathDetails]
(  
 @ProjectId BIGINT,
 @EmployeeId nvarchar(10) NULL,
 @WorkItemDetailsPath nvarchar(200) NULL,
 @IterationOrSprintOrPhaseDetailsPath [nvarchar](200) NULL,
 @ReleaseDetailsPath nvarchar(200) NULL
)  
AS  
BEGIN    
SET NOCOUNT ON;   
BEGIN TRY 
   Declare @IsDeleted int =0

    if exists(SELECT ProjectID from ADM.SmartExecutionSharePathDetails (NOLOCK) where ProjectID=@ProjectId)            
	BEGIN            
	 update ADM.SmartExecutionSharePathDetails set WorkItemDetailsPath=@WorkItemDetailsPath,
       IterationOrSprintOrPhaseDetailsPath=@IterationOrSprintOrPhaseDetailsPath,
       ReleaseDetailsPath=@ReleaseDetailsPath,ModifiedBy=@EmployeeId,ModifiedDate=getdate()
	   where ProjectID=@ProjectId  
	End                    
	else            
	begin  
	 INSERT INTO ADM.SmartExecutionSharePathDetails (      
       ProjectID,
       WorkItemDetailsPath,
       IterationOrSprintOrPhaseDetailsPath,
       ReleaseDetailsPath,
       IsDeleted,
       CreatedBy,
       CreatedDate) VALUES (
	   @ProjectID,
	   @WorkItemDetailsPath,
	   @IterationOrSprintOrPhaseDetailsPath,
	   @ReleaseDetailsPath,
	   @IsDeleted,
	   @EmployeeId,
	   GETDATE()
	   )

	end 
SET NOCOUNT OFF;
END TRY  
BEGIN CATCH        
 DECLARE @ErrorMessage VARCHAR(MAX);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
    
 EXEC AVL_InsertError 'PP.GetALMProgressPercentage', @ErrorMessage, 0 ,''  
    
END CATCH  
  
SET NOCOUNT OFF  
  
END
