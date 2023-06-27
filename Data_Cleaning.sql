SELECT * 
FROM Data_Cleaning..NashvilleHousingData
--WHERE PropertyAddress IS NULL

--Satndardizing Sale Date

SELECT SaleDate, CONVERT(Date, Saledate) 
FROM Data_Cleaning..NashvilleHousingData

ALTER TABLE Data_Cleaning..NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE Data_Cleaning..NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address Data

SELECT PropertyAddress , *
FROM Data_Cleaning..NashvilleHousingData
--WHERE PropertyAddress  IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_Cleaning..NashvilleHousingData a
JOIN  Data_Cleaning..NashvilleHousingData b
	  ON a.ParcelID = b.ParcelID 
	  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

--Updating the NULL value columns

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_Cleaning..NashvilleHousingData a
JOIN  Data_Cleaning..NashvilleHousingData b
	  ON a.ParcelID = b.ParcelID 
	  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL


--Breaking the address into indivisual Columns (Address, City)

-- For the property address

SELECT PropertyAddress
FROM Data_Cleaning..NashvilleHousingData
-- WHERE PropertyAddress NOT LIKE '%,%' 
-- All the address have a ',' in it as a delimiter

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +2, CHARINDEX(',', PropertyAddress)) as City
FROM Data_Cleaning..NashvilleHousingData


ALTER TABLE Data_Cleaning..NashvilleHousingData
ADD Address Nvarchar(255);
ALTER TABLE Data_Cleaning..NashvilleHousingData
ADD City Nvarchar(255);

UPDATE Data_Cleaning..NashvilleHousingData
SET Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

UPDATE Data_Cleaning..NashvilleHousingData
SET City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +2, CHARINDEX(',', PropertyAddress)) 

--For the owner address

SELECT OwnerAddress 
FROM Data_Cleaning..NashvilleHousingData

SELECT 
PARSENAME(Replace(OwnerAddress, ',', '.') ,3),
PARSENAME(Replace(OwnerAddress, ',', '.') ,2),
PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
FROM Data_Cleaning..NashvilleHousingData

ALTER TABLE Data_Cleaning..NashvilleHousingData
ADD OwnerSeperatedAddress Nvarchar(255);

ALTER TABLE Data_Cleaning..NashvilleHousingData
ADD OwnerCity Nvarchar(255);

ALTER TABLE Data_Cleaning..NashvilleHousingData
ADD OwnerState Nvarchar(255);

UPDATE Data_Cleaning..NashvilleHousingData
SET OwnerSeperatedAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

UPDATE Data_Cleaning..NashvilleHousingData
SET OwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

UPDATE Data_Cleaning..NashvilleHousingData
SET OwnerState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)


-- Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM  Data_Cleaning..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT  SoldAsVacant,
		Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
FROM  Data_Cleaning..NashvilleHousingData

Update Data_Cleaning..NashvilleHousingData
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


-- Removing the Duplicates

WITH RowNumCTE AS(
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

FROM Data_Cleaning..NashvilleHousingData
--ORDER BY ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-- Delete unused columns

ALTER TABLE Data_Cleaning..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-- Final Data

SELECT *
FROM Data_Cleaning..NashvilleHousingData

-- Saved the file as a CVS 