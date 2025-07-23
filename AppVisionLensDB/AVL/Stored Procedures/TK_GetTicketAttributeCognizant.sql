/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TK_GetTicketAttributeCognizant]  
@ProjectId BIGINT,  
@serviceid INT,  
@DARTStatusID INT,  
@TicketStatusID BIGINT,  
@TicketTypeID bigint=0  
      
AS   
BEGIN  
SET NOCOUNT ON;   
BEGIN TRY  
DECLARE @TicketAttributeIntegration CHAR  
DECLARE @FlexField1Name NVARCHAR(100)='Flex Field (1)'  
DECLARE @FlexField2Name NVARCHAR(100)='Flex Field (2)'  
DECLARE @FlexField3Name NVARCHAR(100)='Flex Field (3)'  
DECLARE @FlexField4Name NVARCHAR(100)='Flex Field (4)'  
set @TicketAttributeIntegration = (SELECT ISNULL(IsMainSpringConfigured,'N') as Config from AVL.MAS_ProjectMaster (NOLOCK)   
         WHERE ProjectID = @ProjectId)  
  
SET @DARTStatusID=(SELECT TicketStatus_ID FROM AVL.TK_MAP_ProjectStatusMapping(NOLOCK)   
     WHERE ProjectID=@ProjectId AND IsDeleted=0  
     AND StatusID=@TicketStatusID)  
CREATE TABLE #AttributeTemp  
(  
AttributeName NVARCHAR(1000) NULL,  
ColumnMappingName NVARCHAR(1000) NULL,  
AttributeType NVARCHAR(10) NULL  
)  
  
 IF(@TicketAttributeIntegration = 'Y')  
  BEGIN  
   IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK)   
   WHERE Projectid = @ProjectId and IsDeleted = 0)   
    BEGIN  
     INSERT INTO #AttributeTemp  
     SELECT  
     D.AttributeName,  
     D.AttributeName AS ColumnMappingName,   
     ISNULL(AM.AttributeType,'M') AS AttributeType  
     FROM AVL.MAS_MainspringAttributeStatusMaster D (NOLOCK)   
     LEFT JOIN AVL.MAS_AttributeMaster AM (NOLOCK) ON D.AttributeID=AM.AttributeID    
     WHERE D.ServiceID=@serviceid AND D.StatusID=@DARTStatusID  
      AND D.IsDeleted= 0  AND D.FieldType='M' AND AM.IsDeleted=0  
    END   
  ELSE  
   BEGIN   
  
    INSERT INTO #AttributeTemp   
    SELECT   
     D.AttributeName,   
     D.AttributeName AS ColumnMappingName,   
     ISNULL(AM.AttributeType,'M') AS AttributeType  
     FROM AVL.PRJ_MainspringAttributeProjectStatusMaster D (NOLOCK)   
     LEFT JOIN AVL.MAS_AttributeMaster AM (NOLOCK) ON D.AttributeID=AM.AttributeID  
     WHERE D.ProjectID = @ProjectId AND D.ServiceID=@serviceid   
     AND D.StatusID=@DARTStatusID AND D.IsDeleted= 0  AND D.FieldType='M' AND AM.IsDeleted=0  
   END   
  
 END  
  
