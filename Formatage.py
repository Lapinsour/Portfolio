#!/usr/bin/env python
# coding: utf-8

# Certains tableaux de données peuvent être un peu arides. Voici comment les rendre plus lisibles.
# 

# In[17]:


import pandas as pd
import numpy as np


# In[18]:


#Création du DataFrame initial
df = pd.DataFrame(
{
'Mois':pd.date_range(
start = '01-01-2012',
end = '31-12-2022',
freq = 'MS'
),
'Visites_produits':np.random.randint(
low = 1_000_000,
high = 2_500_000,
size = 132
),
'Exemplaires_vendus':np.random.randint(
low = 300_000,
high = 500_000,
size = 132
),
'Revenus':np.random.randint(
low = 750_000,
high = 1_250_000,
size = 132
)
}
)


# In[19]:


#Création de nouvelles variables 
df['Conversion'] = df['Exemplaires_vendus']/df['Visites_produits']
df['Prix_unitaire'] = df['Revenus']/df['Exemplaires_vendus']


# In[45]:


#Création d'une ligne "TOTAL"

total = df.sum()
total['Mois'] = pd.NaT
total['Prix_unitaire'] = total['Revenus'] / total['Exemplaires_vendus']
total['Conversion'] = total['Exemplaires_vendus'] / total['Visites_produits']
total = total.to_frame().transpose()


#Style de la ligne "TOTAL"
def highlight_total(s):
    r = pd.Series(data = False,index = s.index)
    r['Mois'] = pd.isnull(s.loc['Mois'])

    return ['font-weight: bold' if r.any() else '' for v in r]


#Ajout de la ligne "TOTAL" à notre DataFrame
d = pd.concat([df,total],axis = 0)
d.reset_index(drop = True,inplace = True)


# In[56]:


#Création d'une fonction pour mettre en lumière certaines données
#Ici, les taux de conversion supérieurs à 30%

def highlight_ventes(s, ventes_threshold = 5):
    r = pd.Series(data = False,index = s.index)
    r['Mois'] = s.loc['Conversion'] > ventes_threshold

    return ['background-color: yellow' if r.any() else '' for v in r]


# In[57]:


#FORMATAGE
d.style.set_properties(**{'text-align':'center'}).apply(highlight_ventes, ventes_threshold = 0.3, axis=1).apply(highlight_total,axis = 1).format(
{
'Mois':'{:%B %Y}',
'Visites_produits':'{:,.0f}',
'Exemplaires_vendus':'{:,.0f}',
'Revenus':'{:,.0f}€',
'Conversion':'{:.2%}',
'Prix_unitaire':'{:,.2f}€'
},
na_rep = 'TOTAL'
)\
.hide_index()\
.set_caption('Données sur les ventes <br> créées par Pierre Garrigues')





# In[ ]:




