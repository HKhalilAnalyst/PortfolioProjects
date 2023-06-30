SELECT * 
FROM [Portfolio Project]..NashvilleHousing


-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(date, Saledate) 
FROM [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, Saledate) 

ALTER TABLE NashvilleHousing
add SaleDateConverted date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, Saledate) 



-- Populate Property Address Data

SELECT *
FROM [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND  a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND  a.[UniqueID ] != b.[UniqueID ]



-- Breaking Out Address into Individual Coloumns (Address, City, State) 

SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress)+1, LEN(PropertyAddress))  As Address
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1)

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM [Portfolio Project]..NashvilleHousing

SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(Soldasvacant), COUNT(Soldasvacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY Soldasvacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END 
FROM [Portfolio Project]..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	     END 


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

From [Portfolio Project]..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns



Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

