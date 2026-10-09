GO
USE SPEDMON
SELECT 
       cc.CLIENT_NAME
      ,pp.CONCAT_NAME
      ,gg.GROUP_NAME
      ,pc.CLIENT_ID
      ,pg.PRACTITIONER_ID
      ,gg.GROUP_ID
      ,CASE
			WHEN gg.GROUP_ID
				IN (48,175,181,199)
			THEN 'Yes'
			ELSE 'No'
			END									AS [Can Supervise]
	  ,CASE
			WHEN gg.GROUP_ID
				IN (50,177,178,179,187,189)
			THEN 'Yes'
			ELSE 'No'
			END									AS [Needs Supervision]
	  ,pp.UserID
      ,pp.EMAIL
      
FROM [SPEDMON].[dbo].[PRACTITIONER_Practitioner]	AS pp
	JOIN dbo.PRACTITIONER_Client					AS pc	ON pc.PRACTITIONER_ID	= pp.PRACTITIONER_ID
	JOIN dbo.CLIENTS_Client							AS cc	ON cc.CLIENT_ID			= pc.CLIENT_ID
	LEFT OUTER JOIN dbo.PRACTITIONER_GROUPS			AS pg	ON pg.PRACTITIONER_ID	= pp.PRACTITIONER_ID
																						AND (pg.GROUP_TYPE < 3
																						OR pg.GROUP_ID IN (152, 154, 155))
	JOIN dbo.GROUP_Group							AS gg	ON gg.GROUP_ID			= pg.GROUP_ID
	
WHERE 1=1
	AND pp.ACTIVE = 1
	AND cc.LEA = 1
	AND cc.CLIENT_ID <> 112
	AND gg.GROUP_BASE = 'Speech'
	AND gg.GROUP_ID <> 198	--Take out "Waiver SLP Credential " Since they cannot bill therapy
	AND gg.GROUP_ID <> 176	--Take out "Speech- Unlicensed, Preliminary Services Credential IN SLP " since they cannot supervise but do not need supervision
	
ORDER BY 
	cc.CLIENT_NAME, pp.CONCAT_NAME
GO