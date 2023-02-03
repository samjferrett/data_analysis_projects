-- Data cleaning of housing dataset

SELECT *
FROM PortfolioProject..NashvilleHousing

--Task 1: Change Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Task 2: Populate NULLS in property address data 
-- Join table to itself and where ParcelIDs are the same copy Property Address

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Task 3: Creating Address, City, State separate columns

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


-- Task 4: Split Owner address

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- Task 5: Change Y and N to Yes and No in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Task 6: Remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Task 7: Delete Unneeded Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

