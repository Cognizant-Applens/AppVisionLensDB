CREATE TABLE [dbo].[GeoMapping] (
    [GeoMapID]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [ESA_AccountID]   VARCHAR (MAX) NULL,
    [SBU_Delivery]    NVARCHAR (50) NULL,
    [IsDeleted]       BIT           DEFAULT ((0)) NOT NULL,
    [CreatedDate]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       NVARCHAR (50) DEFAULT ('SYSTEM') NOT NULL,
    [ModifiedDate]    DATETIME      NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [Client_Practice] NVARCHAR (50) NULL
);

