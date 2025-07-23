/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[GetDebtConfiguration] @ProjectID bigint
as
Begin
select isdebtenabled,CM.ServiceDartColumn from AVL.MAS_ProjectMaster(nolock) PM  
 JOIN AVL.ITSM_PRJ_SSISColumnMapping CM on cm.ProjectID=pm.ProjectID
where PM.ProjectID=@ProjectID and cm.IsDeleted=0 and pm.IsDeleted=0 and (cm.ServiceDartColumn LIKE '%Resolution Code%' or 
cm.ServiceDartColumn LIKE '%Cause Code%' OR
cm.ServiceDartColumn LIKE '%Debt Classification%' OR
cm.ServiceDartColumn LIKE '%Avoidable Flag%' OR
cm.ServiceDartColumn LIKE '%Residual Debt%')
End
