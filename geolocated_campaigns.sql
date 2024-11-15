---- Offtheshelf orders
DROP TABLE IF EXISTS #physical_store_argyroupoli
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Sales Office ID]
INTO #physical_store_argyroupoli
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Sales Office ID],4) IN ('7503')
	AND YEAR([Date])>= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] IS NOT NULL
	AND [OneCustomer ID] <> '#'
	AND [Order Channel ID] IN  ('#') -- offtheshelf


---- Webservices/Store orders courier
DROP TABLE IF EXISTS #store_courier_argyroupoli
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Sales Office ID]
INTO #store_courier_argyroupoli
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Sales Office ID],4) IN ('7503')
	AND YEAR([Date]) >= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] IS NOT NULL
	AND [OneCustomer ID] <> '#'
	AND [Order Channel ID] IN  ('Webservice', 'Store')
	AND ShippingMethod = 'COURIER'


---- Webservices/Store orders store pickup
DROP TABLE IF EXISTS #store_store_argyroupoli
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Sales Office ID]
INTO #store_store_argyroupoli
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Sales Office ID],4) IN ('7503')
	AND YEAR([Date]) >= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] IS NOT NULL
	AND [OneCustomer ID] <> '#'
	AND [Order Channel ID] IN  ('Webservice', 'Store')
	AND ShippingMethod = 'Store'


---- Web orders store pickup
DROP TABLE IF EXISTS #web_argyroupoli
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Plant ID]
INTO #web_argyroupoli
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Plant ID],4) IN ('7503')
	AND YEAR([Date]) >= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] IS NOT NULL
	AND [OneCustomer ID] <> '#'
	AND [Order Channel ID] NOT IN  ('Webservice', 'Store', '#')
	AND ShippingMethod = 'Store'


DROP TABLE IF EXISTS #tmp_hd
SELECT a.[OneCustomer ID]
	, [Document ID]
	, CASE WHEN b.Shiptopostalcode IS NULL THEN c.[Shiptopostalcode] ELSE b.[Shiptopostalcode] END AS [Shiptopostalcode]
INTO #tmp_hd
FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] AS a WITH (NOLOCK)
LEFT JOIN (SELECT DISTINCT [Order No], [Shiptopostalcode] FROM [DW_PRD].[dw].[nexus_fact_order_lines] with (nolock) where [Shiptopostalcode] IN ('17341', '17342', '17343', 
'17455', '17456', 
'12351', 
'18233', '18234', 
'16451', '16452', 
'16672', '16673', 
'16672', '16673', '16674', 
'16673', '16674', 
'16671', 
'16674', '16675', '16676', 
'17235', '17236', 
'16777', '16778', 
'17671', '17672', '17673', 
'18533', 
'18344', '18345', '18346', 
'17121', '17122', '17123', '17124', 
'17561', '17562', '17563', 
'17778'
) )  AS b ON a.[Order ID]=b.[Order No] 
LEFT JOIN (SELECT DISTINCT [Ordernum], [Shiptopostalcode] FROM [WEBDATA].[web].[DOCUMENT_HEADER] with (nolock) where [Shiptopostalcode] IN ('17341', '17342', '17343', 
'17455', '17456', 
'12351', 
'18233', '18234', 
'16451', '16452', 
'16672', '16673', 
'16672', '16673', '16674', 
'16673', '16674', 
'16671', 
'16674', '16675', '16676', 
'17235', '17236', 
'16777', '16778', 
'17671', '17672', '17673', 
'18533', 
'18344', '18345', '18346', 
'17121', '17122', '17123', '17124', 
'17561', '17562', '17563', 
'17778'

) )  AS c ON a.[Order ID]=c.[Ordernum] 
WHERE 1=1
	AND YEAR([Date]) >= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] <> '#'
	AND  (b.Shiptopostalcode IS NOT NULL OR c.Shiptopostalcode IS NOT NULL)


DROP TABLE IF EXISTS #customers_final
SELECT *
INTO #customers_final
FROM #physical_store_argyroupoli
UNION 
SELECT *
FROM #store_courier_argyroupoli
UNION 
SELECT *
FROM #store_store_argyroupoli
UNION 
SELECT *
FROM #web_argyroupoli
UNION 
SELECT *
FROM #tmp_hd




