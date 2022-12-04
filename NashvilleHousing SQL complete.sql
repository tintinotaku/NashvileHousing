-- LOOK THE DATA
select * from Nashvillehousing

------------------------------------------------------------------------------------------------------------------------
-- CONVERT SALEDATE

select SaleDate
from Nashvillehousing

alter table Nashvillehousing
	add sale_date_converted date

update Nashvillehousing
set sale_date_converted = convert(date, SaleDate)

-- DOUBLECHECK THE RESULT
select * from Nashvillehousing

------------------------------------------------------------------------------------------------------------------------
-- CHECK THE MISSING DATA IN PROPERTYADDRESS
select a.[UniqueID ],a.ParcelID, a. PropertyAddress, b.[UniqueID ],b.ParcelID, b.PropertyAddress
from Nashvillehousing a join Nashvillehousing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- FILL THE DATA IN PROPERTYADDRESS

update a 
set PropertyAddress = ISNULL(a. PropertyAddress, b.PropertyAddress)
from Nashvillehousing a join Nashvillehousing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--DOUBLECHECK THE RESUTL
select PropertyAddress
from Nashvillehousing
where PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------
-- BREAKING OUT PROPERTYADDRESS INTO INDIVIDUAL COLUMNS
select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
from Nashvillehousing

-- UPDATE TABLE
alter table Nashvillehousing
	add property_address_splited varchar(255)

update Nashvillehousing
set property_address_splited =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

alter table Nashvillehousing
	add property_city_splited varchar(255)

update Nashvillehousing
set property_city_splited=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- DOUBLECHECK
select * from Nashvillehousing

------------------------------------------------------------------------------------------------------------------------
--BREAKING OUT OWNERADDRESS INTO INDIVIDUAL COLUMNS
select PARSENAME(replace(OwnerAddress, ',', '.') , 3) as owner_address,
PARSENAME(replace(OwnerAddress, ',', '.') , 2) as owner_city,
PARSENAME(replace(OwnerAddress, ',', '.') , 1) as owner_state
from Nashvillehousing

-- UPDATE TABLE
alter table Nashvillehousing
	add owner_address varchar(255)

update Nashvillehousing
set owner_address =  PARSENAME(replace(OwnerAddress, ',', '.') , 3)

alter table Nashvillehousing
	add owner_city varchar(255)
go

update Nashvillehousing
set owner_city =  PARSENAME(replace(OwnerAddress, ',', '.') , 2)
go

alter table Nashvillehousing
	add owner_state varchar(255)
go

update Nashvillehousing
set owner_state =  PARSENAME(replace(OwnerAddress, ',', '.') , 1)
go

-- DOUBLECHECK
select * from Nashvillehousing

------------------------------------------------------------------------------------------------------------------------
-- CHANGE Y AND N TO YES AND NO IN SOLD_AS_VACANT

-- TAKE A LOOK OF THE PRIOR DATA

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from Nashvillehousing

-- UPDATE DATA

update Nashvillehousing
set SoldAsVacant =
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from Nashvillehousing

-- DOUBLECHECK
select SoldAsVacant, COUNT(SoldAsVacant)
from Nashvillehousing
group by SoldAsVacant

------------------------------------------------------------------------------------------------------------------------
-- USE ROW_NUMBER FUNCTION TO VISUALIZE THE DUPLICATE DATA
with a as (
select *, ROW_NUMBER() over (partition by ParcelID,			
										  PropertyAddress,
										  SaleDate,
										  SalePrice,
										  LegalReference
										  order by UniqueID) as row_num
										
from Nashvillehousing
)

-- THIS IS ALL THE DUPLICATE DATA (DEFINE BY ROW_NUM "2")
SELECT * from a
where a.row_num > 1


-- DELETE ALL DUPLICATE DATA
delete
from a 
where a.row_num > 1

------------------------------------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS
select * from Nashvillehousing

alter table Nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
