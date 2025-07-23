CREATE TYPE [MS].[BaseMeasureData_TVP] AS TABLE(
	[ServiceId] [bigint] NOT NULL,
	[BaseMeasureId] [bigint] NOT NULL,
	[BaseMeasureValue] [nvarchar](50) NULL
)