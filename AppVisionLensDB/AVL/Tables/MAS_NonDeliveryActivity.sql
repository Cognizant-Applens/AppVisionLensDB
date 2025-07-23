CREATE TABLE [AVL].[MAS_NonDeliveryActivity] (
    [ID]                  INT            NOT NULL,
    [NonTicketedActivity] NVARCHAR (MAX) NULL,
    [IsActive]            BIT            NULL,
    [CreatedBy]           NVARCHAR (MAX) NULL,
    [CreatedDate]         DATETIME       NULL
);

