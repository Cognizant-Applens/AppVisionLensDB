/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE proc [dbo].[ITSM_SaveITSMDetails]
@ITSMID int=null,
@ITSMName nvarchar(max)=null,
@ITSMConfig char(2)=null,
@ProjectID int=null,
@EmployeeID NVARCHAR(MAX)=NULL,
@CustomerID int=null
as
begin
SET NOCOUNT ON;
BEGIN TRY
BEGIN TRAN
IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)  where ITSMScreenId=1 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
begin
INSERT INTO [AVL].[PRJ_ConfigurationProgress]  (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
values(@CustomerID,@ProjectID,2,1,100,0,@EmployeeID,getdate())
end
else 
begin
update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@EmployeeID,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=1 and customerid=@CustomerID and screenid=2 and IsDeleted=0 and ITSMScreenId=1
end
if(@ITSMID=0)
begin

insert into AVL.MAS_ITSMTools values(@ITSMName,0,@EmployeeID,GETDATE(),@CustomerID)
set @ITSMID=(select top 1 ITSMID from AVL.MAS_ITSMTools (NOLOCK)  order by ITSMID desc)
end
select @ITSMID as 'ITSMID'
update [AVL].[MAS_ProjectMaster]  set ITSMConfiguration=@ITSMConfig,ITSMID=@ITSMID,ModifiedBy=@EmployeeID,ModifiedDate=getdate() where ProjectID=@ProjectID
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_SaveITSMDetails] ', @ErrorMessage, 0 ,@CustomerID
		
	END CATCH  
	SET NOCOUNT OFF;
end

--SELECT * FROM [AVL].[MAS_ITSMScreenMaster]
----DELETE FROM [AVL].[MAS_ITSMScreenMaster]
--select * from [AVL].[PRJ_ConfigurationProgress]
