/* 

 DATA CLEANING

 */

 Select *
 from PortfolioProject..NashvilleHousing

-- Stanardize date format

 Select SaleDate,CONVERT(DATE,SaleDate) as std_date
 from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate=Convert(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDateCoverted Date;

update PortfolioProject..NashvilleHousing
set SaleDateCoverted=Convert(Date,SaleDate)


--Property Address

 Select PropertyAddress
 from PortfolioProject..NashvilleHousing
 --where propertyaddress is null
 order by ParcelID --[it seems parcelid=property address]

  Select a.ParcelID,b.parcelid,a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
     on a.parcelID=b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 Where a.PropertyAddress is null


update a
set PropertyAddress=ISNULL(a.propertyAddress,b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
 on a.parcelID=b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null



 --Breaking out address into Indivisual columns*address,city,state)


 Select PropertyAddress
 from PortfolioProject..NashvilleHousing

 select 
 substring(propertyAddress,1,charindex(',',PropertyAddress)-1) as address
 , substring(propertyAddress,charindex(',',PropertyAddress)+1,Len(PropertyAddress)) as address
from PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing


--change Y AND N TO YES AND NO


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
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

From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject..NashvilleHousing


-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

