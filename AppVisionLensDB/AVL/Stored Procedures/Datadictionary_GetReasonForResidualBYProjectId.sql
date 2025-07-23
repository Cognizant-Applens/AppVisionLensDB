/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [AVL].[Datadictionary_GetReasonForResidualBYProjectId] @projectID int
AS
BEGIN
Select ReasonResidualID,ReasonResidualName,CreatedDate from [AVL].[TK_MAS_ReasonForResidual] where isDeleted=0  and ReasonResidualName not in ('Others')
--Union All
--select ReasonResidualID,ReasonResidualName,CreatedDate from [AVL].[Data_others_ReasonForResidual] where isDeleted=0
--And ProjectID=@projectID ORDER BY CreatedDate DESC
END
