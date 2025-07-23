/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetKARatingDetails]  
(  
	@KATicketID NVARCHAR(1000)
)
AS
BEGIN	

    BEGIN TRY
	SET NOCOUNT ON;
	
	DECLARE @KAIds TABLE(KAId BIGINT)
	
	INSERT INTO @KAIds
     SELECT Item  FROM dbo.Split((@KATicketID),',')

   
	SELECT KA_R.KAID,Sum(rating) TotalRating,Count(rating) RatingCount 
	  FROM AVL.KEDB_TRN_KARating_MapTicketId KA_R
		JOIN @KAIds temp_KA on KA_R.KAID=temp_KA.KAId GROUP BY KA_R.KAID

	 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	   
		EXEC AVL_InsertError '[AVL].[KEDB_GetKARatingDetails]', @ErrorMessage,'',''
		RETURN @ErrorMessage
  END CATCH   
END
