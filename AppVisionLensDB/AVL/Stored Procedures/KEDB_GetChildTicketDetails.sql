/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetChildTicketDetails] 
  (	      
    @ProjectID BIGINT  ,
	@HealingTicketID NVARCHAR(100),
	@UserId NVARCHAR(50)
  )
AS
BEGIN  
BEGIN TRY 
  SET NOCOUNT ON;
   
   SELECT distinct TTD.Ticketid,TTD.TicketDescription,TTD.EffortTillDate,TTD.ResolutionRemarks,
   TTD.CreatedDate as MappedDate  FROM [AVL].[TK_TRN_TicketDetail] TTD   
   INNER JOIN [AVL].[DEBT_PRJ_HealParentChild]   HPC (NOLOCK) ON 
	 HPC.DARTTicketID = TTD.TicketID  
   INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD (NOLOCK) ON
     HTD.ProjectPatternMapID = HPC.ProjectPatternMapID
   INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM (NOLOCK) ON
     HPPM.ProjectPatternMapID = HTD.ProjectPatternMapID
     WHERE HTD.HealingTicketID = @HealingTicketID and TTD.ProjectID = @ProjectID 
	AND HPPM.ProjectID = @ProjectID AND TTD.IsDeleted=0 AND HPC.IsDeleted=0 AND HPC.MapStatus=1
     

		 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[KEDB_GetChildTicketDetails] ', @ErrorMessage,@UserId,@ProjectID
		RETURN @ErrorMessage
  END CATCH   
END
