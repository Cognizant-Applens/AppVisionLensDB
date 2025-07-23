/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetTranslatedfieldsforMLAPI] 
	@projectID int,	
	@add_text  nvarchar(max)=null,
	@TimeTickerID nvarchar(100)  
AS
BEGIN
		BEGIN TRY
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT IsMultilingualEnabled FROM AVL.MAS_ProjectMaster WHERE ProjectID=@projectID AND IsDeleted=0 AND IsMultilingualEnabled=1)
	BEGIN	

	DECLARE @translatedTicketDescription nvarchar(200)
	DECLARE @translatedadd_text nvarchar(200)

	IF EXISTS (SELECT 1 FROM AVL.PRJ_MultilingualColumnMapping WHERE ProjectID=@projectID AND ColumnID=1 AND IsActive=1)
	BEGIN
	SET @translatedTicketDescription=(SELECT DISTINCT TicketDescription FROM AVL.TK_TRN_Multilingual_TranslatedTicketDetails WHERE TimeTickerID=@TimeTickerID AND Isdeleted=0 )
	END
	ELSE 
	SET @translatedTicketDescription=''


	
	IF (@add_text ='Resolution Remarks')
	BEGIN
	IF EXISTS (SELECT 1 FROM AVL.PRJ_MultilingualColumnMapping WHERE ProjectID=@projectID AND ColumnID=3 AND IsActive=1)
	BEGIN
	SET @translatedadd_text=(SELECT DISTINCT ResolutionRemarks FROM AVL.TK_TRN_Multilingual_TranslatedTicketDetails WHERE TimeTickerID=@TimeTickerID AND Isdeleted=0 )
	END
	else
	SET @translatedadd_text=''
	END

	ELSE
	SET @translatedadd_text=''

	SELECT ISNULL(@translatedTicketDescription,'Not translated') AS TicketDescription,isNULL(@translatedadd_text,'Not translated') AS add_text,'Enabled' AS IsMultilingualEnabled
	END
	ELSE 
	SELECT 'Not Enabled' AS IsMultilingualEnabled
   
   END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetTranslatedfieldsforMLAPI]', @ErrorMessage, @projectID,0
		
	END CATCH 
END
