/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [dbo].[GetTicketInfoDetails]
@ProjectId int,
@TicketID nvarchar(50),
@supportTypeID int
as
begin
SET NOCOUNT ON;
BEGIN TRY
DECLARE @Ticket nvarchar(50);
SET @Ticket =  LTRIM(RTRIM(REPLACE(REPLACE(@TicketID, CHAR(9), CHAR(160)), CHAR(160), '')))
if(@supportTypeID=1)
begin

 IF EXISTS (SELECT
		1
	FROM [AVL].[TK_TRN_TicketDetail](NOLOCK)
	WHERE ProjectID = @ProjectId
	AND LTRIM(RTRIM(REPLACE(REPLACE(TicketID, CHAR(9), CHAR(160)), CHAR(160), ''))) = @Ticket
	AND IsDeleted = 0) BEGIN
SELECT
	'1' AS TicketID
END ELSE BEGIN
SELECT
	'0' AS TicketID
END
END
ELSE if @supportTypeID=2

BEGIN

 IF EXISTS (SELECT 1 FROM [AVL].TK_TRN_InfraTicketDetail(NOLOCK)
	WHERE ProjectID = @ProjectId
	AND LTRIM(RTRIM(REPLACE(REPLACE(TicketID, CHAR(9), CHAR(160)), CHAR(160), ''))) = @Ticket
	AND IsDeleted = 0) 
	BEGIN
			SELECT '1' AS TicketID
	END 
ELSE 
BEGIN
		    SELECT '0' AS TicketID
END

END

END TRY 

BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

--INSERT Error    
EXEC AVL_InsertError	'[dbo].[GetTicketInfoDetails] '
						,@ErrorMessage
						,@ProjectId
						,0

END CATCH

SET NOCOUNT OFF;

END
