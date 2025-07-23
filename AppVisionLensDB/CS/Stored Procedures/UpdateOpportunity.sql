/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/****** Object:  StoredProcedure [CS].[UpdateOpportunity]    Script Date: 7/8/2020 7:42:06 PM ******/
CREATE PROCEDURE [CS].[UpdateOpportunity]
	-- Add the parameters for the stored procedure here
	 @OpportunityID Int,
	 @NominationCloseOn	Datetime,  
     @OppStartDate	Datetime, 
	@OppEndDate	Datetime,  
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
            SET    NominationCloseOn = @NominationCloseOn,  
                   OppStartDate = @OppStartDate,  
                   OppEndDate = @OppEndDate,  
                   ModifiedBy = @ModifiedBy ,
				   ModifiedDate = GETDATE()
            WHERE  OpportunityID = @OpportunityID;  
        END  		

	 END TRY
	  BEGIN CATCH
	  DECLARE @ErrorMessage VARCHAR(MAX); 
      SELECT @ErrorMessage = ERROR_MESSAGE() 
	  EXEC [CS].[InsertErrorLog]  '[CS].[UpdateOpportunity]', @ErrorMessage,  0 
	 END CATCH
	 END;
