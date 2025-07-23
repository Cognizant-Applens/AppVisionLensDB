/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [CS].[InsertOpportunity]
										 (@OpportunityName Nvarchar(250),  
                                          @OpportunityType	Nvarchar(10),  
                                          @NoOfTeams	Int,  
                                          @AssociatesPerTeam	Int,  
                                          @ESAProjectId	NVARCHAR(15),  
										  @Description	Nvarchar(1000),  
                                          @NominationCloseOn	Datetime,  
                                          @OppStartDate	Datetime, 
										  @OppEndDate	Datetime,  
                                          @Tags VARCHAR(250),
										  @TechStack NVARCHAR(MAX),
									      @UploadDocument	Nvarchar(256), 
										  @StatusId	Int,  
                                          @NoOfBids	Int,  
										  @CreatedBy Nvarchar(15)
										  )
AS   
BEGIN
SET NOCOUNT ON;
BEGIN TRY


Declare @tagstring VARCHAR(250)
DECLARE @TechStackAllvalue NVARCHAR(MAX)
Declare @OpportunityID BIGINT;
          
            INSERT INTO CS.Opportunity  
                        (OpportunityName,  
                         OpportunityType,  
                         NoOfTeams,  
                         AssociatesPerTeam, 
						 ESAProjectId,
						 Description,
						 NominationCloseOn,
						 OppStartDate,
						 OppEndDate,
						 UploadDocument,
						 StatusId,
						 NoOfBids,
						 CreatedBy,
						 CreatedDate,
						 IsDeleted)  
            VALUES     ( @OpportunityName,  
                        @OpportunityType,  
                        @NoOfTeams	,  
                        @AssociatesPerTeam	,  
                        @ESAProjectId	,  
                        @Description	,  
                        @NominationCloseOn	,  
                        @OppStartDate	, 
                        @OppEndDate	,  
                        @UploadDocument	, 
                        1	,  
                        0,
                        @CreatedBy,
                        GETDATE(),
						0
                        )  
			SELECT @OpportunityID = SCOPE_IDENTITY()
			
			INSERT INTO CS.TagOpportunity (OpportunityID,  
										Tag,  
										CreatedBy,
										CreatedDate) 
			SELECT @OpportunityID, CAST(Item AS nvarchar) , @CreatedBy,GETDATE() 
			FROM  dbo.Split(@Tags, ',');  
						
if CHARINDEX(',0',@TechStack) > 0
BEGIN
SET @TechStackAllvalue=(select rtrim(substring(@TechStack,1, charindex(',0', @TechStack)-1)))
INSERT INTO CS.TechStackOpportunity(OpportunityID,  
										TechStack,  
										CreatedBy,
									CreatedDate)
 SELECT @OpportunityID, Item , @CreatedBy,GETDATE() 
			FROM  dbo.Split(@TechStackAllvalue, ',') ;
			SELECT @OpportunityID AS 'Result';
END
	ELSE
	BEGIN
	INSERT INTO CS.TechStackOpportunity(OpportunityID,  
										TechStack,  
										CreatedBy,
									CreatedDate)
 SELECT @OpportunityID, Item , @CreatedBy,GETDATE() 
			FROM  dbo.Split(@TechStack, ',') ;
			SELECT @OpportunityID AS 'Result';
	END
	
	 END TRY
	 BEGIN CATCH
	  DECLARE @ErrorMessage VARCHAR(MAX); 
      SELECT @ErrorMessage = ERROR_MESSAGE() 
	  EXEC [CS].[InsertErrorLog]  '[CS].[InsertOpportunity]', @ErrorMessage,  0 
	 END CATCH
END;
