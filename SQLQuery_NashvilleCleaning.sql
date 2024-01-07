--Nettoyage de données en SQL queries

Select * 
From Nashville_DB.dbo.Sheet1$



--1.Formater la date

Alter Table Nashville_DB.dbo.Sheet1$ 
Alter Column SaleDate Date

Select SaleDate, CONVERT(Date,SaleDate)
From Nashville_DB.dbo.Sheet1$



--2.Remplacer les NULL de la colonne PropertyAdress

--Pour cela, on ajoute l'adresse d'un ParcelID à toutes les lignes qui ont le même ParcelID, mais une adresse NULL. 
Select PropertyAddress
From Nashville_DB.dbo.Sheet1$
Where PropertyAddress is null


--Méthode : JOIN la table sur elle-même (A,B) en remplaçant les NULL de la table A par les adresses de la table B selon le ParcelID.
--Note : sur SQL Server, ISNULL prend 2 arguments et affiche la valeur du 2ème argument si le 1er est NULL.
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From Nashville_DB.dbo.Sheet1$ a
Join Nashville_DB.dbo.Sheet1$ b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ]<> b.[UniqueID ]



--3.Séparer l'adresse en plusieurs colonnes : Adresse, Ville, Etat

--Méthode 1 : le 1er Substring sélectionne la colonne PropertyAddress à partir du 1er caractère, jusqu'à l'index de ','-1, soit le caractère précédent la virgule.
--Le 2è Substring sélectionne PropertyAddress du caractère suivant la virgule jusqu'à l'index du caractère égal à la longueur de la chaîne, soit le dernier.

Alter Table Nashville_DB.dbo.Sheet1$ 
Add Adresse Nvarchar(255)
Update Nashville_DB.dbo.Sheet1$ 
Set Adresse = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table Nashville_DB.dbo.Sheet1$ 
Add Ville Nvarchar(255)
Update Nashville_DB.dbo.Sheet1$ 
Set Ville = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Méthode 2 : utiliser Parsename, qui scinde une chaîne de caractères selon les points, en replaçant les virgules par des points.

Alter Table Nashville_DB.dbo.Sheet1$ 
Add 
Adresse_Owner Nvarchar(255)
,Ville_Owner Nvarchar(255)
,Etat_Owner Nvarchar(255)

Update Nashville_DB.dbo.Sheet1$ 
Set Adresse_Owner = Parsename(Replace(OwnerAddress,',','.'),3) 
	,Ville_Owner= Parsename(Replace(OwnerAddress,',','.'),2)
	,Etat_Owner = Parsename(Replace(OwnerAddress,',','.'),1) 

Select * from Nashville_DB.dbo.Sheet1$ 


--4.Standardiser les valeurs de la colonne "SoldAsVacant"

--On remarque que le "No" et "Yes" sont parfois écrits respectivement "N" et "Y". 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_DB.dbo.Sheet1$ 
Group By SoldAsVacant


Update Nashville_DB.dbo.Sheet1$
Set SoldAsVacant =Case When SoldAsVacant = 'Y' Then 'Yes'
					   When SoldAsVacant = 'N' Then 'No'
					   Else SoldAsVacant
					   End




--5.Supprimer les doublons


With Row_num_Table as(
Select *,
Row_number() Over (
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
				Order by UniqueID) as row_num
From Nashville_DB.dbo.Sheet1$ 
)


Select * 
From Row_num_Table
Where row_num > 1


--6.Supprimer les colonnes inutiles
Alter Table Nashville_DB.dbo.Sheet1$ 
Drop Column OwnerAddress,
			TaxDistrict,
			PropertyAddress


Select *
From Nashville_DB.dbo.Sheet1$ 