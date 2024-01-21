SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date formate

SELECT SaleDateConverted, CONVERT (Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate property address
--SELECT *
--FROM PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out addy into individual columns
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
-- Looking at address starting at the very first value and going to the first comma. 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing
 -- Doing what is stated above while mentioning the position of the comma
 SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
 CHARINDEX(',', PropertyAddress)
 FROM PortfolioProject.dbo.NashvilleHousing
--Removing the comma
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
FROM PortfolioProject.dbo.NashvilleHousing
--Going to the comma but we add 1 specifying where it needs to finish, showing address 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing
--Two new values add in data called "PropertyCityAddress" and "PropertySplitAddress"
ALTER TABLE NashvilleHousing
Add PropertySplitAddress NvarChar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NvarChar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--SELECT *
--FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing
--Broken out into 3 columns ez way compared to substrings 
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NvarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NvarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NvarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--SELECT *
--FROM PortfolioProject.dbo.NashvilleHousing


--Change Y and N to YEs and No in "sold as vacant" field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2
--UPDATE Statement
SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   Else SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   Else SoldAsVacant
	   END

--Remove DUPES
WITH RowNumCTE AS(
 SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
		UniqueID) 
		row_num

 FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

 -- DELETE unused columns
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

