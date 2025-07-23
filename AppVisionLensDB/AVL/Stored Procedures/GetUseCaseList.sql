/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetUseCaseList] 
(
@UserID NVARCHAR(50)
)
AS 
BEGIN

BEGIN TRY 
		SET NOCOUNT ON;

		SELECT UC.Id,UC.UseCaseId,UC.UseCaseTitle,UC.BUID,UC.CustomerID,UC.ReferenceID,UC.ApplicationID,UC.TechnologyID,UC.BusinessProcessID,UC.SubBusinessProcessID,
		UC.ServiceID,UC.UseCaseStatusId,
		UC.ToolName,UC.AutomationFeasibility as 'AutomationFeasibility',0 as 'CurrentRate',0 as 'UserRateCount',
		UC.OverAllEffortSpent,
		AD.ApplicationName,
		PT.PrimaryTechnologyName as 'TechnologyName'
			INTO #UCList FROM AVL.UseCaseDetails UC
			LEFT JOIN AVL.APP_MAS_ApplicationDetails AD on UC.ApplicationID=AD.ApplicationID
			LEFT JOIN AVL.APP_MAS_PrimaryTechnology PT on UC.TechnologyID=PT.PrimaryTechnologyID
			
			WHERE UC.CreatedBy=@UserID
		
		SELECT UC.Id,UC.UseCaseId,UC.UseCaseTitle,UC.BUID,UC.CustomerID,cast (UC.ReferenceID as varchar(10)) ReferenceID,UC.ApplicationID,UC.TechnologyID,UC.BusinessProcessID,UC.SubBusinessProcessID,
		UC.ServiceID,UC.UseCaseStatusId,
		UC.ToolName,UC.AutomationFeasibility,UC.CurrentRate,UC.UserRateCount,UC.OverAllEffortSpent,
		ApplicationName,
		TechnologyName,
		x.SupportType,
		y.Tag,
		z.ToolsClassification,
		ToolsClassificationIds.ToolsClassificationId
				FROM #UCList UC
				CROSS APPLY
				(
					SELECT STUFF	(
						( 
							SELECT ',' +sl.ServiceLevelName FROM AVL.UseCaseSolutionTypeDetail ST 
							JOIN AVL.MAS_ServiceLevel sl on st.SolutionTypeID=sl.ServiceLevelID
							WHERE ST.UseCaseDetailId=UC.Id
							FOR XML PATH('') 
						)
					,1,1,'') as SupportType
				) as X
				CROSS APPLY
				(
					SELECT STUFF	(
						( 
							SELECT ',' +ST.Tag FROM AVL.UseCaseTagDetail ST 
							WHERE ST.UseCaseDetailId=UC.Id
							FOR XML PATH('') 
						)
					,1,1,'') as Tag
				) as Y
				CROSS APPLY
				(
					SELECT STUFF	(
						( 
							SELECT ',' +sl.SolutionTypeName FROM AVL.UseCaseServiceLevelDetails ST 
							JOIN AVL.TK_MAS_SolutionType sl on st.ServiceLevelID=sl.SolutionTypeID
							WHERE ST.UseCaseDetailId=UC.Id
							FOR XML PATH('') 
						)
					,1,1,'') as ToolsClassification
				) as Z
				CROSS APPLY
				(
					SELECT STUFF	(
						( 
							SELECT ',' +Convert (nvarchar(50),sl.SolutionTypeID) FROM AVL.UseCaseServiceLevelDetails ST 
							JOIN AVL.TK_MAS_SolutionType sl on st.ServiceLevelID=sl.SolutionTypeID
							WHERE ST.UseCaseDetailId=UC.Id
							FOR XML PATH('') 
						)
					,1,1,'') as ToolsClassificationId
				) as ToolsClassificationIds
				ORDER BY UC.CurrentRate DESC
			DROP TABLE #UCList

END TRY
BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE()   
          EXEC AVL_INSERTERROR 'AVL.GetUseCaseList',  @ErrorMessage,  0 
END CATCH 

END
