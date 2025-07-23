/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_SelfStart_SaveColumnMapping]    
    @UserID INT ,    
    @ProjectID INT ,    
    @MapList VARCHAR(MAX) ,    
    @Source VARCHAR(MAX) = NULL ,    
    @Destination VARCHAR(MAX)  = NULL ,    
    @SourceIndex VARCHAR(MAX) ,    
    @DestinationIndex VARCHAR(MAX),
	@CustomerID int=null    
AS     
    BEGIN                  
	BEGIN TRY 
	BEGIN TRAN            
        SET NOCOUNT ON;  
                           
        DECLARE @temp TABLE    
            (    
              id INT IDENTITY(1, 1) ,    
              [Source] VARCHAR(100)    
            )                
        DECLARE @temp1 TABLE    
            (    
              id INT IDENTITY(1, 1) ,    
              Destination VARCHAR(100)    
            )                
        DECLARE @Sourcetemp TABLE    
            (    
              id INT IDENTITY(1, 1) ,    
              [Source] VARCHAR(100)    
            )                
        DECLARE @Destinationtemp TABLE    
            (    
              id INT IDENTITY(1, 1) ,    
              Destination VARCHAR(100)    
            )          
        DECLARE @SrcIndex TABLE    
            (    
              id INT IDENTITY(1, 1) ,    
              [Index] VARCHAR(100)    
            )                
        DECLARE @DestIndex TABLE    
            (    
              id INT IDENTITY(1, 1) ,    
              [Index] VARCHAR(100)    
            )                  
                
 -- To Split the Mapping Fields              
        DECLARE @desc VARCHAR(MAX)                
        DECLARE @flag INT                
        SET @flag = 0                
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@MapList, '>')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @desc                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                IF ( @flag = 0 )     
                    BEGIN                
                        INSERT  INTO @temp    
                                ( Source )    
                        VALUES  ( @desc )                
                        SET @flag = 1                 
                    END                
                ELSE     
                    BEGIN                
                        INSERT  INTO @temp1    
                                ( Destination )    
                        VALUES  ( @desc )                
                        SET @flag = 0                
                    END                      
                   
                FETCH NEXT FROM db_cursor INTO @desc                
            END                         
        CLOSE db_cursor                           
        DEALLOCATE db_cursor               
                
 -- To Split the Source Fields               
        DECLARE @srcdesc VARCHAR(MAX)                
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@Source, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @srcdesc                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                INSERT  INTO @Sourcetemp    
                        ( Source )    
                VALUES  ( @srcdesc )                
                       
                FETCH NEXT FROM db_cursor INTO @srcdesc                
            END              
        CLOSE db_cursor                           
        DEALLOCATE db_cursor               
         
 -- To Split the Destination Fields                
               
        DECLARE @destdesc VARCHAR(MAX)                
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@Destination, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @destdesc                
        WHILE @@FETCH_STATUS = 0     
            BEGIN     
                INSERT  INTO @Destinationtemp    
                        ( Destination )    
                VALUES  ( @destdesc )                
                     
                FETCH NEXT FROM db_cursor INTO @destdesc            
            END                
        CLOSE db_cursor                           
        DEALLOCATE db_cursor               
           
  -- To Split the Source Index          
            
        DECLARE @index INT               
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@SourceIndex, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @index                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                INSERT  INTO @SrcIndex    
                        ( [Index] )    
                VALUES  ( @index )                
                       
                FETCH NEXT FROM db_cursor INTO @index                
            END              
        CLOSE db_cursor                           
        DEALLOCATE db_cursor            
           
 -- To Split the Destination Index          
            
        DECLARE @index1 INT               
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@DestinationIndex, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @index1                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                INSERT  INTO @DestIndex    
                        ( [Index] )    
                VALUES  ( @index1 )                
                       
                FETCH NEXT FROM db_cursor INTO @index1                
            END              
        CLOSE db_cursor            
        DEALLOCATE db_cursor           
               
              
        IF EXISTS ( SELECT  1    
                    FROM   [AVL].[ITSM_PRJ_SSISExcelColumnMapping]      
                    WHERE   ProjectID = @ProjectID )     
            BEGIN              
                DELETE  FROM [AVL].[ITSM_PRJ_SSISExcelColumnMapping]       
                WHERE   ProjectID = @ProjectID;              
            END   
            
            DECLARE @SrcCnt int, @DestCnt int
                 
              
               
            
  
             
            INSERT  INTO [AVL].[ITSM_PRJ_SSISExcelColumnMapping]      
                ( ProjectID ,      
                  ServiceDartColumn ,                      
                  IsDeleted ,      
                  CreatedDateTime ,      
                  CreatedBY      
                )      
                SELECT  @ProjectID AS ProjectId ,      
                        B.Destination ,                              
                        0 AS IsDeleted ,      
                        GETDATE() ,      
                        @UserID      
                FROM     @Destinationtemp B                      
                            
          UPDATE  SM SET SM.ProjectColumn=A.Source      
    FROM       
    [AVL].[ITSM_PRJ_SSISExcelColumnMapping] SM            
    INNER JOIN                    
    (SELECT DISTINCT SSCM.ServiceDartColumn,TS.Source FROM @Sourcetemp TS      
    INNER JOIN  @Sourcetemp TD ON TD.ID=TS.ID      
    INNER JOIN [AVL].[ITSM_PRJ_SSISExcelColumnMapping]    SSCM ON Replace(SSCM.ServiceDartColumn,' ','')=Replace(TD.Source,' ','')  
    WHERE SSCM.ProjectID = @ProjectID) A      
    ON A.ServiceDartColumn=SM.ServiceDartColumn      
    WHERE SM.ProjectID = @ProjectID
	
 --New Source are adding to the table             
