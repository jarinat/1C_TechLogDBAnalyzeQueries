
IF OBJECT_ID('tempdb.dbo.#ListOfEvents', 'U') IS NOT NULL
  DROP TABLE #ListOfEvents;

CREATE TABLE #ListOfEvents
(
	EventType NVARCHAR(30),
	Duration NVARCHAR(10)
)

INSERT INTO #ListOfEvents
VALUES ('Deadlock', '0'),
        ('Timeout', '0'),
		('Transaction', '<= 3'),
		('Transaction', '<= 10'),
		('Transaction', '> 10'),
		('Query', '<= 3'),
		('Query', '<= 10'),
		('Query', '> 10'),
		('LockWait', '<= 3'),
		('LockWait', '<= 10'),
		('LockWait', '> 10')
-----------------------------------
SELECT
	IBs.IBName,
	ListOfEvents.EventType,
	ListOfEvents.Duration,
	SUM(CASE
		WHEN Events.DateTime IS NULL THEN 0
		ELSE 1
	END) AS Quantity

FROM
	#ListOfEvents as ListOfEvents
	LEFT JOIN
	(
		SELECT
			Events.IBName
		FROM
			Events
		GROUP BY
			Events.IBName
	) AS IBs
	ON 1 = 1
	LEFT JOIN Events as Events
	ON
		ListOfEvents.EventType = Events.Type
		AND ListOfEvents.Duration = (CASE
									WHEN ISNULL(Events.Duration, 0) = 0 THEN '0'
									WHEN Events.Duration <= 3 * 100000 THEN '<= 3'
									WHEN Events.Duration <= 10 * 100000 THEN '<= 10'
									ELSE '> 10'
								END)
		AND IBs.IBName = Events.IBName

		--AND Events.IBName = 'WMS_ELA'

GROUP BY
	IBs.IBName,
	ListOfEvents.EventType,
	ListOfEvents.Duration

ORDER BY
	IBs.IBName,
	ListOfEvents.EventType,
	ListOfEvents.Duration

        