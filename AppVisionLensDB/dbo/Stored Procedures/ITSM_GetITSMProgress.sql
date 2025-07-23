/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE proc [dbo].[ITSM_GetITSMProgress] --83,5497

@ProjectID int,
@CustomerID INT=NULL
as
begin
BEGIN TRY
Declare @ITSMScreenId DECIMAL(18,2);
DECLARE @STATUSProgress DECIMAL(18,4);
DECLARE @IsSeverity INT=NULL,@IsCognizant INT
DECLARE @ClosedTicketStatus DECIMAL(18,2)=0
DECLARE @TicketUploadStatus DECIMAL(18,2)=0
DECLARE @MainIndex int
 DECLARE @SecondMax int
 DECLARE @ScreenCount int
 declare @finalPerc int
 DECLARE @SupportType INT 


SELECT 	@IsCognizant=C.IsCognizant FROM AVL.Customer C  (NOLOCK) WHERE CustomerID=@CustomerID AND C.IsDeleted=0

IF (@IsCognizant=1)
BEGIN
SET NOCOUNT ON;
		CREATE TABLE #SupportTabl
		(
			SupportTypeID INT
		)
		INSERT INTO #SupportTabl
		exec pp.getsupporttypeid @ProjectID

		SELECT @SupportType=SupportTypeID  FROM #SupportTabl
END 
ELSE 
BEGIN

 SET @SupportType = (SELECT ISNULL(SupportTypeId,0) FROM AVL.MAP_ProjectConfig (NOLOCK) WHERE ProjectID = @ProjectID)
 END
 set @ITSMScreenId=(select TOP 1 ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
					where ProjectID=@ProjectID AND CustomerID=@CustomerID AND ScreenID=2 AND IsDeleted=0 ORDER BY ITSMScreenId DESC)

 set @ScreenCount=CASE WHEN (@SupportType=1 and @IsCognizant = 1) THEN (select count(id) from AVL.PRJ_ConfigurationProgress 
					where ProjectID=@ProjectID AND CustomerID=@CustomerID and IsDeleted=0 and ScreenID=2 AND ITSMScreenId<>12) ELSE
					(select count(id) from AVL.PRJ_ConfigurationProgress (NOLOCK)
					where ProjectID=@ProjectID AND CustomerID=@CustomerID and IsDeleted=0 and ScreenID=2) END
   


 select @IsSeverity=IsSeverity from [AVL].[PRJ_ConfigurationProgress]  (NOLOCK)
 WHERE ProjectID=@ProjectID AND IsDeleted=0 AND ScreenID=2 AND ITSMScreenId=2

 IF @IsCognizant=0 OR @IsCognizant IS NULL
 BEGIN

 SET @SecondMax  =(select TOP 1 ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
     where ProjectID=@ProjectID AND CustomerID=@CustomerID AND ScreenID=2 AND IsDeleted=0 and ITSMScreenId<>10 
	   ORDER BY ITSMScreenId DESC)
	 set @MainIndex=(case WHEN (@SecondMax=2 and @ITSMScreenId=10) then 3 ELSE @SecondMax END)

 SELECT @ClosedTicketStatus=CompletionPercentage  from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
          where ProjectID=@ProjectID AND CustomerID=@CustomerID AND ScreenID=2 AND IsDeleted=0 AND ITSMScreenId=6

