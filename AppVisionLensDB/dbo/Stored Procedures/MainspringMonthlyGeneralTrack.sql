/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [dbo].[MainspringMonthlyGeneralTrack]
@ProjectId int,
@MethodName varchar(500),
--@StartTime varchar(500),
--@EndTime varchar(500),
@StartTime datetime,
@EndTime datetime,
@Remarks varchar(500)

AS

BEGIN
SET NOCOUNT ON; 
declare @CreatedBy varchar(500);
set @createdBy='Mainspring'
DECLARE @CreatedDate DATETIME;
set @CreatedDate=GETDATE()
declare @ModifiedBy varchar(500);
set @ModifiedBy=NULL
declare @ModifiedDate datetime;
set @ModifiedDate=NULL

--if(@EndTime is null or @EndTime = '' or  @EndTime ='null' )
if(@EndTime is null)

BEGIN
Insert into MainspringMonthlyTrack values(@ProjectId,@MethodName,@StartTime,@EndTime,@Remarks,@createdBy,@CreatedDate,@ModifiedBy,@ModifiedDate)
END
ELSE
BEGIN
Update MainspringMonthlyTrack set EndTime=@EndTime,Remarks=@Remarks where ProjectID=@ProjectId and MethodName=@MethodName
END
SET NOCOUNT OFF; 
End
