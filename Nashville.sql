/*

DATA Cleaning in SQL

*/

Select * from dbo.Nashville;


---- Standardize Sale Date -- Remove timestamp

Alter Table Nashville
Add SaleDateConverted Date;

Update Nashville
Set SaleDate2 = Cast(SaleDate as Date);

Select SaleDate2 from dbo.Nashville;

-- exec sp_rename 'Nashville.SaleDateConverted', 'SaleDate2';


-------------------------------------------
----- Populate Property	Address Data -----

select * 
from dbo.Nashville
-- where PropertyAddress is Null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.Nashville a
join dbo.Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ] -- combination of parcelID & UniqueID
where a.PropertyAddress is  null;

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.Nashville a
Join dbo.Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


----------------------------------------------------------------------

---- Breaking Address into Individual Columns (Address, City, State)

Select 
Substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, CharIndex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from dbo.Nashville


Alter Table Nashville
Add Property_Address NVarchar(255);

Update Nashville
SET Property_Address = SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress) -1)

Alter Table Nashville
Add PropertyCity NVarchar(255);

Update Nashville
SET PropertyCity = SUBSTRING(PropertyAddress, CharIndex(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
from Nashville

---- Owner Address ----

Select 
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
from Nashville

Alter Table Nashville
Add Owner_Address NVarchar(255);

Update Nashville
SET Owner_Address = ParseName(Replace(OwnerAddress, ',', '.'), 3)

Alter Table Nashville
Add OwnerCity NVarchar(255);

Update Nashville
SET OwnerCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

Alter Table Nashville
Add OwnerState NVarchar(255);

Update Nashville
SET OwnerState = ParseName(Replace(OwnerAddress, ',', '.'), 1)

---- ------------------------------------------------------------

---- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Nashville

Update Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

----------------------------------------------------------------

---- Remove Duplicates ----

WITH RowNumCTE AS
(Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				   ) row_num
FROM Nashville
)

Select *
FROM RowNumCTE
Where row_num > 1


-------------------------------------------------
-

---- 

Alter Table	Nashville
Drop Column OwnerAddress, TaxDistrict, PropertyAddress 

Alter Table	Nashville
Drop Column SaleDate

Select * from Nashville


















-- group by - reduces noof rows by rolling them up
-- partition by - does not affect nof rows