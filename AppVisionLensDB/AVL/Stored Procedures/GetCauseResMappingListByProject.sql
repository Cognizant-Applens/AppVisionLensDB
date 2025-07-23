/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetCauseResMappingListByProject]           
    @Projectid INT        
AS         
BEGIN                 
SET NOCOUNT ON;   
select CauseID,DMC.CauseCode,
(SELECT STUFF((SELECT ', ' + CAST(ResolutionCodeMapID AS VARCHAR(10)) [text()]
  			FROM AVL.CauseCodeResolutionCodeMapping(NOLOCK)
			 WHERE  ProjectID=@Projectid AND CauseCodeMapID = DMC.CauseID AND IsDeleted = 0 
				FOR XML PATH(''), TYPE)
					.value('.','NVARCHAR(MAX)'),1,2,' ')) AS ResolutionId

 from AVL.DEBT_MAP_CauseCode(NOLOCK) DMC WHERE DMC.ProjectID=@Projectid
 AND DMC.IsDeleted=0

SET NOCOUNT OFF;    
END
