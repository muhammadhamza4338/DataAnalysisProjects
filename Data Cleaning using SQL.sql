

select * from NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(date,saleDate)

alter table nashvillehousing
add saledateconverted date;

--alter table nashvillehousing
--drop column saledateconverted

update NashvilleHousing
set saledateconverted=CONVERT(date,saleDate)




-------Data insertion in property address

select a.parcelID,a.propertyaddress,b.parcelid,b.propertyaddress
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---Splitting the propertyaddress
select propertyaddress from NashvilleHousing

select 
SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1),
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))

from NashvilleHousing

--------------------------------------------
alter table nashvillehousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress=SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1)

-------------------------------------------
alter table nashvillehousing
add propertysplitcity nvarchar(255)

update NashvilleHousing
set propertysplitcity=SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

select * from NashvilleHousing


----spliting ownername column using ParseName instead of substring
----we replace , with . because parsename work with periods not commas

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)

from NashvilleHousing
-------------------------------------------
alter table nashvillehousing
add ownersplitaddress nvarchar(255);

update NashvilleHousing
set ownersplitaddress=PARSENAME(replace(owneraddress,',','.'),3)

------------------------------------------
alter table nashvillehousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity=PARSENAME(REPLACE(owneraddress,',','.'),2)

------------------------------------------
alter table nashvillehousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate=PARSENAME(replace(owneraddress,',','.'),1)


--select * from NashvilleHousing------------------------

select SoldAsVacant,count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select 
case 
when SoldAsVacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else SoldAsVacant
end
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant=
case 
when SoldAsVacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else SoldAsVacant
end


-------------------Remove Duplicates
--- we will remove duplicates by window function row_number 

---- we are not deleting data from actual table, we just make cte and store all duplicate there
---if we want to delete from cte then we will use delete instead of select in outer query of cte
with duplicateCTE as 
(
select *,
ROW_NUMBER() over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueID)row_num
from nashvillehousing
)
select *  from duplicateCTE where row_num>1


--------------------------deleting unused column
alter table nashvillehousing
drop column propertyaddress,owneraddress,taxdistrict,saledate



select * from NashvilleHousing