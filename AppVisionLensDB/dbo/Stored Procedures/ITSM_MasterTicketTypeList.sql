/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_MasterTicketTypeList]
(
@ProjectID INT
)
AS
BEGIN
BEGIN TRY
DECLARE @SupportTypeID AS INT=0;
DECLARE @SupportTypeIDComma AS VARCHAR(50)='';
	SET @SupportTypeID=(SELECT SupportTypeID FROM AVL.MAP_ProjectConfig WHERE ProjectID=@ProjectID)
	IF @SupportTypeID=1 
	BEGIN
	SET @SupportTypeIDComma='1,3';
	END
	ELSE IF @SupportTypeID=2 
	BEGIN
	SET @SupportTypeIDComma='2,3';
	END
	ELSE 
	BEGIN
	SET @SupportTypeIDComma='1,2,3';
	END
	SELECT TicketTypeID,TicketTypeName FROM [AVL].[TK_MAS_TicketType] MTT 
	where IsDeleted=0 AND MTT.TicketTypeID NOT IN (9,10,20) AND MTT.SupportTypeId
	IN (select Item FROm dbo.Split(@SupportTypeIDComma,','))
END TRY
  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_MasterTicketTypeList] ', @ErrorMessage, 0,0
	END CATCH  
END
