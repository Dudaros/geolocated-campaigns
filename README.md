# geolocated-campaigns
Requests that include specific Stores and related Postal Codes, that return mobile numbers and emails

# Customer Analytics Data Processing Script

## Overview
This SQL script processes customer data and consent information for various sales channels in specific geographic regions of Greece. It focuses on analyzing customer interactions across different store locations and order channels while tracking consent status for communications.

## Prerequisites
- Access to the following databases:
  - CustomerAnalytics
  - DW_PRD
  - WEBDATA

## Main Features
1. Customer Order Channel Analysis
2. Geographic Location Processing
3. Communication Consent Status Tracking
4. Customer Basic Information Integration

## Detailed Process Flow

### 1. Order Channel Data Collection
The script creates several temporary tables to categorize orders by channel:

- **Physical Store Orders** (`#physical_store_iwannina`)
  - Captures off-the-shelf orders from physical stores
  - Filters for sales office ID starting with '7060'
  - Data from 2019 onwards

- **Store Courier Orders** (`#store_courier_iwannina`)
  - Processes webservice/store orders delivered via courier
  - Includes specific sales office filtering

- **Store Pickup Orders** (`#store_store_iwannina`)
  - Handles webservice/store orders with store pickup
  - Maintains consistent filtering criteria

- **Web Orders** (`#web_iwannina`)
  - Processes web orders with store pickup option
  - Excludes webservice and store channels

### 2. Geographic Data Processing
- Creates `#tmp_hd` table for postal code mapping
- Covers specific postal codes in various regions
- Integrates shipping address information

### 3. Consent Management
- Processes mobile consent information (`#mobile_consent`)
- Handles email consent status
- Integrates with customer basic information

### 4. Final Output
The script generates a comprehensive dataset including:
- Customer identification details
- Store location information
- Communication consent status
- Geographic categorization
- Contact information

## Output Fields
- OneCustomer ID
- Sales Office ID
- created_at
- mail
- mobile
- name
- surname
- type
- value
- NEXT_ID
- mobileConsent
- emailConsent
- Public_store (categorized by region)
- flag (consent status)

## Geographic Regions Covered
- Store - Public Ιωάννινα
- HD - Νομός Ιωαννίνων
- Νομός Θεσπρωτίας
- Νομός Άρτας
- Νομός Πρέβεζας
- Αγρίνιο

## Consent Status Categories
- Has consent
- Has no consent
- No status
- Other

## Performance Considerations
- Uses NOLOCK hints for read operations
- Implements temporary tables for improved performance
- Includes specific indexing strategies

## Usage Notes
1. Ensure appropriate database access permissions
2. Verify date ranges (currently set from 2019 onwards)
3. Check for valid country ID (set to '0070')
4. Monitor temporary table usage in high-concurrent environments

## Maintenance
- Regular cleanup of temporary tables is recommended
- Periodic validation of postal code lists
- Review of consent status logic as per business requirements

## Dependencies
- CustomerAnalytics.forecast.factOneCustomerSales_new
- CustomerAnalytics.customer.Customer_Consent_DB
- CustomerAnalytics.customer.BasicInfo
- DW_PRD.dw.nexus_fact_order_lines
- WEBDATA.web.DOCUMENT_HEADER


