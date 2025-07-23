/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
      
-- =============================================        
-- Author:  <Gayatri Bauraj>        
-- Create date: <Create Date,,>        
-- Description: <Description,,>        
-- =============================================        
      --exec [AVL].[GetApplicationMappingCount] 7237
CREATE PROCEDURE [AVL].[GetApplicationMappingCount]        
@AccountID int        
        
AS        
BEGIN        
        
 --   Declare @Customer_Id INT    
 --select @Customer_Id = CustomerID from AVL.Customer where ESA_AccountID=@AccountID    
CREATE TABLE #applicationcount        
 (ApplicationCount INT,        
 ActivityId INT,  
 BusinessProcessID bigint,         
 Manual VARCHAR(5)        
  )        
  
INSERT INTO #applicationcount         
SELECT COUNT(ApplicationID),ActivityId,BusinessProcessID,Manual FROM [AVL].[BOM_ActivityMap]     
WHERE AccountID=@AccountID and IsActive=1    
GROUP BY ActivityID,BusinessProcessID,Manual        
      
UPDATE #applicationcount SET ApplicationCount=0 WHERE Manual=1        
        
SELECT appCnt.ActivityID AS 'ActivityID',appCnt.BusinessProcessID ,appCnt.ApplicationCount,        
CASE WHEN appCnt.Manual=1        
THEN        
'true'        
ELSE        
'false'        
END AS 'Manual'        
FROM #applicationcount appCnt   
        
        
        
DROP TABLE #applicationcount        
        
        
END