INSERT INTO [AVL].[ITSM_PRJ_SSISExcelColumnMapping] (ProjectID,ServiceDartColumn,ProjectColumn,IsDeleted,CreatedBY,CreatedDateTime)
SELECT @ProjectID,NULL,[Source],0,@UserID,GETDATE() from  @Sourcetemp
WHERE  NOT EXISTS (SELECT ProjectColumn
                   FROM  [AVL].[ITSM_PRJ_SSISExcelColumnMapping](NOLOCK)  
                   WHERE Replace([Source],' ','')=Replace(ProjectColumn,' ','') and ProjectID=@ProjectID)

--ends	 
        IF EXISTS ( SELECT  1    
                    FROM    [AVL].[ITSM_PRJ_SSISColumnMapping]    
                    WHERE   ProjectID = @ProjectID )     
            BEGIN              
                DELETE  FROM [AVL].[ITSM_PRJ_SSISColumnMapping]     
                WHERE   ProjectID = @ProjectID;              
            END              
        INSERT  INTO [AVL].[ITSM_PRJ_SSISColumnMapping]      
                ( ProjectID ,    
                  ServiceDartColumn ,    
                  ProjectColumn ,    
                  IsDeleted ,    
                  CreatedDateTime ,    
      CreatedBY ,    
                  SourceIndex ,    
                  DestinationIndex    
                )    
                SELECT  @ProjectID AS ProjectId , 
						Destination ,    
                        [Source] , 
                        0 AS IsDeleted ,    
                        GETDATE() ,    
                        @UserID ,    
                        C.[Index] ,    
                        D.[Index]    
                FROM    @temp A ,    
                        @temp1 B ,    
                        @SrcIndex C ,    
                        @DestIndex D    
                WHERE   A.id = B.id    
                        AND B.id = C.id    
                        AND C.id = D.id    
						
  IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=2 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
   begin
    IF(NOT EXISTS(SELECT ServiceDartColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping] WHERE ServiceDartColumn='Severity' AND ProjectID=@ProjectID AND IsDeleted=0)) 
    INSERT INTO [AVL].[PRJ_ConfigurationProgress]
	(CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate,IsSeverity) 
	values(@CustomerID,@ProjectID,2,2,100,0,@UserID,getdate(),0)
	ELSE 
  INSERT INTO [AVL].[PRJ_ConfigurationProgress] (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate,IsSeverity)
  values(@CustomerID,@ProjectID,2,2,100,0,@UserID,getdate(),1)
   end  
  else
   begin
    IF(NOT EXISTS(SELECT ServiceDartColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping] WHERE ServiceDartColumn='Severity' AND ProjectID=@ProjectID AND IsDeleted=0)) 
    update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@UserID,ModifiedDate=getdate(),IsSeverity=0 where ProjectID=@ProjectID and ITSMScreenId=2 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
	ELSE
	    update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@UserID,ModifiedDate=getdate(),IsSeverity=1 where ProjectID=@ProjectID and ITSMScreenId=2 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
  end              
    SELECT ISNULL(IsSeverity,0) AS 'IsSeverity' FROM [AVL].[PRJ_ConfigurationProgress]  where ProjectID=@ProjectID and ITSMScreenId=2 and customerid=@CustomerID and screenid=2 and IsDeleted=0             
  SET NOCOUNT OFF;    
  COMMIT TRAN
  END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_SelfStart_SaveColumnMapping] ', @ErrorMessage, @ProjectID,@UserID
		
	END CATCH  



 END
