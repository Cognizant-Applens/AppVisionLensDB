/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TK_GetTicketAttributeCustomer]
@ProjectId BIGINT,
@serviceid INT,
@DARTStatusID INT,
@TicketStatusID BIGINT,
@TicketTypeID bigint=0


WITH RECOMPILE      
AS 
BEGIN 
BEGIN TRY
SET NOCOUNT ON;
DECLARE @IsDebtEnabled VARCHAR(10);
declare @IsDebtConsidered nvarchar(max);
CREATE TABLE #AttributeTemp
(
ServiceID INT NULL,
AttributeName NVARCHAR(1000) NULL,
ColumnMappingName NVARCHAR(1000) NULL,
ProjectStatusID BIGINT NULL,
ProjectID BIGINT NULL,
DARTStatusID INT NULL,
AttributeType NVARCHAR(10) NULL
)

SET @DARTStatusID=(SELECT TicketStatus_ID FROM AVL.TK_MAP_ProjectStatusMapping(NOLOCK) 
					WHERE ProjectID=@ProjectId AND IsDeleted=0
					AND StatusID=@TicketStatusID)
SET @IsDebtEnabled=(SELECT ISNULL(IsDebtEnabled,'N') FROM AVL.MAS_ProjectMaster WHERE ProjectID=@ProjectId AND IsDeleted=0)
set @IsDebtConsidered=(select ISNULL(DebtConsidered,'N') from AVL.TK_MAP_TicketTypeMapping where TicketTypeMappingID=@TicketTypeID)	
		INSERT INTO #AttributeTemp
		SELECT 0 AS ServiceID,AM.AttributeName,AM.AttributeName AS ColumnMappingName,0 AS ProjectStatusID,
		0 AS ProjectID,tm.StatusID AS DARTStatusID,ISNULL(AM.AttributeType,'M') AS AttributeType 
		--INTO #AttributeTemp 
		FROM AVL.MAS_TicketTypeStatusAttributeMaster tm
		inner join  AVL.MAS_AttributeMaster am
		ON TM.AttributeID=AM.AttributeID
		WHERE tm.StatusID=@DARTStatusID AND FieldType='M' and AM.IsDeleted =0


SELECT ColumnID INTO #Temp FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping WHERE ProjectID=@ProjectId
AND IsActive=1

--IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =7 AND @DARTStatusID=8)
--BEGIN
--	INSERT INTO #AttributeTemp
--	SELECT 0 AS ServiceID,'Nature Of The Ticket' AS AttributeName,0 AS ProjectStatusID,
--	0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 
--END
--IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =9 AND @DARTStatusID =8)
--BEGIN
--	INSERT INTO #AttributeTemp
--	SELECT 0 AS ServiceID,'KEDB Path' AttributeName,0 AS ProjectStatusID,
--		0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 
--END
DECLARE @OptionalAttrType INT
SELECT @OptionalAttrType=OptionalAttributeType FROM AVL.MAS_ProjectDebtDetails Where ProjectID=@ProjectId AND IsDeleted<>1
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =11 AND (@DARTStatusID=8 or @DARTStatusID=9 ) AND (@OptionalAttrType=1 OR @OptionalAttrType=3))
BEGIN
	INSERT INTO #AttributeTemp
	SELECT 0 AS ServiceID,'Flex Field (1)' AttributeName,null,0 AS ProjectStatusID,
		0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 
END
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =12 AND (@DARTStatusID=8 or @DARTStatusID=9 ) AND (@OptionalAttrType=1 OR @OptionalAttrType=3))
BEGIN
	INSERT INTO #AttributeTemp
	SELECT 0 AS ServiceID,'Flex Field (2)' AttributeName,null,0 AS ProjectStatusID,
		0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 
END
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =13 AND (@DARTStatusID=8 or @DARTStatusID=9 ) AND (@OptionalAttrType=1 OR @OptionalAttrType=3))
BEGIN
	INSERT INTO #AttributeTemp
	SELECT 0 AS ServiceID,'Flex Field (3)' AttributeName,null,0 AS ProjectStatusID,
		0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 
END
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =14 AND (@DARTStatusID=8 or @DARTStatusID=9 ) AND (@OptionalAttrType=1 OR @OptionalAttrType=3))
BEGIN
	INSERT INTO #AttributeTemp
	SELECT 0 AS ServiceID,'Flex Field (4)' AttributeName,null,0 AS ProjectStatusID,
		0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 
END
IF EXISTS ( SELECT IsAutoClassified From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassified='Y' 
			and ProjectID=@ProjectId AND IsDeleted=0 AND  @IsDebtConsidered='Y' AND @DARTStatusID=8)
BEGIN
	IF  EXISTS ( SELECT TOP 1 IsOptionalField FROM ML.ConfigurationProgress(NOLOCK)
					where ProjectId=@ProjectId AND IsDeleted=0 and IsOptionalField = 1) 
						BEGIN
							INSERT INTO #AttributeTemp
							SELECT 0 AS ServiceID,'Resolution Method' AS AttributeName,'Resolution Method' AS ColumnMappingName,
								0 AS ProjectStatusID,0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 
						END
	INSERT INTO #AttributeTemp
	SELECT 0 AS ServiceID,'Ticket Description' AS AttributeName,'Ticket Description' AS ColumnMappingName,0 AS ProjectStatusID,
		0 AS ProjectID,8 AS DARTStatusID,'M' AS AttributeType 			
END

IF @IsDebtEnabled<> 'Y' or  @IsDebtConsidered<>'Y'
--and @IsDebtConsidered='Y'
BEGIN
		--SELECT * FROM #AttributeTemp
		DELETE FROM #AttributeTemp WHERE AttributeType='D'
		DELETE FROM #AttributeTemp WHERE AttributeName IN('Flex Field (1)','Flex Field (2)','Flex Field (3)','Flex Field (4)')
END
	
	UPDATE A
	SET A.ColumnMappingName = B.ProjectColumn
	FROM #AttributeTemp A,
	AVL.ITSM_PRJ_SSISColumnMapping B
	WHERE A.AttributeName = B.ServiceDartColumn 
	AND B.ProjectID = @ProjectId
	AND B.ServiceDartColumn IN ('Flex Field (1)','Flex Field (2)','Flex Field (3)','Flex Field (4)') AND IsDeleted = 0

	UPDATE #AttributeTemp SET ColumnMappingName=AttributeName
	WHERE ColumnMappingName IS NULL AND AttributeName IN('Flex Field (1)','Flex Field (2)','Flex Field (3)','Flex Field (4)')

	SELECT * FROM #AttributeTemp
	
	DROP TABLE #AttributeTemp	
SET NOCOUNT OFF;
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()




		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetTicketAttributeCustomer]', @ErrorMessage, @ProjectId,0
		
	END CATCH 
END
