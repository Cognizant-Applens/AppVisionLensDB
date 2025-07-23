/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[InsertTicketsinTicketSource]
-- Add the parameters for the stored procedure here
@ProjectID BIGINT,
@RegexConfigID BIGINT,
@JobStatusID BIGINT,
@UserID nvarchar(50),
@IsUpdate BIT,
@DescriptionJsonData NVARCHAR(MAX)	

AS
BEGIN
BEGIN TRY  
BEGIN TRAN
DECLARE @IsDecryptionRequired BIT = 0;
DECLARE @RegexFieldValue INT;
IF(@IsUpdate = 0)
BEGIN
INSERT INTO AVL.Regex_TicketSource(RegexJobStatusID,ProjectID,TicketID,RegexField,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
SELECT @JobStatusID,RC.ProjectID,TD.TicketID,
CASE WHEN RC.RegexFieldID = 11 THEN TD.TicketDescription 
WHEN RC.RegexFieldID = 12 THEN TD.ResolutionRemarks
WHEN RC.RegexFieldID = 13 THEN TD.TicketSummary
WHEN RC.RegexFieldID = 14 THEN TD.Comments
ELSE ''
END AS RegexField,
0,
@UserID,
GETDATE(),
null,
null
FROM AVL.PRJ_RegexConfiguration RC JOIN 
avl.TK_TRN_ticketdetail TD ON RC.projectid = TD.projectid AND TD.DartStatusID = 8 -- AND @SupportTypeID IN (1,3)
JOIN [AVL].[MAP_ProjectConfig] PC ON RC.projectID = PC.ProjectID AND PC.supporttypeid in (1,3)
AND TD.ClosedDate BETWEEN RC.EffectiveStartDate and RC.EffectiveEndDate AND RC.RegexConfigID = @RegexConfigID
UNION
SELECT @JobStatusID,RC.ProjectID,ITD.TicketID,
CASE WHEN RC.RegexFieldID = 11 THEN ITD.TicketDescription 
WHEN RC.RegexFieldID = 12 THEN ITD.ResolutionRemarks
WHEN RC.RegexFieldID = 13 THEN ITD.TicketSummary
WHEN RC.RegexFieldID = 14 THEN ITD.Comments
ELSE ''
END AS RegexField,
0,
@UserID,
GETDATE(),
null,
null
FROM AVL.PRJ_RegexConfiguration RC JOIN avl.TK_TRN_InfraTicketDetail
 ITD ON RC.projectid = ITD.projectid AND ITD.DartStatusID = 8  --AND @SupportTypeID IN (2,3)
 JOIN [AVL].[MAP_ProjectConfig] PC ON RC.projectID = PC.ProjectID AND PC.supporttypeid in (2,3)
AND ITD.ClosedDate BETWEEN RC.EffectiveStartDate and RC.EffectiveEndDate AND RC.RegexConfigID = @RegexConfigID

SELECT @RegexFieldValue =RegexFieldID FROM AVL.PRJ_RegexConfiguration WHERE RegexConfigID = @RegexConfigID

IF(@RegexFieldValue = 11 OR @RegexFieldValue = 13)
BEGIN
SET @IsDecryptionRequired = 1

END
SELECT @IsDecryptionRequired;
SELECT ID,TicketID,RegexField FROM AVL.Regex_TicketSource where RegexJobStatusID = @JobStatusID
END
IF(@IsUpdate = 1)
BEGIN

CREATE TABLE #TEMPDESCRIPTION
			(
				TicketID NVARCHAR(MAX),				
				RegexField NVARCHAR(max)
			)

INSERT INTO #TEMPDESCRIPTION(TicketID,RegexField)
SELECT TicketID,RegexField  FROM OPENJSON(@DescriptionJsonData)
WITH(TicketID NVARCHAR(MAX) '$.TicketID',
RegexField NVARCHAR(MAX) '$.RegexField') AS JSONVALUES

UPDATE TS  SET TS.RegexField = TD.RegexField
FROM AVL.Regex_TicketSource TS JOIN  #TEMPDESCRIPTION TD
ON TS.TicketID = TD.TicketID AND TS.ProjectID = @ProjectID

DROP TABLE #TEMPDESCRIPTION;
SELECT 1;
END
			
		COMMIT TRAN
	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[InsertTicketsinTicketSource]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
