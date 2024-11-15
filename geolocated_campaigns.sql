
---- Offtheshelf orders
DROP TABLE IF EXISTS #physical_store_iwannina
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Sales Office ID]
INTO #physical_store_iwannina
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Sales Office ID],4) IN ('7060')
	AND YEAR([Date])>= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] IS NOT NULL
	AND [OneCustomer ID] <> '#'
	AND [Order Channel ID] IN  ('#') -- offtheshelf


---- Webservices/Store orders courier
DROP TABLE IF EXISTS #store_courier_iwannina
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Sales Office ID]
INTO #store_courier_iwannina
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Sales Office ID],4) IN ('7060')
	AND YEAR([Date]) >= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] IS NOT NULL
	AND [OneCustomer ID] <> '#'
	AND [Order Channel ID] IN  ('Webservice', 'Store')
	AND ShippingMethod = 'COURIER'


---- Webservices/Store orders store pickup
DROP TABLE IF EXISTS #store_store_iwannina
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Sales Office ID]
INTO #store_store_iwannina
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Sales Office ID],4) IN ('7060')
	AND YEAR([Date]) >= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] IS NOT NULL
	AND [OneCustomer ID] <> '#'
	AND [Order Channel ID] IN  ('Webservice', 'Store')
	AND ShippingMethod = 'Store'


---- Web orders store pickup
DROP TABLE IF EXISTS #web_iwannina
SELECT DISTINCT [OneCustomer ID]
	, [Document ID]
	, [Plant ID]
INTO #web_iwannina
  FROM [CustomerAnalytics].[forecast].[factOneCustomerSales_new] WITH (NOLOCK)
  WHERE 1=1
	AND LEFT([Plant ID],4) IN ('7060')
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
LEFT JOIN (SELECT DISTINCT [Order No], [Shiptopostalcode] FROM [DW_PRD].[dw].[nexus_fact_order_lines] with (nolock) where [Shiptopostalcode] IN ('45221','45222','45232','45233','45244','45333','45332','45445','45444','45500','45570','44002','44003','44001'
,'44010','44200','44100','44004','46100','46131','46030','46200','46300','47132','47131','47150','47041','47040','47045','47044','47043','48100','48200','48060','48061','48062','48300','30131','30132','30133','30150') )  AS b ON a.[Order ID]=b.[Order No] 
LEFT JOIN (SELECT DISTINCT [Ordernum], [Shiptopostalcode] FROM [WEBDATA].[web].[DOCUMENT_HEADER] with (nolock) where [Shiptopostalcode] IN ('45221','45222','45232','45233','45244','45333','45332','45445','45444','45500','45570','44002','44003','44001'
,'44010','44200','44100','44004','46100','46131','46030','46200','46300','47132','47131','47150','47041','47040','47045','47044','47043','48100','48200','48060','48061','48062','48300','30131','30132','30133','30150') )  AS c ON a.[Order ID]=c.[Ordernum] 
WHERE 1=1
	AND YEAR([Date]) >= '2019'
	AND [Country ID] = '0070'
	AND [OneCustomer ID] <> '#'
	AND  (b.Shiptopostalcode IS NOT NULL OR c.Shiptopostalcode IS NOT NULL)


DROP TABLE IF EXISTS #customers_final
SELECT *
INTO #customers_final
FROM #physical_store_iwannina
UNION 
SELECT *
FROM #store_courier_iwannina
UNION 
SELECT *
FROM #store_store_iwannina
UNION 
SELECT *
FROM #web_iwannina
UNION 
SELECT *
FROM #tmp_hd




DROP TABLE IF EXISTS #mobile_consent
SELECT TOP 1 with ties *
INTO #mobile_consnet
FROM [CustomerAnalytics].[customer].[Customer_Consent_DB]
WHERE 1=1
	AND mobile <> ''
	AND mobile IS NOT NULL
order by row_number() over (partition by mobile order by updated_at desc)



DROP TABLE IF EXISTS #mobile_consent_list
SELECT distinct a.*
	, b.*
	, CASE WHEN c.[mobileConsent] IS NULL THEN 3 ELSE c.[mobileConsent] END AS [mobileConsent]
INTO #mobile_consnet_list
FROM #customers_final AS a
LEFT JOIN [CustomerAnalytics].[customer].[BasicInfo] AS b ON a.[OneCustomer ID]=b._id
LEFT JOIN #mobile_consnet AS c ON b.mobile = c.mobile 


DROP TABLE IF EXISTS #Final_list
SELECT a.*
	, CASE WHEN b.emailConsent IS NULL THEN 3 ELSE b.emailConsent END AS emailConsent
INTO #Final_list
FROM #mobile_consnet_list AS a
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
	, CASE WHEN [Sales Office ID] IN ('7060') THEN 'Store - Public Ιωάννινα'
		   WHEN [Sales Office ID] IN ('45221','45222','45232','45233','45244','45333','45332','45445','45444','45500','45570','44002','44003','44001','44010','44200','44100','44004','46100') THEN 'HD - Νομός Ιωαννίνων'
		   WHEN [Sales Office ID] IN ('46131','46030','46200','46300') THEN 'Νομός Θεσπρωτίας'
		   WHEN [Sales Office ID] IN ('47132','47131','47150','47041','47040','47045','47044','47043') THEN 'Νομός Άρτας'
		   WHEN [Sales Office ID] IN ('48100','48200','48060','48061','48062','48300') THEN 'Νομός Πρέβεζας'
		   WHEN [Sales Office ID] IN ('30131','30132','30133','30150') THEN 'Αγρίνιο'
	   ELSE 'Other' END AS Public_store
	, CASE WHEN ([mobileConsent] = 1 OR emailConsent = 1) THEN 'Has consent'
		   WHEN ([mobileConsent] = 0 OR  emailConsent = 0) THEN 'Has no consent'
		   WHEN ([mobileConsent] = 3 OR  emailConsent = 3) THEN 'No status'
		   ELSE 'Other' END AS flag
FROM #Final_list
WHERE 1=1







