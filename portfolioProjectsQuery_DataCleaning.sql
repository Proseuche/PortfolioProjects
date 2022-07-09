/* 

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProjects.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate
From PortfolioProjects.dbo.NashvilleHousing

Select SaleDate, CONVERT(Date, SaleDate) as Date
From PortfolioProjects.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------------------------

-- Populate Property Address

Select *
From PortfolioProjects.dbo.NashvilleHousing
--Where PropertyAddress is Null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
	Join PortfolioProjects.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
	Join PortfolioProjects.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null




----------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, State, City)

Select

SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

From PortfolioProjects.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




Select *
From PortfolioProjects.dbo.NashvilleHousing

--ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
--DROP COLUMN PropertySplitAddress, PropertySplitCity


Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing


Select
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
From PortfolioProjects.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field

select SoldAsVacant
From PortfolioProjects.dbo.NashvilleHousing


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
		CASE When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
			End
			
From PortfolioProjects.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)




------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE As (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
	ORDER BY UniqueID ) row_num

From PortfolioProjects.dbo.NashvilleHousing
--ORDER BY ParcelID
)


Delete
From RowNumCTE
Where row_num > 1
-- Order By PropertyAddress


--------------------------------------------------------------------------------------------------------------------------------------
-- Deleting Unused Colums

Select *
From PortfolioProjects.dbo.NashvilleHousing


Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop Column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict








































































































