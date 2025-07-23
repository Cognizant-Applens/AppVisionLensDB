/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW dbo.VW_TicketDetails
AS
SELECT DISTINCT 
                         C.CustomerName AS AccountName, PRJ.CTS_VERTICAL AS practiseowner, Sev.SeverityName, PM.ProjectID, PRJ.ID AS ESAProjectID, PM.ProjectName, 
                         SAM.ServiceName, TD.TicketID, TS.SubmitterId AS AssociateID, d_desig1.Designation, TD.Onsite_Offshore, TD.OpenDateTime, PrSt.StatusName AS ticketstatus, 
                         TD.CompletedDateTime AS ticketresolveddate, TD.Closeddate AS ticketcloseddate, TSD.Hours, PriMap.PriorityName, TD.Resolvedby, App.ApplicationName, 
                         SAM.ActivityName AS categoryname, SAM.ServiceID, TS.TimesheetDate, SAM.ActivityName, MONTH(TD.OpenDateTime) AS month, YEAR(TD.OpenDateTime) AS year, 
                         C.ESA_AccountID, C.CustomerID, tkttype.TicketTypeName, TD.TicketStatusMapID, App.PrimaryTechnologyID, tech.PrimaryTechnologyName, 
                         TD.MetResponseSLAMapID, sla.MetSLAName
FROM            AVL.TM_PRJ_Timesheet AS TS WITH (NOLOCK) INNER JOIN
                         AVL.TM_TRN_TimesheetDetail AS TSD WITH (NOLOCK) ON TS.TimesheetId = TSD.TimesheetId AND TS.ProjectID = TSD.ProjectId INNER JOIN
                         AVL.MAS_LoginMaster AS LM WITH (NOLOCK) ON LM.UserID = TS.SubmitterId AND LM.IsDeleted = 0 INNER JOIN
                         AVL.TK_TRN_TicketDetail AS TD WITH (NOLOCK) ON TD.TimeTickerID = TSD.TimeTickerID AND TSD.ProjectId = TD.ProjectID INNER JOIN
                         AVL.TK_MAP_SeverityMapping AS SM ON SM.SeverityIDMapID = TD.SeverityMapID AND SM.ProjectID = TD.ProjectID INNER JOIN
                         AVL.TK_MAP_ProjectStatusMapping AS PrSt ON PrSt.TicketStatus_ID = TD.DARTStatusID AND TD.ProjectID = PrSt.ProjectID INNER JOIN
                         AVL.TK_MAP_PriorityMapping AS PriMap ON PriMap.PriorityIDMapID = TD.PriorityMapID AND TD.ProjectID = PriMap.ProjectID INNER JOIN
                         AVL.APP_MAS_ApplicationDetails AS App ON App.ApplicationID = TD.ApplicationID INNER JOIN
                         AVL.MAS_ProjectMaster AS PM ON PM.ProjectID = TD.ProjectID AND PM.IsESAProject = 1 INNER JOIN
                         AVL.Customer AS C ON C.CustomerID = PM.CustomerID AND C.IsCognizant = 1 LEFT OUTER JOIN
                         AVL.TK_MAS_Severity AS Sev ON Sev.SeverityID = SM.SeverityID LEFT OUTER JOIN
                         AVL.TK_MAS_ServiceActivityMapping AS SAM ON SAM.ServiceID = TSD.ServiceId AND SAM.ActivityID = TSD.ActivityId LEFT OUTER JOIN
                         AVL.TK_MAS_MetSLACondition AS sla ON sla.MetSLAId = TD.MetResolutionMapID LEFT OUTER JOIN
                         AVL.APP_MAS_PrimaryTechnology AS tech ON tech.PrimaryTechnologyID = App.PrimaryTechnologyID LEFT OUTER JOIN
                         AVL.TK_MAS_TicketType AS tkttype ON tkttype.TicketTypeID = TD.TicketTypeMapID LEFT OUTER JOIN
                         ESA.Projects AS PRJ WITH (NOLOCK) ON PM.EsaProjectID = PRJ.ID LEFT OUTER JOIN
                         ESA.ProjectAssociates AS d_desig WITH (NOLOCK) ON TS.SubmitterId = d_desig.AssociateID AND d_desig.ProjectID = PM.ProjectID LEFT OUTER JOIN
                         ESA.Associates AS d_desig1 ON d_desig1.AssociateID = d_desig.AssociateID

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TS"
            Begin Extent = 
               Top = 6
               Left = 297
               Bottom = 135
               Right = 494
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TSD"
            Begin Extent = 
               Top = 6
               Left = 532
               Bottom = 135
               Right = 721
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 259
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TD"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 303
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SM"
            Begin Extent = 
               Top = 138
               Left = 341
               Bottom = 267
               Right = 529
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PrSt"
            Begin Extent = 
               Top = 138
               Left = 567
               Bottom = 267
               Right = 766
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PriMap"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_TicketDetails';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       End
         Begin Table = "App"
            Begin Extent = 
               Top = 270
               Left = 311
               Bottom = 399
               Right = 547
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PM"
            Begin Extent = 
               Top = 270
               Left = 585
               Bottom = 399
               Right = 811
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 531
               Right = 298
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Sev"
            Begin Extent = 
               Top = 402
               Left = 336
               Bottom = 531
               Right = 506
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SAM"
            Begin Extent = 
               Top = 402
               Left = 544
               Bottom = 531
               Right = 730
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sla"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 663
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tech"
            Begin Extent = 
               Top = 534
               Left = 246
               Bottom = 663
               Right = 471
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tkttype"
            Begin Extent = 
               Top = 534
               Left = 509
               Bottom = 663
               Right = 688
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PRJ"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 795
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d_desig"
            Begin Extent = 
               Top = 666
               Left = 268
               Bottom = 795
               Right = 475
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d_desig1"
            Begin Extent = 
               Top = 666
               Left = 513
               Bottom = 795
               Right = 716
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_TicketDetails';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_TicketDetails';

