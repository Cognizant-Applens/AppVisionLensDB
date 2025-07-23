/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[BOM_ActivityDetailsMap]                    
@ActivityData xml = Null,                    
@ActivityID bigint = NULL,                    
@BusinessProcessID bigint = NULL,                    
@AccountID bigint = NULL,                    
@mode nvarchar(10)                    
As                    
                    
Begin                    
                  
                    
SET NOCOUNT ON;            
          
IF @Mode = 'Upload'          
          
BEGIN          
        
Declare @tempActivityforEXcel table            
(            
ActivityMapID bigint primary key not null Identity(1,1),            
ActivityID bigint null,          
BusinessProcessID bigint null,               
IsActive bit not null,            
CreatedBy nvarchar(50)  null,                     
ModifiedBy nvarchar(50)  null,            
ApplicationID bigint null            
)            
Insert into @tempActivityforEXcel            
Select              
   ActivityDetails.query('ActivityID').value('.', 'bigint') as ActivityID,         
   ActivityDetails.query('BusinessProcessID').value('.', 'bigint') as BusinessProcessID ,           
   ActivityDetails.query('IsActive').value('.', 'bit') as IsActive,              
   ActivityDetails.query('CreatedBy').value('.', 'nvarchar(50)') as CreatedBy,                          
   ActivityDetails.query('ModifiedBy').value('.', 'nvarchar(50)') as ModifiedBy,            
   ActivityDetails.query('ApplicationID').value('.', 'bigint') as ApplicationID        
            
FROM   @ActivityData.nodes('/AVL.BOM_ActivityMap/ActivityDetails')AS ActivityData(ActivityDetails)              
            
          
  MERGE INTO AVL.BOM_ActivityMap AS target          
  USING (Select [ActivityID],[BusinessProcessID],          
         [IsActive] ,[CreatedBy]            
   ,[ModifiedBy],[ApplicationID]          
         from @tempActivityforEXcel GROUP BY [ActivityID],[BusinessProcessID],[ApplicationID],[IsActive] ,[CreatedBy],[ModifiedBy] ) AS source          
                           ON target.ActivityID = source.ActivityID          
                           AND target.BusinessProcessId = source.BusinessProcessID        
         AND target.ApplicationID=source.ApplicationID  and target.AccountID=@AccountID        
                           WHEN MATCHED THEN           
                           UPDATE SET target.ModifiedBy = source.ModifiedBy,target.ModifiedDate=GETDATE()   , target.Isactive=   source.Isactive,target.Manual=0  
                           WHEN NOT MATCHED BY TARGET THEN          
                           Insert  (ActivityID,BusinessProcessID,IsActive        
         ,CreatedBy ,ModifiedBy,ModifiedDate,ApplicationID,AccountID,Manual)          
                           VALUES (source.ActivityID,source.BusinessProcessID, 1,          
        source.CreatedBy,source.ModifiedBy,GETDATE(),source.ApplicationID,@AccountId,0);         
        
        
UPDATE AVL.BOM_ActivityMap SET IsActive = 0, ModifiedDate = GETDATE()      
WHERE  ActivityID in (select a.ActivityID FRom @tempActivityforEXcel a join AVL.BOM_ActivityMap b on a.ActivityID=b.ActivityID)   
AND AccountId = @AccountID AND Manual=1 AND BusinessProcessId in (select a.BusinessProcessID FRom @tempActivityforEXcel a join AVL.BOM_ActivityMap b on a.ActivityID=b.ActivityID)
       
END          
          
        
                  
if @Mode='Insert'                    
Begin                     
                             
       Declare @tempActivity table                    
(                    
ActivityMapID bigint primary key not null Identity(1,1),                    
ActivityID bigint null,                    
                    
IsActive bit not null,                    
CreatedBy nvarchar(50)  null,                    
CreatedDate datetime null,                    
ModifiedBy nvarchar(50)  null,                    
ApplicationID bigint null                    
)                    
                    
                    
                    
Insert into @tempActivity            
Select                      
   ActivityDetails.query('ActivityID').value('.', 'bigint') as ActivityID,                                     
   ActivityDetails.query('IsActive').value('.', 'bit') as IsActive,                      
   ActivityDetails.query('CreatedBy').value('.', 'nvarchar(50)') as CreatedBy,                     
   ActivityDetails.query('CreatedDate').value('.', 'datetime') as CreatedDate,                     
   ActivityDetails.query('ModifiedBy').value('.', 'nvarchar(50)') as ModifiedBy,                    
   ActivityDetails.query('ApplicationID').value('.', 'bigint') as ApplicationID                    
FROM   @ActivityData.nodes('/AVL.BOM_ActivityMap/ActivityDetails')AS ActivityData(ActivityDetails)                      
                
MERGE INTO AVL.BOM_ActivityMap AS target                    
                           USING (Select [ActivityID],                    
         [IsActive],[CreatedBy],[CreatedDate],[ModifiedBy],[ApplicationID]                    
         from @tempActivity) AS source                    
                           ON target.ActivityID = source.ActivityID                    
                           AND target.BusinessProcessID =   @BusinessProcessID               
         AND target.ApplicationID=source.ApplicationID and target.IsActive=Source.Isactive              
                           WHEN MATCHED THEN                     
                           UPDATE SET target.ModifiedBy = source.ModifiedBy,target.ModifiedDate=GETDATE()                    
                           WHEN NOT MATCHED BY TARGET THEN                    
                           Insert (ActivityID,IsActive,CreatedBy,CreatedDate,                    
         ModifiedBy,ModifiedDate,ApplicationID,Manual,BusinessProcessId,AccountId)                    
                           VALUES (source.ActivityID, source.IsActive,                    
         source.CreatedBy,GETDATE(),source.ModifiedBy,GETDATE(),source.ApplicationID,0,@BusinessProcessID,@AccountID);                    
                    
                    
UPDATE AVL.BOM_ActivityMap SET IsActive = 0, ModifiedDate = GETDATE() WHERE ActivityID = @ActivityID  AND AccountId = @AccountID AND                   
ApplicationID NOT IN (SELECT ApplicationID FROM @tempActivity WHERE  ActivityID = @ActivityID )                   
AND BusinessProcessId=@BusinessProcessID           
                    
End                    
                    
ELSE IF @Mode='Select'                    
BEGIN                     
 SELECT [ActivityID],[IsActive],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[ApplicationID],[Manual]                     
    FROM AVL.BOM_ActivityMap WHERE ActivityID=@ActivityID   AND BusinessProcessId=@BusinessProcessID AND AccountId=@AccountID  AND IsActive=1              
END                  
              
ELSE IF @Mode='Remove'  
                
BEGIN                
                    
UPDATE AVL.BOM_ActivityMap SET IsActive = 0, ModifiedDate = GETDATE() WHERE ActivityID = @ActivityID AND
BusinessProcessId=@BusinessProcessID AND AccountId=@AccountID              
           
END                
          
         
END
