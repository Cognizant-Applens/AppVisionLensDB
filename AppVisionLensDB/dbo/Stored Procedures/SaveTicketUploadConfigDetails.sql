/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[SaveTicketUploadConfigDetails] --'688715',42423,'M','\\CTSC00374050801\avmdart_dev\43423','Y','688715;0;0;0',5276,null

@EmployeeID varchar(20)=null,
@ProjectID bigint=null,
@IsmanualOrAuto char=null,
@SharePath nvarchar(200)=null,
@Ismailer char=null,
@TicketSharePathUsers varchar(50)=null,
@CustomerID bigint=null,
@ITSMID int=null,
@ProjectTimeZoneId INT=NULL

as
begin
SET NOCOUNT ON;
BEGIN TRY
BEGIN TRAN

Select DISTINCT IsCognizant into #Temp from AVL.Customer (NOLOCK) where CustomerID in 
				  (select TOP 1 LM.CustomerID from AVL.MAS_LoginMaster LM  (NOLOCK) where EmployeeID=@EmployeeID and LM.IsDeleted=0)
Declare @ISCognizant char;
set @ISCognizant=(select IsCognizant from avl.customer (NOLOCK) where customerid = @CustomerID and isdeleted=0)
if(@ISCognizant=1)
begin
	IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK) where ITSMScreenId=11 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
	begin
		INSERT INTO [AVL].[PRJ_ConfigurationProgress]  (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
		values(@CustomerID,@ProjectID,2,11,NULL,0,@EmployeeID,getdate())
	end
	else 
	begin
		update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@EmployeeID,ModifiedDate=getdate() where ProjectID=@ProjectID  and customerid=@CustomerID and screenid=2 and IsDeleted=0 
		end
	end
else
begin
	IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)  where ITSMScreenId=9 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
	begin
		INSERT INTO [AVL].[PRJ_ConfigurationProgress]  (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
		values(@CustomerID,@ProjectID,2,9,NULL,0,@EmployeeID,getdate())
	end
	else 
	begin
		update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@EmployeeID,ModifiedDate=getdate() where ProjectID=@ProjectID 
		 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
	end
end
IF EXISTS(select * from TicketUploadProjectConfiguration (NOLOCK) where ProjectID=@ProjectID and IsDeleted=0)
    BEGIN
        Update TicketUploadProjectConfiguration
		set IsManualOrAuto=@IsmanualOrAuto,
		SharePath=@SharePath,
		Ismailer=@Ismailer,
		TicketSharePathUsers=@TicketSharePathUsers,
		ModifiedBy=@EmployeeID,
		ModifiedDateTime=getdate()
		where ProjectID=@ProjectID and IsDeleted=0
    END
ELSE
    BEGIN
        insert into TicketUploadProjectConfiguration(ProjectID,
		IsManualOrAuto,
		SharePath,
		Ismailer,
		TicketSharePathUsers,
		IsDeleted,
		CreatedBy,
		CreatedDateTime) 
		values(@ProjectID,@IsmanualOrAuto,@SharePath,@Ismailer,@TicketSharePathUsers,0,@EmployeeID,Getdate())
    END

IF EXISTS(select * from AVL.MAP_ProjectConfig (NOLOCK) where ProjectID=@ProjectID)
    BEGIN
        Update AVL.MAP_ProjectConfig
		set TimeZoneId=@ProjectTimeZoneId,
		ModifiedBy=@EmployeeID,
		ModifiedDateTime=getdate()
		where ProjectID=@ProjectID 
    END
ELSE
    BEGIN
        insert into AVL.MAP_ProjectConfig(ProjectID,
		TimeZoneId,
		CreatedBY,
		CreatedDateTime) 
		values(@ProjectID,@ProjectTimeZoneId,@EmployeeID,Getdate())
    END



	DECLARE @Type Varchar(10),@SharePathName Varchar(200),@IsMailerType Varchar(10),@UsersTicketSharePath VARCHAR(50)='0;0;0;0'
	SELECT @IsManualOrAuto=IsManualOrAuto,@SharePath=SharePath,@IsMailer=Ismailer,@TicketSharePathUsers=TicketSharePathUsers
    FROM TicketUploadProjectConfiguration (NOLOCK) WHERE ProjectID =@ProjectID AND IsDeleted=0

     IF ((IsNull(@IsManualOrAuto, '') = 'A' AND ISNULL(@ProjectTimeZoneId,0) !=0) OR 
	 (IsNull(@IsManualOrAuto, '') != '' AND IsNull(@SharePath, '') != '' AND IsNull(@IsMailer, '') != '' 
	 AND IsNull(@TicketSharePathUsers, '0;0;0;0') != '0;0;0;0')
	 )
      BEGIN
	    IF @ISCognizant=1 
		BEGIN
          update [AVL].[PRJ_ConfigurationProgress]  set CompletionPercentage=100
		  where ProjectID=@ProjectID  and customerid=@CustomerID and screenid=2 and ITSMScreenId = 11 and IsDeleted=0 
        END
		ELSE
		BEGIN
		  update [AVL].[PRJ_ConfigurationProgress]  set CompletionPercentage=100
		    where ProjectID=@ProjectID  and customerid=@CustomerID and screenid=2 and ITSMScreenId = 9 and IsDeleted=0 
		END
      END

select * from TicketUploadProjectConfiguration (NOLOCK) where ProjectID=@ProjectID and IsDeleted=0
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[SaveTicketUploadConfigDetails]', 

@ErrorMessage, @EmployeeID ,@ProjectID
		
	END CATCH  
	SET NOCOUNT OFF;
end
