/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Proc [dbo].[ITSM_GetITSMName]
@EmployeeId varchar(20)=null
as
begin
	select A.ITSMID as ITSMID ,A.ITSMName as ITSMName  from AVL.MAS_ITSMTools A
	inner join [AVL].[MAS_ProjectMaster] B on B.ITSMID=A.ITSMID
	inner join [AVL].[MAS_LoginMaster] C on C.ProjectID=B.ProjectID   
	where C.EmployeeID=@EmployeeId and C.IsDeleted=0
end
