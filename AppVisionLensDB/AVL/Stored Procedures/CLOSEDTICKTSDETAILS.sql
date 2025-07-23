
Create PROCEDURE AVL.CLOSEDTICKTSDETAILS  

AS   

BEGIN  

CREATE TABLE #ClosedTemp(  

SUbmitterID INT,  

ProjectID INT,  

EmployeeID int,  

[MONTH] INT,  

[Year] INT,  

[MONTHNAME] NVARCHAR (50),

ClosedTickets INT

)  


INSERT INTO #ClosedTemp(SUbmitterID,ProjectID,EmployeeID,[MONTH],[Year],[MONTHNAME],ClosedTickets)  

Select A1.SubmitterId,A1.ProjectID,A1.EmployeeID,A1.Month,A1.Year,A1.MONTHNAME,(coalesce(A1.ClosedTickets1,0) + coalesce(B1.ClosedTickets2,0)) as ClosedTickets from   

(Select A.AssignedTo as SubmitterId ,A.ProjectID,D.EmployeeID,Month(A.Closeddate) as Month,  

Year(A.Closeddate)as Year,DATENAME(MONTH,A.Closeddate)AS MONTHNAME,count(A.TicketID) as ClosedTickets1 

from [AVL].[TK_TRN_TicketDetail](NOLOCK) A Inner Join [AVL].[TK_MAS_Service] B  

On A.ServiceID = B.ServiceID Inner Join [AVL].MAS_ServiceLevel C   

On B.ServiceLevelID = C.ServiceLevelID   

Left Join Avl.Mas_LoginMaster D ON  A.AssignedTo=D.UserID AND D.ProjectID=A.ProjectID  

where A.DARTStatusID = 8  and C.ServiceLevelID Not in (5,6)   

AND A.Closeddate >= DATEADD(Day,1,EOMONTH(DATEADD(Month,-6,GETDATE())))   

Group by  A.AssignedTo,A.ProjectID,D.EmployeeID,Month(A.Closeddate),Year(A.Closeddate),DATENAME(MONTH,A.Closeddate)) A1 

Full Outer Join  

(Select A.AssignedTo as SubmitterId ,A.ProjectID,D.EmployeeID,Month(A.OpenDateTime) as Month,  

Year(A.OpenDateTime)as Year,DATENAME(MONTH,A.Closeddate)AS MONTHNAME,count(A.TicketID)as ClosedTickets2 

from [AVL].[TK_TRN_TicketDetail](NOLOCK) A Inner Join [AVL].[TK_MAS_Service] B  

On A.ServiceID = B.ServiceID Inner Join [AVL].MAS_ServiceLevel C   

On B.ServiceLevelID = C.ServiceLevelID    

Left Join Avl.Mas_LoginMaster D ON A.AssignedTo=D.UserID AND D.ProjectID=A.ProjectID  

where A.DARTStatusID = 8 and A.ClosedDate is Null and C.ServiceLevelID Not in (5,6) and DARTStatusID <> 13   

AND A.Closeddate >= DATEADD(Day,1,EOMONTH(DATEADD(Month,-6,GETDATE())))   

Group by  A.AssignedTo,A.ProjectID,D.EmployeeID,Month(A.OpenDateTime),Year(A.OpenDateTime),DATENAME(MONTH,A.Closeddate))B1


On A1.SubmitterId =B1.SubmitterId  

and A1.ProjectID = B1.ProjectID   

And A1.Month = B1.Month  

And A1.Year = B1.Year;  

CREATE TABLE #AssociateTemp(  

AssociateID Char(11),  

AssociateName varchar(max),  

Designation nvarchar(max),  

offshore varchar(3),  

Dept_Name varchar(max),  

grade varchar(30), 

GradeEquivalent nvarchar(100),

ESAProjectID INT,  

projectid int  

)  

Insert INTO #AssociateTemp (AssociateID,AssociateName,Designation,offshore,Dept_Name,grade,GradeEquivalent,ESAProjectID,projectid)  

SELECT A1.AssociateID,A1.AssociateName,A1.Designation,A1.Offshore_Onsite,A2.Dept_Name,A2.Grade,A5.Grade_Equivalent As garde,A2.ProjectID as Esa_Project_Id,a4.projectid  

FROM [ESA].Associates(NOLOCK) A1   

INNER JOIN [ESA].[ProjectAssociates](NOLOCK)A2 ON A1.AssociateID = A2.AssociateID and A1.Grade=a2.Grade  

LEFT JOIN AVL.Mas_ProjectMaster (Nolock) A4 ON A2.projectid=A4.EsaProjectID  

LEFT JOIN [dbo].[Grade_Equivalent] (NoLock) A5 ON A5.Grade=A2.grade
 
Select *from #AssociateTemp a   

Left JOIN #ClosedTemp b on a.projectid=b.ProjectID and a.AssociateID=b.EmployeeID 
 
 
END  
 