SELECT @TicketUploadStatus=CompletionPercentage  from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
          where ProjectID=@ProjectID AND CustomerID=@CustomerID AND ScreenID=2 AND IsDeleted=0 AND ITSMScreenId=9

      IF @IsSeverity=1 AND (NOT EXISTS(select TOP 1 ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
          where ProjectID=@ProjectID AND CUSTOMERID=@CustomerID AND ScreenID=2 AND IsDeleted=0 AND ITSMScreenId=5))
		   BEGIN
		      IF @ClosedTicketStatus IS NULL AND @TicketUploadStatus IS NULL 
			   set @STATUSProgress=(CONVERT(DECIMAL(18, 2),@ScreenCount-3))/10;

			  ELSE IF @ClosedTicketStatus IS NULL OR @TicketUploadStatus IS NULL 
			   set @STATUSProgress=(CONVERT(DECIMAL(18, 2),@ScreenCount-2))/10;
		      ELSE 

			   set @STATUSProgress=(CONVERT(DECIMAL(18, 2),@ScreenCount-1))/10;
            END

       ELSE 
	    BEGIN
	         IF  @ClosedTicketStatus IS NULL AND @TicketUploadStatus IS NULL 
			  SET @STATUSProgress=(CONVERT(DECIMAL(18, 2),@ScreenCount-2)*100)/1000;
			 ELSE IF @ClosedTicketStatus IS NULL OR @TicketUploadStatus IS NULL
		      set @STATUSProgress=(CONVERT(DECIMAL(18, 2),@ScreenCount-1)*100)/1000;
            ELSE 
	           set @STATUSProgress=(CONVERT(DECIMAL(18, 2),@ScreenCount)*100)/1000;
        END
  set @finalPerc  =(select @STATUSProgress*100)
      select cast (@MainIndex as int) as ITSMScreenID,@IsCognizant as IsCognizant,
	   case when (@finalPerc) >100.00 THEN 100.00 ELSE @finalPerc end as StatusProgress,
	  ISNULL(@IsSeverity,0) AS 'IsSeverity',@SupportType as SupportTypeId
  END

  IF @IsCognizant=1
    BEGIN
   SET @SecondMax  =(select TOP 1 ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
     where ProjectID=@ProjectID AND CustomerID=@CustomerID AND ScreenID=2 AND IsDeleted=0 and ITSMScreenId<>12 
	   ORDER BY ITSMScreenId DESC)
	  
	 --set @MainIndex=(case WHEN (@SupportType=2 AND @SecondMax BETWEEN 3 AND 11 and @ITSMScreenId=12) 
	 --then @SecondMax - 1 ELSE @SecondMax END)
	  
	 --set @MainIndex=(case WHEN (@SecondMax=2 and @ITSMScreenId=12) then 3 ELSE @SecondMax END)


	 set @MainIndex=(case WHEN (@SupportType=2 AND @SecondMax BETWEEN 3 AND 11 and @ITSMScreenId=12) 
	 then @SecondMax - 1 ELSE CASE WHEN @ScreenCount=12 THEN @ScreenCount-2 ELSE 
	 CASE WHEN (@SupportType!=2 AND  @SecondMax BETWEEN 3 AND 11 and @ITSMScreenId=12) THEN  @SecondMax ELSE @SecondMax END END END)
	  
	 set @MainIndex=(case WHEN (@SecondMax=2 and @ITSMScreenId=12) then 3 ELSE @MainIndex END)

	  IF @ScreenCount=12 
	  BEGIN
	      SET @ScreenCount=@ScreenCount-1
	  END

	 SELECT @ClosedTicketStatus=CompletionPercentage  from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
          where ProjectID=@ProjectID AND CUSTOMERID=@CustomerID AND ScreenID=2 AND IsDeleted=0 AND ITSMScreenId=7
     
	 SELECT @TicketUploadStatus=CompletionPercentage  from [AVL].[PRJ_ConfigurationProgress] (NOLOCK)
          where ProjectID=@ProjectID AND CustomerID=@CustomerID AND ScreenID=2 AND IsDeleted=0 AND ITSMScreenId=11

	
	       IF @ClosedTicketStatus IS NULL AND @TicketUploadStatus IS NULL
		       Set @STATUSProgress=case when @SupportType=3 
									then ((CONVERT(DECIMAL(18, 2),@ScreenCount-2)*100)/1100) 
									else ((CONVERT(DECIMAL(18, 2),@ScreenCount-2)*100)/1000)
									END
            ELSE IF @ClosedTicketStatus IS NULL OR @TicketUploadStatus IS NULL
			   set @STATUSProgress=case when @SupportType=3 
									then ((CONVERT(DECIMAL(18, 2),@ScreenCount-1)*100)/1100)
									else ((CONVERT(DECIMAL(18, 2),@ScreenCount-1)*100)/1000)
									END
		      ELSE 
			   set @STATUSProgress=case when @SupportType=3 
									then ((CONVERT(DECIMAL(18, 2),@ScreenCount)*100)/1100)
									else((CONVERT(DECIMAL(18, 2),@ScreenCount)*100)/1000)
									END
									print @STATUSProgress
				set @finalPerc  =(select @STATUSProgress*100)
		select cast (@MainIndex as int) as ITSMScreenID,@IsCognizant as IsCognizant,
		case when (@finalPerc) >100.00 THEN 100.00 ELSE @finalPerc end as StatusProgress,
	  ISNULL(@IsSeverity,0) AS 'IsSeverity',@SupportType as SupportTypeId 
   END
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_GetITSMProgress]', @ErrorMessage, @ProjectID,@CustomerID
		
	END CATCH  
	SET NOCOUNT OFF;

end
