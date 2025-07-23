/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[SaveItsmPercentageinTileProgress] 
(      
  @CustomerId BIGINT NULL,      
  @ProjectID  BIGINT,      
  @EmployeeID VARCHAR(50)      
)      
As      
BEGIN      
  
 SET NOCOUNT ON    
  
 BEGIN TRY     
  
  DECLARE @ItsmTileID		INT = 9
  DECLARE @ItsmPercentage   INT = 0      
      
  SET @ItsmPercentage = dbo.GetItsmPercentage(@ProjectID)    
  SET @ItsmPercentage = CASE WHEN ISNULL(@ItsmPercentage, CAST(0 AS INT)) > 100 THEN 100 ELSE ISNULL(@ItsmPercentage, CAST(0 AS INT)) END    
      
  -- Save ITSM 
  EXEC [PP].[SaveProjectProfilingTileProgress] @ProjectID, @ItsmTileID, @ItsmPercentage, @EmployeeID
    
 END TRY    
 BEGIN CATCH    
      
	DECLARE @ErrorMessage VARCHAR(MAX);    
	SELECT @ErrorMessage = ERROR_MESSAGE()  
   
   EXEC AVL_InsertError '[PP].[SaveItsmPercentageinTileProgress]',     
@ErrorMessage, @EmployeeID ,@ProjectID   
	--EXEC AVL_InsertError 'PP.SaveItsmPercentageinTileProgress', @ErrorMessage, 0 , ''  
   
  END CATCH    

END
