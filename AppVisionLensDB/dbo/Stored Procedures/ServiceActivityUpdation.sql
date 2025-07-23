/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC ServiceActivityUpdation 'Application Strengthening','Internal Communication On/Off',41387


CREATE proc ServiceActivityUpdation 
@ServiceName varchar(max),
@ActivityName varchar(max),
@projectID Bigint
as 
begin

DECLARE @ServiceTypeID BIGINT
set @ServiceTypeID= (select ServiceType from AVL.TK_MAS_Service where ServiceName=@ServiceName and IsDeleted=0)

if(@ServiceTypeID<>4)
BEGIN
	if NOT exists(SELECT * from AVL.TK_MAS_ServiceActivityMapping WHERE  ServiceName=@ServiceName and ActivityName=@ActivityName and IsDeleted=0)
	BEGIN
		declare @ServiceID bigint
		declare @ActivityID bigint
	
		if NOT EXISTS(select * from AVL.MAS_ActivityMaster where ActivityName=@ActivityName and IsDeleted=0)
		BEGIN
			set @ActivityID =(select top 1 (ActivityID)+1 from AVL.TK_MAS_ServiceActivityMapping ORDER by ActivityID desc)
		END
		ELSE
		BEGIN
			set @ActivityID =(select ActivityID from AVL.MAS_ActivityMaster where ActivityName=@ActivityName and IsDeleted=0)
		END
		set @ServiceID =(select ServiceID from AVL.TK_MAS_Service where ServiceName=@ServiceName and IsDeleted=0)

		insert into AVL.TK_MAS_ServiceActivityMapping(ServiceTypeID,ServiceID,ServiceName,ServiceShortName,ActivityID,ActivityName,Categorization,IsDeleted,CreatedDate,CreatedBy) 
		values(@ServiceTypeID,@ServiceID,@ServiceName,@ServiceName,@ActivityID,@ActivityName,'ENVA',0,getdate(),627119)

	END

	DECLARE @ServiceMapID BIGINT
	set @ServiceMapID=(SELECT ServiceMappingID from AVL.TK_MAS_ServiceActivityMapping WHERE  ServiceName=@ServiceName and ActivityName=@ActivityName and IsDeleted=0)

	if NOT EXISTS(SELECT * from AVL.TK_PRJ_ProjectServiceActivityMapping where ProjectID=@projectID and ServiceMapID=@ServiceMapID and IsDeleted=0)
	BEGIN
		insert INTO AVL.TK_PRJ_ProjectServiceActivityMapping(ServiceMapID,ProjectID,IsDeleted,CreatedDateTime,CreatedBY) 
		VALUES(@ServiceMapID,@projectID,0,GETDATE(),627119)
	END
END
END
