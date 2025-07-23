/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/****** Object:  StoredProcedure [CS].[DeleteOpportunity]    Script Date: 7/9/2020 8:15:50 PM ******/
-- =============================================
-- Author:		<Amsaveni>
-- Create date: <07/06/2020>
-- Description:	<To softt delete opportunity>
-- =============================================
CREATE PROCEDURE [CS].[DeleteOpportunity]
	-- Add the parameters for the stored procedure here
	 @OpportunityID Int,
	 @ModifiedBy Nvarchar(10)
AS
BEGIN
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        BEGIN  
            UPDATE CS.Opportunity  
            SET    IsDeleted = 1,  
				   ModifiedBy = @ModifiedBy,	
                   ModifiedDate = GETDATE()
            WHERE  OpportunityID = @OpportunityID;  
        END  		

	 END TRY
	  BEGIN CATCH
	  DECLARE @ErrorMessage VARCHAR(MAX); 
      SELECT @ErrorMessage = ERROR_MESSAGE() 
	  EXEC [CS].[InsertErrorLog]  '[CS].[DeleteOpportunity]', @ErrorMessage,  0 
	 END CATCH
	 END;
