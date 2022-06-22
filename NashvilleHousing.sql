SELECT * 
FROM PortfolioProject..NashvilleHousing

-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data
SELECT*
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null
order by ParcelID

Select a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select OwnerAddress
from PortfolioProject..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes' When SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = 
 CASE When SoldAsVacant = 'Y' THEN 'Yes' When SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates 

With rownumCTE as(
 SELECT * , 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) rownum

 FROM PortfolioProject..NashvilleHousing
 )
 --order by ParcelID
DELETE
 from rownumCTE
 where rownum > 1

 -- Delete Unused Columns
 Select * 
 from PortfolioProject..NashvilleHousing


 Alter table PortfolioProject..NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 
 Alter table PortfolioProject..NashvilleHousing
 DROP COLUMN SaleDate