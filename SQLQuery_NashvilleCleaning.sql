--Nettoyage de donn�es en SQL queries

Select * 
From Nashville_DB.dbo.Sheet1$



--1.Formater la date

Alter Table Nashville_DB.dbo.Sheet1$ 
Alter Column SaleDate Date

Select SaleDate, CONVERT(Date,SaleDate)
From Nashville_DB.dbo.Sheet1$



--2.Remplacer les NULL de la colonne PropertyAdress

--Pour cela, on ajoute l'adresse d'un ParcelID � toutes les lignes qui ont le m�me ParcelID, mais une adresse NULL. 
Select PropertyAddress
From Nashville_DB.dbo.Sheet1$
Where PropertyAddress is null


--M�thode : JOIN la table sur elle-m�me (A,B) en rempla�ant les NULL de la table A par les adresses de la table B selon le ParcelID.
--Note : sur SQL Server, ISNULL prend 2 arguments et affiche la valeur du 2�me argument si le 1er est NULL.
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From Nashville_DB.dbo.Sheet1$ a
Join Nashville_DB.dbo.Sheet1$ b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ]<> b.[UniqueID ]



--3.S�parer l'adresse en plusieurs colonnes : Adresse, Ville, Etat

--M�thode 1 : le 1er Substring s�lectionne la colonne PropertyAddress � partir du 1er caract�re, jusqu'� l'index de ','-1, soit le caract�re pr�c�dent la virgule.
--Le 2� Substring s�lectionne PropertyAddress du caract�re suivant la virgule jusqu'� l'index du caract�re �gal � la longueur de la cha�ne, soit le dernier.

Alter Table Nashville_DB.dbo.Sheet1$ 
Add Adresse Nvarchar(255)
Update Nashville_DB.dbo.Sheet1$ 
Set Adresse = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table Nashville_DB.dbo.Sheet1$ 
Add Ville Nvarchar(255)
Update Nashville_DB.dbo.Sheet1$ 
Set Ville = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--M�thode 2 : utiliser Parsename, qui scinde une cha�ne de caract�res selon les points, en repla�ant les virgules par des points.

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

--On remarque que le "No" et "Yes" sont parfois �crits respectivement "N" et "Y". 

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