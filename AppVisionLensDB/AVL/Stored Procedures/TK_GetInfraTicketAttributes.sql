/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================------  
-- Author    :    Dhivya Bharathi M    
--  Create date:    June 24 2019     
-- ============================================================================  

CREATE PROCEDURE [AVL].[TK_GetInfraTicketAttributes]  
@ProjectId BIGINT,  
@DARTStatusID INT,  
@TicketStatusID BIGINT  
  
AS   
BEGIN   
BEGIN TRY  
SET NOCOUNT ON;  
  
CREATE TABLE #AttributeTemp  
(  
AttributeName NVARCHAR(1000) NULL,  
ColumnMappingName NVARCHAR(1000) NULL,  
AttributeType NVARCHAR(10) NULL  
)  
  
DECLARE @IsDebtEnabled NVARCHAR(10)  
SET @DARTStatusID=(SELECT TicketStatus_ID FROM AVL.TK_MAP_ProjectStatusMapping(NOLOCK)   
                                  WHERE ProjectID=@ProjectId AND IsDeleted=0  
                                  AND StatusID=@TicketStatusID)  
set @IsDebtEnabled=(select TOP 1 IsDebtEnabled from AVL.MAS_ProjectMaster where ProjectID=@ProjectId   
     AND IsDeleted= 0 )  
IF(@IsDebtEnabled='Y')  
       BEGIN  
          INSERT INTO #AttributeTemp  
                                  SELECT  
                                  A.AttributeName,  
                                  A.AttributeName AS ColumnMappingName,   
                                  ISNULL(B.AttributeType,'M') AS AttributeType  
                                  FROM [AVL].[MAS_InfraAttributeStatusMaster] A (NOLOCK)   
                                  LEFT JOIN AVL.MAS_AttributeMaster B ON A.AttributeID=B.AttributeID    
                                  WHERE A.StatusID=@DARTStatusID  
                                  AND A.IsDeleted= 0  AND A.DebtFieldType='M'  
                           END      
              ELSE  
                     BEGIN    
                   INSERT INTO #AttributeTemp  
                                  SELECT  
                                  A.AttributeName,  
                                  A.AttributeName AS ColumnMappingName,   
                                  ISNULL(B.AttributeType,'M') AS AttributeType  
                                  FROM [AVL].[MAS_InfraAttributeStatusMaster] A (NOLOCK)   
                                  LEFT JOIN AVL.MAS_AttributeMaster B ON A.AttributeID=B.AttributeID    
                                  WHERE A.StatusID=@DARTStatusID  
                                  AND A.IsDeleted= 0  AND A.StandardFieldType='M'  
                     END      
  
IF EXISTS (SELECT IsAutoClassifiedInfra From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassifiedInfra='Y'   
   and ProjectID=@ProjectId AND IsDeleted=0 AND @DARTStatusID=8)  
BEGIN  

IF  EXISTS ( SELECT TOP 1 IsOptionalField FROM ML.InfraConfigurationProgress(NOLOCK)   
       where ProjectId=@ProjectId AND IsDeleted=0 AND IsOptionalField = 1)   
       BEGIN  
        INSERT INTO #AttributeTemp  
        SELECT 'Resolution Method' AS AttributeName,'Resolution Method' AS ColumnMappingName,'M' AS AttributeType  
       END  
	   INSERT INTO #AttributeTemp  
   SELECT 'Ticket Description' AS AttributeName,'Ticket Description' AS ColumnMappingName,'M' AS AttributeType  
END  
  
SELECT AttributeName,ColumnMappingName,AttributeType FROM #AttributeTemp  
  
SET NOCOUNT OFF;  
END TRY    
BEGIN CATCH    
  
              DECLARE @ErrorMessage VARCHAR(MAX);  
              SELECT @ErrorMessage = ERROR_MESSAGE()   
              EXEC AVL_InsertError '[AVL].[TK_GetInfraTicketAttributes]', @ErrorMessage, @ProjectId,0  
                
       END CATCH   
END
