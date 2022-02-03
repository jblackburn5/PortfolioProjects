--- Cleaning Data in SQL Queries ---

/* 

This data was derived from Github through AlexTheAnalyst with full permissions to use and follow along with the queries.

*/


Select * 
From NashvilleHousing

-------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate) -- for some reason this method did not work so we used the below method


Alter Table NashvilleHousing
Add SaleDate2 Date; 

Update NashvilleHousing
Set SaleDate2 = CONVERT(Date,SaleDate)



--------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


Select *
From NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-----------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





Select OwnerAddress   --Separating the address, city, and state for the owneraddress. This an easer method than what we did above for the proeprty address.
From NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.') , 3)
,Parsename(Replace(OwnerAddress, ',', '.') , 2)
,Parsename(Replace(OwnerAddress, ',', '.') , 1)
From NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.') , 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.') , 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.') , 1)




------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in :Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End




-----------------------------------------------------------------------------------------


-- Remove Duplicates

With RowNumCTE As(
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
From NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress



----------------------------------------------------------------------------------------


-- Delete Unused Columns



Select *
From NashvilleHousing


Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate



