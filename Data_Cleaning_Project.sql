/*
 Cleaning data in SQL Queries
 */

select * from PortfolioProject.dbo.NashvilleHousing;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize date format

select SaleDate from .PortfolioProject.dbo.NashvilleHousing;

select SaleDate, convert(date, SaleDate) from PortfolioProject..NashvilleHousing;

Update NashvilleHousing
set SaleDate = cast(SaleDate as Date) from PortfolioProject..NashvilleHousing;

-- If it doesn't Update properly

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select * from PortfolioProject..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking Out Address into Individual Colulmns (Address , City , State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID;

select 
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));

select OwnerAddress from PortfolioProject..NashvilleHousing;

select 
OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(replace(OwnerAddress,',','.'),2) as City,
PARSENAME(replace(OwnerAddress,',','.'),1) as State
from PortfolioProject..NashvilleHousing;


alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1);


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant, 
           case
		   when SoldAsVacant= 'Y' then 'Yes'
		   when SoldAsVacant='N' then 'No'
		   else SoldAsVacant
		   end
from PortfolioProject..NashvilleHousing;

Update PortfolioProject..NashvilleHousing
set SoldAsVacant =  case
		   when SoldAsVacant= 'Y' then 'Yes'
		   when SoldAsVacant='N' then 'No'
		   else SoldAsVacant
		   end;

select * from PortfolioProject..NashvilleHousing;

select distinct(SoldAsVacant), count(*)
from PortfolioProject..NashvilleHousing										
group by SoldAsVacant;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
select *,
                ROW_NUMBER() OVER (
				Partition by ParcelID,
				                      PropertyAddress,
									  SalePrice,
									  LegalReference
									  order by UniqueID )
									  row_num
from PortfolioProject..NashvilleHousing
)

delete
from RowNumCTE
where row_num > 1
-- order by PropertyAddress


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, PropertyAddress, SaleDate;

