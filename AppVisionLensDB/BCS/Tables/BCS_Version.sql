CREATE TABLE [BCS].[BCS_Version] (
    [RecordID]        INT             IDENTITY (1, 1) NOT NULL,
    [UtilityId]       INT             NULL,
    [VersionNumber]   DECIMAL (10, 2) NULL,
    [LastUpdatedDate] DATETIME        NOT NULL,
    [Comments]        VARCHAR (100)   NULL,
    [IsDeleted]       BIT             NOT NULL,
    [CreatedBy]       VARCHAR (50)    NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [ModifiedBy]      VARCHAR (50)    NULL,
    [ModifiedDate]    DATETIME        NULL
);

