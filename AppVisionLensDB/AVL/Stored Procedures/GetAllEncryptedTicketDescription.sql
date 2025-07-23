/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [AVL].[GetAllEncryptedTicketDescription] 1,'[AVL].[TK_TRN_TicketDetail]','TicketDescription','TimeTickerID'
CREATE PROCEDURE [AVL].[GetAllEncryptedTicketDescription] 
@PageCount INT,
@TableName VARCHAR(100),
@EncryptedColumnName  VARCHAR(100),
@IdentityColumnName VARCHAR(50)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	
	SET NOCOUNT ON

	DECLARE @StartRow BIGINT,@EndRow BIGINT,@LastRecordID BIGINT,@IsLastPage BIT=0,@TotalRecordsCount BIGINT=1
	DECLARE @sqlCommand VARCHAR(500),@FirstRow VARCHAR(10),@LastRow VARCHAR(10),@StatusMsg VARCHAR(20)

	DECLARE @ConditionValidate VARCHAR(50)=' '

	IF  ((@TableName ='[$(DebtEngineDB)].[DE].[InfraHealTicketDetails]') or (@TableName ='[$(DebtEngineDB)].[DE].[HealTicketDetails]'))   AND @EncryptedColumnName='TicketDescription'
	  BEGIN 
	    SET @ConditionValidate=' AND TicketType=''K'''
	  END

	IF @TableName='[ML].[TicketValidation]' AND @EncryptedColumnName='OptionalField'
	  BEGIN
	  	    SET @ConditionValidate=' AND ID>=80030 AND ID<=81029'
	  END

    SET @StartRow=(@PageCount-1)*30000;
	SET @EndRow=@PageCount*30000;
	SET @FirstRow=CAST(@StartRow AS NVARCHAR(10))
	SET @LastRow=CAST(@EndRow  AS NVARCHAR(10))

	CREATE TABLE #TempTRNTickets(
	ID BIGINT,
	TicketDescription NVARCHAR(MAX)
	)

	CREATE TABLE #TempLastData(
	LastRecordID BIGINT
	)
	
	CREATE TABLE #TempTotalRecords(
	 RecordsCount BIGINT
	)

	SET @sqlCommand = 'SELECT  ' + @IdentityColumnName +' AS ''ID'','+ @EncryptedColumnName + ' AS ''TicketDescription'' FROM ' + @TableName +
	' WHERE('+@EncryptedColumnName+' IS NOT NULL AND '+ @EncryptedColumnName+'!='''') AND '
	+ @IdentityColumnName +'>'+ @FirstRow +' AND '+@IdentityColumnName+'<='+@LastRow + @ConditionValidate

   INSERT INTO #TempTRNTickets Exec(@sqlCommand)

   SET @sqlCommand=''
   SET @sqlCommand='SELECT TOP 1 '+@IdentityColumnName+ ' AS ''LastRecordID'' FROM '+ @TableName + 
   ' WHERE('+@EncryptedColumnName + ' IS NOT NULL AND ' +@EncryptedColumnName+'!='''') '+@ConditionValidate + ' ORDER BY '+ @IdentityColumnName +' DESC'
   INSERT INTO #TempLastData Exec(@sqlCommand)

   --SELECT @TempTRNTicketsCount=COUNT(ID) FROM #TempTRNTickets

   IF(@PageCount=1)
    BEGIN
         SET @sqlCommand=''
         SET @sqlCommand='SELECT COUNT('+@IdentityColumnName+') FROM '+ @TableName +
		        ' WHERE('+@EncryptedColumnName + ' IS NOT NULL AND ' +@EncryptedColumnName+'!='''')'
         INSERT INTO #TempTotalRecords Exec(@sqlCommand)
		 SELECT TOP 1 @TotalRecordsCount=RecordsCount FROM #TempTotalRecords
    END

		 
		 -- SELECT TimeTickerID,TicketID,ProjectID,TicketDescription
		 -- INTO #TempTRNTickets FROM AVL.TK_TRN_TicketDetail (NOLOCK)  
	  --   WHERE (TicketDescription is not null AND TicketDescription!='') AND 
		 --TimeTickerID>@StartRow AND TimeTickerID<=@EndRow

		SELECT TOP 1 @LastRecordID=LastRecordID FROM #TempLastData 

		 IF(EXISTS(SELECT ID FROM #TempTRNTickets WHERE ID=@LastRecordID))
		  BEGIN  
		  SET @IsLastPage=1
		  END
		  ELSE
		   BEGIN
		   SET @IsLastPage=0
		   END

		 SELECT @IsLastPage AS 'IsLastPage',@TotalRecordsCount AS 'TotalRecordsCount'
	     SELECT * FROM #TempTRNTickets

		  IF OBJECT_ID(N'tempdb..#TempTRNTickets') IS NOT NULL
            BEGIN
                 DROP TABLE #TempTRNTickets
            END
          IF OBJECT_ID(N'tempdb..#TempLastData') IS NOT NULL
            BEGIN
                 DROP TABLE #TempLastData
            END
		  IF OBJECT_ID(N'tempdb..#TempTotalRecords') IS NOT NULL
            BEGIN
                 DROP TABLE #TempTotalRecords
            END
			SET @StatusMsg='success'
			SELECT @StatusMsg AS 'Status'

  SET NOCOUNT OFF
COMMIT TRAN
END TRY  
	BEGIN CATCH  
	 DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		SELECT @ErrorMessage as ErrorMessage

		SET @StatusMsg='fail' 
	    SELECT @StatusMsg AS 'Status'
	ROLLBACK TRAN

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetAllEncryptedTicketDescription]', @ErrorMessage, 0,0
	END CATCH 
END