DROP TABLE IF EXISTS #mobile_consent
SELECT TOP 1 with ties *
INTO #mobile_consent
FROM [CustomerAnalytics].[customer].[Customer_Consent_DB]
WHERE 1=1
	AND mobile <> ''
	AND mobile IS NOT NULL
order by row_number() over (partition by mobile order by updated_at desc)



DROP TABLE IF EXISTS #mobile_consent_list
SELECT distinct a.*
	, b.*
	, CASE WHEN c.[mobileConsent] IS NULL THEN 3 ELSE c.[mobileConsent] END AS [mobileConsent]
INTO #mobile_consent_list
FROM #customers_final AS a
LEFT JOIN [CustomerAnalytics].[customer].[BasicInfo] AS b ON a.[OneCustomer ID]=b._id
LEFT JOIN #mobile_consent AS c ON b.mobile = c.mobile 


DROP TABLE IF EXISTS #Final_list
SELECT a.*
	, CASE WHEN b.emailConsent IS NULL THEN 3 ELSE b.emailConsent END AS emailConsent
INTO #Final_list
FROM #mobile_consent_list AS a
LEFT JOIN [CustomerAnalytics].[customer].[Customer_Consent_DB] AS b ON a.[value] =b.[_id.email] AND a.[type]= 'EMAIL'
WHERE 1=1




SELECT DISTINCT [OneCustomer ID]
	, [Sales Office ID]
	, created_at
	, mail
	, mobile
	, [name]
	, [surname]
	, [type]
	, [value]
	, [NEXT_ID]
	, mobileConsent
	, emailConsent
	, CASE WHEN [Sales Office ID] IN ('7503') THEN 'Store - Public+ Home Αργυρούπολης'
		   WHEN [Sales Office ID] IN ('17341', '17342', '17343') THEN '’γιος Δημήτριος'
		   WHEN [Sales Office ID] IN ('17455', '17456') THEN '’λιμος'
		   WHEN [Sales Office ID] IN ('12351') THEN 'Αγία Βαρβάρα'
		   WHEN [Sales Office ID] IN ('18233', '18234') THEN '’γιος Ιωάννης Ρέντης'
           WHEN [Sales Office ID] IN ('16451', '16452') THEN 'Αργυρούπολη'
           WHEN [Sales Office ID] IN ('16672', '16673') THEN 'Βάρη'
           WHEN [Sales Office ID] IN ('16672', '16673', '16674') THEN 'Βάρη - Βάρκιζα'
		   WHEN [Sales Office ID] IN ('16673', '16674') THEN 'Βούλα'
		   WHEN [Sales Office ID] IN ('16671') THEN 'Βουλιαγμένη'
		   WHEN [Sales Office ID] IN ('16674', '16675', '16676') THEN 'Γλυφάδα'
		   WHEN [Sales Office ID] IN ('17235', '17236') THEN 'Δάφνη'
		   WHEN [Sales Office ID] IN ('16777', '16778') THEN 'Ελληνικό'
		   WHEN [Sales Office ID] IN ('17671', '17672', '17673') THEN 'Καλλιθέα'
		   WHEN [Sales Office ID] IN ('18533') THEN 'Καστέλλα'
		   WHEN [Sales Office ID] IN ('18344', '18345', '18346') THEN 'Μοσχάτο'
		   WHEN [Sales Office ID] IN ('17121', '17122', '17123', '17124') THEN 'Νέα Σμύρνη'
		   WHEN [Sales Office ID] IN ('17561', '17562', '17563') THEN 'Παλαιό Φάληρο'
		   WHEN [Sales Office ID] IN ('17778') THEN 'Ταύρος'

	   ELSE 'Other' END AS Public_store
	, CASE WHEN ([mobileConsent] = 1 OR emailConsent = 1) THEN 'Has consent'
		   WHEN ([mobileConsent] = 0 OR  emailConsent = 0) THEN 'Has no consent'
		   WHEN ([mobileConsent] = 3 OR  emailConsent = 3) THEN 'No status'
		   ELSE 'Other' END AS flag
FROM #Final_list
WHERE 1=1







