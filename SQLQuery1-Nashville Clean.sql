--Script for selecting top 1000 from ssms

Select TOP(1000) [UniqueID ],
[ParcelID],
[LandUse],
[PropertyAddress],
[SaleDate],
[SalePrice],
[LegalReference],
[soldasvacant],
[ownername],
[owneraddress],
[acreage],
[taxdistrict],
[landvalue],
[buildingvalue],
[totalvalue],
[yearbuilt],
[Bedrooms],
[fullbath],
[halfbath]


From [Portfolio Project].[dbo].[Nashville Housing]

--Cleaning data in sql
Select *
From [Portfolio Project].[dbo].[Nashville Housing]

Select SaleDateconverted, convert(Date, SaleDate)
From [Portfolio Project].[dbo].[Nashville Housing]

Update [Nashville Housing]
Set saledate = convert(Date, SaleDate)
Select Saledate
From [Portfolio Project].[dbo].[Nashville Housing]

Alter Table [Nashville Housing]
Add Saledateconverted Date;

--Needed to create new coloumn for date format

Update [Nashville Housing]
Set saledateconverted = convert(Date, SaleDate)

--Populate address data
Select *
From [Portfolio Project].[dbo].[Nashville Housing]
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress,  b.PropertyAddress)
From [Portfolio Project].[dbo].[Nashville Housing] a
Join [Portfolio Project].[dbo].[Nashville Housing] b
on a.parcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Removing nulls from property address
Update a
Set propertyaddress = isnull(a.propertyaddress,  b.PropertyAddress)
From [Portfolio Project].[dbo].[Nashville Housing] a
Join [Portfolio Project].[dbo].[Nashville Housing] b
on a.parcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Seperating Address into Address,City,State

Select PropertyAddress
From [Portfolio Project].[dbo].[Nashville Housing]
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', propertyAddress) +1, len(PropertyAddress)) as City
From [Portfolio Project].[dbo].[Nashville Housing]

Select Parsename(Replace(OwnerAddress, ',', '.'),3),
Parsename(Replace(OwnerAddress, ',', '.'),2),
Parsename(Replace(OwnerAddress, ',', '.'),1)

From [Portfolio Project].[dbo].[Nashville Housing]


--Creating new fields for location
Alter Table [Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Alter Table [Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Alter Table [Nashville Housing]
Add OwnerSplitState Nvarchar(255);


Update [Nashville Housing]
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'),3)



Update [Nashville Housing]
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'),2)

Update [Nashville Housing]
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'),1)

Select *
From [Portfolio Project].[dbo].[Nashville Housing]


Alter Table [Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyAddress) -1)


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', propertyAddress) +1, len(PropertyAddress)) as City
From [Portfolio Project].[dbo].[Nashville Housing]


--Change Y/N to Yes/No

Select Distinct(Soldasvacant), Count(SoldAsVacant)
From [Portfolio Project].[dbo].[Nashville Housing]
Group By SoldAsVacant
Order By 2


Select Soldasvacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
End
From [Portfolio Project].[dbo].[Nashville Housing]

Update [Nashville Housing]
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
End

--Remove Duplicates

With RowNumCTE as( 
Select *,
Row_Number() over(
Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by UniqueID) row_num
From [Portfolio Project].[dbo].[Nashville Housing]
)
Select *
From RowNumCTE
Where Row_Num > 1

--Delete unused coloumns

Select *
From [Portfolio Project].[dbo].[Nashville Housing]

Alter Table [Portfolio Project].[dbo].[Nashville Housing]
Drop Column  SaleDate
