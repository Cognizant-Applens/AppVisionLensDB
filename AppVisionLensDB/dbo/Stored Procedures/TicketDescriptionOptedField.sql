/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[TicketDescriptionOptedField]  
@ProjectID int  
AS  
BEGIN  
SET nocount ON;
  
Declare @result bit;  
  
if exists(select TOP 1 ProjectID from ml.ConfigurationProgress (NOLOCK) where ProjectID =@ProjectID)
BEGIN
set @result=(select TOP 1 isnull(IsTicketDescriptionOpted,0) from ml.ConfigurationProgress (NOLOCK) where ProjectID=@ProjectID and IsDeleted = 0)  
  END
  ELSE
  BEGIN
  set @result=0;
  END


select @result;  
  SET nocount OFF;
End
