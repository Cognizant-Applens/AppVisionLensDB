/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_GetTicketTypeListByProjectID]   
(  
@ProjectID INT,  
@ITSMConfigStatus CHAR,  
@ITSMToolID INT  
)  
  
AS   
  BEGIN  
   SET NOCOUNT ON;
  BEGIN TRY  
  DECLARE @listStr VARCHAR(MAX)  
  SET @listStr = ''  
  IF (NOT EXISTS(SELECT TicketType FROM [AVL].[TK_MAP_TicketTypeMapping] (NOLOCK) WHERE ProjectID=@ProjectID AND  
			(IsDeleted=0 OR IsDeleted IS NULL)) AND @ITSMConfigStatus='A')  
    BEGIN   
    SELECT  0 AS'TicketTypeMappingID',Value AS 'TicketType', NULL AS 'DebtApplicable',NULL AS 'IsDefaultTicketType',  
  NULL AS  AVMTicketType, NULL AS ServiceId  
    FROM [AVL].[MAS_ITSMToolConfiguration] (NOLOCK) 
     WHERE ITSMScreenID=3 AND (IsDeleted=0 OR IsDeleted IS NULL) AND ITSMToolID=@ITSMToolID  
 END  
 ELSE   
    BEGIN   
  
  SELECT   
  TTM.TicketTypeMappingID,  
  TicketType,  
  DebtConsidered AS 'DebtApplicable',  
  IsDefaultTicketType,  
  AVMTicketType,  
  (SELECT STUFF((SELECT ', ' + CAST(ServiceID AS VARCHAR(10)) [text()]  
     FROM AVL.TK_MAP_TicketTypeServiceMapping (NOLOCK)
    WHERE  TicketTypeMappingID = TTM.TicketTypeMappingID AND IsDeleted = 0  
    FOR XML PATH(''), TYPE)  
     .value('.','NVARCHAR(MAX)'),1,2,' ')) AS ServiceId ,  
  TTM.SupportTypeID AS TcktTypeSupportTypeID ,
  NULL as TcktTypeSupportTypeName, NULL as ProjSupportTypeID
  --STM.SupportTypeName AS TcktTypeSupportTypeName,  
  --MPC.SupportTypeId AS ProjSupportTypeID  
  FROM [AVL].[TK_MAP_TicketTypeMapping] TTM (NOLOCK)     
  --INNER JOIN AVL.MAP_ProjectConfig MPC ON MPC.ProjectID = TTM.ProjectID    
  --INNER JOIN  AVL.SupportTypeMaster STM ON MPC.SupportTypeID = STM.SupportTypeId   
  --AND   STM.IsDeleted = 0 AND TTM.IsDeleted = 0   
  WHERE TTM.ProjectID = @ProjectID   AND (TTM.SupportTypeID is not null and TTM.SupportTypeID>0)
  AND (TTM.IsDeleted = 0 OR TTM.IsDeleted IS NULL) AND TicketType NOT IN('A','H','K')  
  ORDER BY TTM.CreatedDateTime DESC  
 END  
   
  END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[dbo].[ITSM_GetTicketTypeListByProjectID] ', @ErrorMessage, @ProjectID,0  
    
 END CATCH    
  SET NOCOUNT ON;
  
  END
