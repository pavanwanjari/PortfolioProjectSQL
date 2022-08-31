drop table if exists HousingData;
-- create table
create table HousingData(
UniqueID int,
	ParcelID varchar(50),
	LandUse varchar(50),
	PropertyAddress	varchar(100),
	SaleDate date,
	SalePrice float,
	LegalReference varchar(50),
	SoldAsVacant varchar(10),
	OwnerName varchar(100),
	OwnerAddress varchar(200),
	Acreage	float,
	TaxDistrict varchar(100),
	LandValue	float,
	BuildingValue float,
	TotalValue float,
	YearBuilt int,
	Bedrooms int,
	FullBath	int,
	HalfBath int
);

-- import dataset
copy HousingData from 'C:\Users\Pavan\Desktop\SQL\Project5\Nashville Housing Data.csv' with CSV HEADER encoding 'windows-1251'


/*
Cleaning Data in SQL Queries
*/


Select *
From HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Update HousingData
SET saledate = Cast(saledate as Date)

-- If it doesn't Update properly

--ALTER TABLE NashvilleHousing
--Add SaleDateConverted Date;


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From HousingData
Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
---ISNULL(a.PropertyAddress,b.PropertyAddress),
 COALESCE(a.PropertyAddress,b.PropertyAddress,'Empty') -- for postgresql 
From HousingData a
JOIN HousingData b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


Update HousingData
SET PropertyAddress = COALESCE(a.PropertyAddress,b.PropertyAddress,'Empty')
From HousingData as a
JOIN HousingData as b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From HousingData
--Where PropertyAddress is null
--order by ParcelID



SELECT
SUBSTRING(PropertyAddress, 1, strpos(PropertyAddress,',' )-1 ) as Address 
, SUBSTRING(PropertyAddress, strpos(PropertyAddress,',') +2  , length(PropertyAddress)) as Address

From HousingData

-- for sql serever
'''
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From HousingData
'''

ALTER TABLE HousingData
Add PropertySplitAddress varchar(255);

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, strpos(PropertyAddress, ',') -1 );


ALTER TABLE HousingData
Add PropertySplitCity varchar(255);

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, strpos(PropertyAddress,',') + 2 , length(PropertyAddress));




Select *
From HousingData;





Select OwnerAddress
From HousingData;


Select
split_part(OwnerAddress,', ', 3),
split_part(OwnerAddress,', ', 2)
,split_part(OwnerAddress,',', 1)
From HousingData

-- for sql server 
'''
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From HousingData
'''


ALTER TABLE HousingData
Add OwnerSplitAddress varchar(255);

Update HousingData
SET OwnerSplitAddress = split_part(OwnerAddress,', ', 1);


ALTER TABLE HousingData
Add OwnerSplitCity varchar(255);

Update HousingData
SET OwnerSplitCity = split_part(OwnerAddress,', ', 2);



ALTER TABLE HousingData
Add OwnerSplitState varchar(255);

Update HousingData
SET OwnerSplitState = split_part(OwnerAddress,', ', 3);



Select *
From HousingData




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From HousingData


Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From HousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From HousingData




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From HousingData;


ALTER TABLE HousingData
DROP COLUMN owneraddress, 
DROP COLUMN taxdistrict, 
DROP COLUMN propertyaddress, 
DROP COLUMN saledate;







-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

