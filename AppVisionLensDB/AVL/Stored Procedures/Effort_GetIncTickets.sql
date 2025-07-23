/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[Effort_GetIncTickets]
 @ProjectId int,
 @Opendate varchar(max),
 @Closedate varchar(max),
 @Applicationid varchar(50),
 @Resolutionid varchar(max),
 @Causeid varchar(max),
 @Avoidableflag varchar(max),
 @Customerid int,
 @Debtclassificationid varchar(max),
 @Effortwicetckid int,
 @kvalue int
AS
Begin
 DECLARE @Applicationtemp TABLE    
            (    
              id  VARCHAR(100)    
            )                
        DECLARE @Resolutiontemp TABLE    
            (    
              id VARCHAR(100)    
            )          
        DECLARE @Causetemp TABLE    
            (    
              id  VARCHAR(100)    
            )                
        DECLARE @Debttypetemp TABLE    
            (    
              id  VARCHAR(100)    
            )       

--To Split the Application Fields               
        DECLARE @srcdesc VARCHAR(MAX)                
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@Applicationid, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @srcdesc                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                INSERT  INTO @Applicationtemp      
                VALUES  ( @srcdesc )                
                       
                FETCH NEXT FROM db_cursor INTO @srcdesc                
            END              
        CLOSE db_cursor                           
        DEALLOCATE db_cursor 

--To Split the Resolution Fields               
        DECLARE @srcdesc1 VARCHAR(MAX)                
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@Resolutionid, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @srcdesc1                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                INSERT  INTO @Resolutiontemp    
                VALUES  ( @srcdesc1 )                
                       
                FETCH NEXT FROM db_cursor INTO @srcdesc1                
            END              
        CLOSE db_cursor                           
        DEALLOCATE db_cursor

		--To Split the Cause Fields               
        DECLARE @srcdesc2 VARCHAR(MAX)                
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@Causeid, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @srcdesc2                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                INSERT  INTO @Causetemp      
                VALUES  ( @srcdesc2 )                
                       
                FETCH NEXT FROM db_cursor INTO @srcdesc2                
            END              
        CLOSE db_cursor                           
        DEALLOCATE db_cursor


		--To Split the debt type Fields               
        DECLARE @srcdesc3 VARCHAR(MAX)                
        DECLARE db_cursor CURSOR    
        FOR    
            SELECT  item    
            FROM    dbo.split(@Debtclassificationid, ',')                        
        OPEN db_cursor                         
        FETCH NEXT FROM db_cursor INTO @srcdesc3                
        WHILE @@FETCH_STATUS = 0     
            BEGIN                  
                INSERT  INTO @Debttypetemp    
                VALUES  ( @srcdesc3 )                
                       
                FETCH NEXT FROM db_cursor INTO @srcdesc3               
            END              
        CLOSE db_cursor                           
        DEALLOCATE db_cursor

SELECT TM.TicketID,TM.ApplicationName,TM.DebtClassificationName,TM.AvoidableFlag,
              TM.ResolutionCodeName,TM.CauseCodeName
              FROM AppVisionLensOffline.RPT.TK_TRN_TicketDetail TM
              INNER JOIN AVL.MAS_ProjectMaster PM ON TM.ProjectID=PM.ProjectID
              INNER JOIN AVL.TK_MAP_TicketTypeMapping TTM ON TM.TicketTypeMapID=TTM.TicketTypeMappingID AND TM.ProjectID=TTM.ProjectID
              INNER JOIN AVL.DEBT_MAP_CauseCode MCC ON TM.CauseCodeMapID=MCC.CauseID AND TM.ProjectID=MCC.ProjectID
              INNER JOIN AVL.DEBT_MAP_ResolutionCode MRC ON TM.ResolutionCodeMapID=MRC.ResolutionID AND TM.ProjectID=MRC.ProjectID
              INNER JOIN AVL.MAS_ProjectDebtDetails PDB ON PM.ProjectID=PDB.ProjectID
              LEFT JOIN AVL.Customer C ON PM.CustomerID=C.CustomerID AND C.IsCognizant=0
              WHERE 
			  TM.ProjectID=@ProjectId And
			  PM.IsDebtEnabled = 'Y'			  
			  AND PM.IsDeleted = 0 And
			  TTM.DebtConsidered='Y' 
              AND PDB.DebtControlFlag='Y' AND CONVERT(DATE,PDB.DebtControlDate) <= CONVERT(DATE,GETDATE())
              --AND PM.IsProjectsetupcompleted = 'Y'              
              AND TM.DARTStatusID = 8 
              AND TM.AvoidableFlag IN(2,3)
              AND TM.ApplicationID IS NOT NULL
              AND TM.DebtClassificationMapID IS NOT NULL
              AND TM.AvoidableFlag IS NOT NULL 
              AND TM.CauseCodeMapID IS NOT NULL
              AND TM.ResolutionCodeMapID IS NOT NULL
			  AND TM.LastUpdatedDate > CONVERT(DATE,GETDATE()-2)
			  And TM.OpenDateTime>=@opendate AND TM.Closeddate<=@closedate 
              AND tm.IsAttributeUpdated = 1
			  AND TTM.AVMTicketType NOT in (9,10,20) or TTM.AVMTicketType is null
              AND MCC.IsHealConsidered = 'Y'
              AND MRC.IsHealConsidered = 'Y'
			  AND TM.TicketID NOT IN(SELECT HPC.DARTTicketID FROM AVL.DEBT_PRJ_HealParentChild HPC 
              WHERE ISNULL(HPC.IsManual,0) NOT IN(0)
              )
			  AND TM.AvoidableFlag=@Avoidableflag
			  And C.CustomerID=@Customerid
			  And MCC.CauseID in (select id from @Causetemp)
			  And MRC.ResolutionID in (select id from @Resolutiontemp)
			  AND TM.ApplicationId in(select id from @Applicationtemp)
			  And TM.DebtClassificationMapID in(select id from @Debttypetemp)
			  --AND TM.ResidualDebtName='NO'
End
