/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_SelfStart_GetColumnMappingResult] --'627384',4,1
    @UserID VARCHAR(50) ,
    @ProjectID INT ,
    @flag INT,
	@ITSMConfigStatus CHAR,
	@ITSMToolID INT
AS 
    BEGIN       
	BEGIN TRY
    SET NOCOUNT ON;  
    
			IF ( @flag = 0 ) 
            BEGIN        
                IF EXISTS ( SELECT  1
                            FROM    AVL.ITSM_PRJ_SSISColumnMapping
                            WHERE   ProjectID = @ProjectID AND IsDeleted = 0 ) 
                    BEGIN          
                        SELECT  ServiceDartColumn ,
                                ProjectColumn ,
                                ProjectColumn + '>' + ServiceDartColumn AS Mapping ,--ServiceDartColumn + '>' + ProjectColumn
                                SourceIndex ,
                                DestinationIndex
                        FROM   AVL.ITSM_PRJ_SSISColumnMapping
                        WHERE   ProjectID = @ProjectID
                                AND IsDeleted = 0 
								ORDER BY SSIScmID         
                    END 
				ELSE IF (NOT EXISTS(SELECT 1 FROM AVL.ITSM_PRJ_SSISColumnMapping WHERE ProjectID = @ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL)) AND @ITSMConfigStatus='A')
				    BEGIN
					SELECT '' AS ServiceDartColumn,'' AS ProjectColumn, ICON.Value+'>'+COLNAME.name AS Mapping,0 AS SourceIndex,0 AS DestinationIndex
					        FROM [AVL].[MAS_ITSMToolConfiguration] ICON
							JOIN [AVL].[ITSM_MAS_Columnname] COLNAME ON ICON.ColMappingID=COLNAME.ColID AND ISNULL(COLNAME.Isdeleted,0)=0
	                       WHERE ICON.ITSMScreenID=2 AND (ICON.IsDeleted=0 OR ICON.IsDeleted IS NULL)  AND ICON.ITSMToolID=@ITSMToolID
					END
		       ELSE
					BEGIN
						SELECT  '' AS ServiceDartColumn ,
                                '' AS ProjectColumn ,
                                '' AS Mapping ,
                                0 AS SourceIndex ,
                                0 AS DestinationIndex
					END         
            END  
			  ELSE 
            IF ( @flag = 1 ) 
                BEGIN        
                   --committing the servicedartcolumn available table AVL.ITSM_MAS_Columnname
				   SELECT  ServiceDartColumn ,
                            ProjectColumn
                    FROM   AVL.ITSM_PRJ_SSISExcelColumnMapping EC
                    WHERE   ProjectID = @ProjectID
                            AND ISNULL(EC.IsDeleted,0) = 0 
							ORDER BY SSIScmID                
                END                                            
              
    
	SET NOCOUNT OFF;	       
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_SelfStart_GetColumnMappingResult] ', @ErrorMessage, @ProjectID,@UserID
		
	END CATCH  
    END


	--select * from MAS.ProjectMaster where IsESAProject='N'


--	insert into AVL.ITSM_PRJ_SSISColumnMapping values (4,'Ticket Type','TicketType','N',GETDATE(),'627384',NULL,NULL,0,0)
--	select * from AVL.ITSM_PRJ_SSISColumnMapping

--	alter table AVL.ITSM_PRJ_SSISExcelColumnMapping alter column IsDeleted bit null
--	update AVL.ITSM_PRJ_SSISExcelColumnMapping set  IsDeleted=0

--19100	Application Name	Application	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	1
--19100	Assignee	Assignee	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	0
--19100	Cause Code	Cause Code	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	77
--19100	Client User ID	ClientUserID	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	2
--19100	DebtClassification	DebtClassification	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	74
--19100	NatureOfTheTicket	NatureOfTheTicket	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	36
--19100	Open Date	OpenDate	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	0
--19100	Priority	Priority	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	0
--19100	Resolution Code	Resolution Code	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	77
--19100	Status	Status	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	1
--19100	TicketDescription	TicketDescription	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	3
--19100	Ticket ID	TicketID	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	0
--19100	Ticket Type	TicketType	N	2018-01-05 14:34:36.793	549178	NULL	NULL	0	0

--insert into AVL.ITSM_PRJ_SSISExcelColumnMapping values(4,null,'PlannedStartDateandTime #','N',getdate(),'627384',null,null)
--	select * from AVL.ITSM_PRJ_SSISExcelColumnMapping
--19100	NULL	SourceDepartment	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	SecAssignee	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	RootCause	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	RaisedByCustomer	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	PlannedEndDate	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	Severity #	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	ReleaseType #	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	PlannedEffort #	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	EstimatedWorkSize #	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	ActualWorkSize #	N	2018-01-05 14:34:36.790	549178	NULL	NULL
--19100	NULL	PlannedStartDateandTime #	N	2018-01-05 14:34:36.790	549178	NULL	NULL
