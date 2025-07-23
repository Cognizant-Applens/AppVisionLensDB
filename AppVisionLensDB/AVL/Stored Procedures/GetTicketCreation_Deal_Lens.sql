/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetTicketCreation_Deal_Lens] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

	SELECT [Priority_TK_Creation]
      ,[Status_TK_Creation]
      ,[Application_TK_Creation]
      ,[TicketType_TK_Creation]
      ,[ESAProjectID_TK_Creation]
      ,[ProjectName_TK_Creation]
      ,[AccountName_TK_Creation]
	  ,SupportTypeID
	  ,IsSDTicket
  FROM [AVL].[TicketCreation_Deal_Lens] where isdeleted =0
   
END
