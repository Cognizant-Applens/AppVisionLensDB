/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[DataDictionary_AddReasonforResidual] @ResidualText nvarchar(max),@EmployeeID varchar(50),@projectID int
AS
BEGIN
Declare  @countID int
set @countID=(select count(*) from [AVL].[Data_others_ReasonForResidual] where ReasonResidualName=@ResidualText and ProjectID=@projectID)
IF(@countID !=1)
BEGIN
Insert into [AVL].[Data_others_ReasonForResidual] values(@projectID,@ResidualText,0,@EmployeeID,GETDATE(),NULL,NULL)
END
END