ELSE  
 BEGIN   
  IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_StandardAttributeProjectStatusMaster (NOLOCK)   
     WHERE Projectid = @ProjectId and IsDeleted = 0)   
   BEGIN  
    INSERT INTO #AttributeTemp   
     SELECT   
     D.AttributeName,   
     D.AttributeName AS ColumnMappingName,   
     ISNULL(AM.AttributeType,'M') AS AttributeType  
     FROM AVL.MAS_StandardAttributeStatusMaster D (NOLOCK)   
     LEFT JOIN AVL.MAS_AttributeMaster AM ON D.AttributeID=AM.AttributeID  
     WHERE  D.ServiceID=@serviceid AND D.StatusID=@DARTStatusID AND D.FieldType='M'  
     AND D.IsDeleted= 0 AND AM.IsDeleted =0  
       
   END  
  ELSE  
   BEGIN  
    INSERT INTO #AttributeTemp   
     SELECT   
     D.AttributeName,   
     D.AttributeName AS ColumnMappingName,   
     ISNULL(AM.AttributeType,'M') AS AttributeType  
     FROM AVL.PRJ_StandardAttributeProjectStatusMaster D (NOLOCK)   
     LEFT JOIN AVL.MAS_AttributeMaster AM (NOLOCK) ON D.AttributeID=AM.AttributeID  
     WHERE D.Projectid=@ProjectId  AND D.ServiceID=@serviceid AND D.StatusID=@DARTStatusID  
     AND D.FieldType='M'  AND D.IsDeleted=0 AND AM.IsDeleted=0  
  
   END  
 END  
 SELECT ColumnID INTO #Temp FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK)   
 WHERE ProjectID=@ProjectId AND IsActive=1  
  
 DECLARE @FlexField1 NVARCHAR(20);  
 DECLARE @FlexField2 NVARCHAR(20);  
 DECLARE @FlexField3 NVARCHAR(20);  
 DECLARE @FlexField4 NVARCHAR(20);  
  
 SET @FlexField1=(SELECT TOP 1 AttributeName FROM #AttributeTemp (NOLOCK) WHERE AttributeName=@FlexField1Name)  
 SET @FlexField2=(SELECT TOP 1 AttributeName FROM #AttributeTemp (NOLOCK) WHERE AttributeName=@FlexField2Name)  
 SET @FlexField3=(SELECT TOP 1 AttributeName FROM #AttributeTemp (NOLOCK) WHERE AttributeName=@FlexField3Name)  
 SET @FlexField4=(SELECT TOP 1 AttributeName FROM #AttributeTemp (NOLOCK) WHERE AttributeName=@FlexField4Name)  
  
 IF(@serviceid in (1,4,5,6,7,8,10))  
  BEGIN  
  DECLARE @OptionalAttrType INT  
  SELECT @OptionalAttrType=OptionalAttributeType FROM AVL.MAS_ProjectDebtDetails (NOLOCK) Where ProjectID=@ProjectId AND IsDeleted<>1  
  IF EXISTS (SELECT ColumnID FROM #Temp (NOLOCK) WHERE ColumnID =11 AND (@DARTStatusID=8 or @DARTStatusID=9 )AND @FlexField1 IS NULL AND (@OptionalAttrType=1 OR @OptionalAttrType=3))  
   BEGIN  
    INSERT INTO #AttributeTemp  
    SELECT @FlexField1Name AS AttributeName,NULL,'M' AS AttributeType  
   END  
  IF EXISTS (SELECT ColumnID FROM #Temp (NOLOCK) WHERE ColumnID =12 AND (@DARTStatusID=8 or @DARTStatusID=9 ) AND @FlexField2 IS NULL AND (@OptionalAttrType=1 OR @OptionalAttrType=3))  
  BEGIN  
   INSERT INTO #AttributeTemp  
   SELECT @FlexField2Name AS AttributeName,NULL,'M' AS AttributeType  
  END  
  IF EXISTS (SELECT ColumnID FROM #Temp (NOLOCK) WHERE ColumnID =13 AND (@DARTStatusID=8 or @DARTStatusID=9 ) AND @FlexField3 IS NULL AND (@OptionalAttrType=1 OR @OptionalAttrType=3))  
  BEGIN  
   INSERT INTO #AttributeTemp  
   SELECT @FlexField3Name AS AttributeName,NULL,'M' AS AttributeType  
  END  
  IF EXISTS (SELECT ColumnID FROM #Temp (NOLOCK) WHERE ColumnID =14 AND (@DARTStatusID=8 or @DARTStatusID=9 ) AND @FlexField4 IS NULL AND (@OptionalAttrType=1 OR @OptionalAttrType=3))  
  BEGIN  
   INSERT INTO #AttributeTemp  
   SELECT @FlexField4Name AS AttributeName,NULL,'M' AS AttributeType  
  END  
  IF EXISTS (SELECT IsAutoClassified From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassified='Y'   
     and ProjectID=@ProjectId AND IsDeleted=0 AND @DARTStatusID=8)  
  BEGIN  
    IF  EXISTS ( SELECT TOP 1 IsOptionalField FROM ML.ConfigurationProgress(NOLOCK)   
       where ProjectId=@ProjectId AND IsDeleted=0 AND IsOptionalField = 1)   
       BEGIN  
        INSERT INTO #AttributeTemp  
        SELECT 'Resolution Method' AS AttributeName,'Resolution Method' AS ColumnMappingName,'M' AS AttributeType  
       END  
   INSERT INTO #AttributeTemp  
   SELECT 'Ticket Description' AS AttributeName,'Ticket Description' AS ColumnMappingName,'M' AS AttributeType  
  END  
 END  
  
 UPDATE A  
 SET A.ColumnMappingName = B.ProjectColumn  
 FROM #AttributeTemp A,  
 AVL.ITSM_PRJ_SSISColumnMapping B  
 WHERE B.ProjectID = @ProjectId AND A.AttributeName = B.ServiceDartColumn   
 AND B.ServiceDartColumn IN (@FlexField1Name,@FlexField2Name,@FlexField3Name,@FlexField4Name) AND IsDeleted = 0  
  
 UPDATE #AttributeTemp SET ColumnMappingName=AttributeName  
 WHERE ColumnMappingName IS NULL AND AttributeName IN(@FlexField1Name,@FlexField2Name,  
               @FlexField3Name,@FlexField4Name)  
  
  
 SELECT @serviceid AS ServiceID, AttributeName,ColumnMappingName,@TicketStatusID AS ProjectStatusID,  
 @ProjectId AS ProjectID,@DARTStatusID AS DARTStatusID,AttributeType   
 FROM  #AttributeTemp (NOLOCK)     
  
 --DROP TABLE IF EXISTS  #Temp  
 --DROP TABLE IF EXISTS #AttributeTemp  
  
 IF OBJECT_ID('tempdb..#Temp', 'U') IS NOT NULL  
 BEGIN  
  DROP TABLE #Temp  
 END  
  
 IF OBJECT_ID('tempdb..#AttributeTemp', 'U') IS NOT NULL  
 BEGIN  
  DROP TABLE #AttributeTemp  
 END  

END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()   
  EXEC AVL_InsertError '[AVL].[TK_GetTicketAttributeCognizant]', @ErrorMessage, @ProjectId,0  
    
 END CATCH   
SET NOCOUNT OFF;    
END
