/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [CS].[GetMyOpportunityDetails](@Text Nvarchar(100),
											 @UserId Nvarchar(50),
                                             @PageNo int,
											 @RecordsPerPage int)
    -- Add the parameters for the stored procedure here
AS

BEGIN
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
        -- Insert statements for procedure here

	select distinct OP.OpportunityId, OpportunityName,OpportunityType,NoOfTeams,AssociatesPerTeam,ESAProjectId,    
	OP.Description,NominationCloseOn,OppStartDate,OppEndDate,
	    STUFF((
       SELECT DISTINCT ', ' + CAST(TA1.Tag AS VARCHAR(MAX))
       FROM CS.TagOpportunity TA1  
       WHERE TA1.OpportunityID =OP.OpportunityID  
       FOR XML PATH('')
     ),1,1,'') as Tags,
     STUFF((
       SELECT DISTINCT ', ' + CAST(TS1.TechStack AS VARCHAR(MAX))  
       FROM CS.TechStackOpportunity TS1  
       where TS1.OpportunityID =OP.OpportunityID   
       FOR XML PATH('')
     ),1,1,'') as TechStack,UploadDocument,OP.StatusID,
	LO.Description as Status, NoOfBids,(select count(OpportunityID) from  CS.Opportunity where CreatedBy=@UserId and ISDeleted=0 and OpportunityName like '%'+ @Text +'%') as TotalItems ,
	case when getdate()<=NominationCloseOn then 'Open' else 'Closed' end as NominationStatus
	from  CS.Opportunity OP
	inner join CS.LookUp LO on OP.StatusId=LO.ID
	where OP.CreatedBy=@UserId and OP.ISDeleted=0 
	and OP.OpportunityName like '%'+ @Text +'%'
    order by OP.OpportunityID desc
    OFFSET (@PageNo-1)*@RecordsPerPage ROWS
    FETCH NEXT @RecordsPerPage ROWS ONLY
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		EXEC [CS].[InsertErrorLog]  '[CS].[GetMyOpportunityDetails]', @ErrorMessage,  0
END CATCH
END
