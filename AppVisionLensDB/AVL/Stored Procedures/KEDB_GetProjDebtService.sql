/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetProjDebtService] 
 @projectid INT   
AS     
    BEGIN         
  BEGIN TRY  
 SET NOCOUNT ON;    
 
	  SELECT DISTINCT S.ServiceID,S.ServiceName,ServiceShortName 
	 FROM AVL.TK_PRJ_ProjectServiceActivityMapping PSAM WITH(NOLOCK)  
	JOIN AVL.TK_MAS_ServiceActivityMapping SAM WITH(NOLOCK) ON PSAM.ServiceMapID =SAM.ServiceMappingID  
	JOIN AVL.TK_MAS_Service S WITH(NOLOCK) ON S.ServiceID=SAM.ServiceID 
	WHERE ProjectID=@projectid  AND S.ServiceID <>41 --and S.ServiceID in ( 1, 4,  5,  6, 7, 8, 10) 
	AND PSAM.IsDeleted=0 AND SAM.IsDeleted=0  and s.IsDeleted=0 
    ORDER BY S.ServiceName   
  
END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(4000);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
 
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[KEDB_GetProjDebtService] ', @ErrorMessage, 0 ,@projectid  
    
 END CATCH    
    END
