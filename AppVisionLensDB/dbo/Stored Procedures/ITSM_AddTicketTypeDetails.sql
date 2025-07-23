/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_AddTicketTypeDetails] 
(	     
@IsCognizant INT,           
@ProjectID INT,
@ITSMTicketTypes TVP_ITSMTicketTypes_Apr24 READONLY,
@CustomerID int=null,
@CreatedBy VARCHAR(100)=NULL
)
AS

BEGIN
DECLARE @result bit=0,@ITSMScreenId INT=3;
    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION
	IF @IsCognizant=1
	  BEGIN
	  SET @ITSMScreenId=4
	  END
	 
			 
     IF (EXISTS (SELECT IsDefaultTicketType FROM @ITSMTicketTypes WHERE IsDefaultTicketType='Y'))
	  BEGIN
	     UPDATE [AVL].[TK_MAP_TicketTypeMapping] SET IsDefaultTicketType=NULL
		  WHERE ProjectID=@ProjectID AND IsDeleted=0
	  END
     IF @IsCognizant=0
	  BEGIN 

	    IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=3 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
         begin
           INSERT INTO [AVL].[PRJ_ConfigurationProgress] 
            (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
            values(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CreatedBy,getdate())
        end  
      else
     begin
        update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate()
		 where ProjectID=@ProjectID and ITSMScreenId=3 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
      end  
	      
	   INSERT INTO [AVL].[TK_MAP_TicketTypeMapping] 
		 (TicketType,AVMTicketType,ProjectID,DebtConsidered,IsDeleted,CreatedDateTime,CreatedBy,IsDefaultTicketType,SupportTypeID) 
		         SELECT TicketTypeName,NULL,@ProjectID,IsDebtApplicable,0,GETDATE(),@CreatedBy,IsDefaultTicketType,SupportTypeID FROM @ITSMTicketTypes WHERE TicketTypeID=0

       UPDATE [AVL].[TK_MAP_TicketTypeMapping] SET TicketType=t2.TicketTypeName,
			DebtConsidered=t2.IsDebtApplicable,IsDefaultTicketType=t2.IsDefaultTicketType,
			ModifiedDateTime=GETDATE(),ModifiedBY=@CreatedBy,SupportTypeID=t2.SupportTypeID
	         FROM [AVL].[TK_MAP_TicketTypeMapping] t1
			 JOIN @ITSMTicketTypes t2 ON t1.TicketTypeMappingID=t2.TicketTypeID AND  t2.TicketTypeID<>0
			
	  END

	  ELSE IF  @IsCognizant=1
	    BEGIN
		 IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=4 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
         begin
           INSERT INTO [AVL].[PRJ_ConfigurationProgress] 
            (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
            values(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CreatedBy,getdate())
        end  
      else
     begin
        update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate()
		 where ProjectID=@ProjectID and ITSMScreenId=3 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
      end

	     DECLARE @Count INT,@i INT=1,@LastIdentity INT
 
SELECT @Count=Count(*) FROM @ITSMTicketTypes 

 
WHILE @i<=@Count
 
BEGIN
 
IF(EXISTS(SELECT TicketTypeID FROM @ITSMTicketTypes WHERE TicketTypeID=0 AND ID=@i))
 
BEGIN
 
INSERT INTO [AVL].[TK_MAP_TicketTypeMapping] 
 
(TicketType,AVMTicketType,ProjectID,DebtConsidered,IsDeleted,CreatedDateTime,CreatedBy,IsDefaultTicketType,SupportTypeID) 
 
SELECT TicketTypeName,AppLensTicketType,@ProjectID,IsDebtApplicable,0,GETDATE(),@CreatedBy,IsDefaultTicketType,SupportTypeID 
 
FROM @ITSMTicketTypes 
 
WHERE TicketTypeID=0 AND ID=@i
 
 
SELECT @LastIdentity=@@IDENTITY
 
INSERT INTO [AVL].[TK_MAP_TicketTypeServiceMapping] 
 
(ProjectID,TicketTypeMappingID,ServiceID,IsDeleted,CreatedDateTime,CreatedBY) 
 
SELECT @ProjectID,@LastIdentity,
 
LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS AVMServiceMappingList,
 
0,GETDATE(),@CreatedBy
 
FROM
 
(
 
SELECT CAST('<XMLRoot><RowData>' + REPLACE(AVMServiceMappingList,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
 
FROM @ITSMTicketTypes WHERE ID=@i
 
)t
 
CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)
 
 
END
 
ELSE
 
BEGIN
 
 UPDATE [AVL].[TK_MAP_TicketTypeServiceMapping] SET IsDeleted=1 
 FROM [AVL].[TK_MAP_TicketTypeServiceMapping] t1 
 JOIN @ITSMTicketTypes t2 ON t1.TicketTypeMappingID=t2.TicketTypeID
 WHERE ProjectID=@ProjectID AND t2.ID=@i AND t2.TicketTypeID<>0

 UPDATE [AVL].[TK_MAP_TicketTypeMapping] SET TicketType=t2.TicketTypeName,AVMTicketType=t2.AppLensTicketType,
ModifiedDateTime=GETDATE(),IsDefaultTicketType=t2.IsDefaultTicketType,ModifiedBY=@CreatedBy,SupportTypeID=t2.SupportTypeID
 FROM [AVL].[TK_MAP_TicketTypeMapping] t1
 JOIN @ITSMTicketTypes t2 ON t1.TicketTypeMappingID=t2.TicketTypeID AND t2.TicketTypeID<>0
  WHERE t2.ID=@i


INSERT INTO [AVL].[TK_MAP_TicketTypeServiceMapping] 
(ProjectID,TicketTypeMappingID,ServiceID,IsDeleted,CreatedDateTime,CreatedBY) 

SELECT @ProjectID,TicketTypeID,
LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS AVMServiceMappingList,
0,GETDATE(),@CreatedBy
FROM
(
SELECT TicketTypeID,CAST('<XMLRoot><RowData>' + REPLACE(AVMServiceMappingList,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
FROM @ITSMTicketTypes WHERE ID=@i
)t
CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)

--UPDATE [AVL].[TK_MAP_TicketTypeServiceMapping] SET TicketTypeMappingID=t2.TicketTypeID,
--ServiceID=t2.AVMServiceMappingList,ModifiedDateTime=GETDATE(),
--ModifiedBY=@CreatedBy FROM [AVL].[TK_MAP_TicketTypeServiceMapping] t1
--JOIN @ITSMTicketTypes t2 ON t1.TicketTypeMappingID=t2.TicketTypeID  AND ID=@i
--JOIN 
--(SELECT TicketTypeID,
--LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS AVMServiceMappingList
--FROM
--(
--SELECT TicketTypeID, CAST('<XMLRoot><RowData>' + REPLACE(AVMServiceMappingList,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
--FROM @ITSMTicketTypes WHERE ID=@i
--)t3  
-- CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)) t4 ON t4.TicketTypeID=t1.TicketTypeMappingID
--WHERE  t2.TicketTypeID<>0 


-- UPDATE [AVL].[TK_MAP_TicketTypeMapping] SET TicketType=t2.TicketTypeName,AVMTicketType=t2.AppLensTicketType,
--ModifiedDateTime=GETDATE(),IsDefaultTicketType=t2.IsDefaultTicketType,ModifiedBY=@CreatedBy
-- FROM [AVL].[TK_MAP_TicketTypeMapping] t1
-- JOIN @ITSMTicketTypes t2 ON t1.TicketTypeMappingID=t2.TicketTypeID AND t2.TicketTypeID<>0
 
END
SET @i=@i+1

END
		 -- INSERT INTO [AVL].[TK_MAP_TicketTypeMapping] 
		 --(TicketType,AVMTicketType,ProjectID,DebtConsidered,IsDeleted,CreatedDateTime,CreatedBy,IsDefaultTicketType) 
		 --        SELECT TicketTypeName,NULL,@ProjectID,IsDebtApplicable,0,GETDATE(),@CreatedBy,IsDefaultTicketType FROM @ITSMTicketTypes WHERE TicketTypeID=0

   --       UPDATE [AVL].[TK_MAP_TicketTypeMapping] SET TicketType=t2.TicketTypeName,
			--DebtConsidered=t2.IsDebtApplicable,ModifiedDateTime=GETDATE(),IsDefaultTicketType=t2.IsDefaultTicketType,
			--ModifiedBY=@CreatedBy
	  --       FROM [AVL].[TK_MAP_TicketTypeMapping] t1
			-- JOIN @ITSMTicketTypes t2 ON t1.TicketTypeMappingID=t2.TicketTypeID AND  t2.TicketTypeID<>0
		END
	 SET @result=1
	 COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_AddTicketTypeDetails] ', @ErrorMessage, 0 ,@CustomerID
		  SET @result=1
	 END CATCH
	
	SET NOCOUNT OFF;
	SELECT @result AS 'Result'
END
