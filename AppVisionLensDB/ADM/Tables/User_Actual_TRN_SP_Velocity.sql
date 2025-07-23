CREATE TABLE [ADM].[User_Actual_TRN_SP_Velocity] (
    [User_SP_ID]              INT             IDENTITY (1, 1) NOT NULL,
    [ProjectSprintVelocityID] BIGINT          NOT NULL,
    [UserID]                  INT             NOT NULL,
    [SP_Delivered]            DECIMAL (18, 2) NOT NULL,
    [IsDeleted]               BIT             DEFAULT ((0)) NOT NULL,
    [CreatedBy]               NVARCHAR (50)   DEFAULT ('System') NOT NULL,
    [CreatedDate]             DATETIME        DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              NVARCHAR (50)   NULL,
    [ModifiedDate]            DATETIME        NULL,
    CONSTRAINT [PK_User_SP_ID] PRIMARY KEY CLUSTERED ([User_SP_ID] ASC),
    CONSTRAINT [FK_ProjectSprintVelocityID] FOREIGN KEY ([ProjectSprintVelocityID]) REFERENCES [ADM].[Project_Sprint_TRN_SP_Velocity] ([ProjectSprintVelocityID])
);

