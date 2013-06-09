/*********************************************
 * OPL 12.5 Model
 * Author: vansteen
 * Creation Date: 26 mai 2013 at 15:09:49
 *********************************************/

int nbSemaines = ...;
range Semaines = 1..nbSemaines;
int tempsDeTravailMaxParSemaine = ...;

{string} Produits = ...;
tuple ProduitData {
 	float prixUnitaire;
 	float coutStockageUnitaire;
 	float tempsDeTravail;
 	float quantiteInitiale; 
}; 
ProduitData produit[Produits] = ...;

{string} Lignes = ...;
tuple LigneData {
  	float tempsdeTestMaxParSemaine;
 	float coutFixe;
 	float coutUnitaire;
}; 
LigneData ligne[Lignes] = ...;

{string} produitsAssocies[Lignes] = ...;

float quantiteMax[Produits,Semaines] = ...;

dvar int+ production[Produits,Semaines];
dvar int+ ventes[Produits,Semaines];
dvar boolean ligneUtilisee[Lignes,Semaines];
dvar boolean ligneAUtilisee[Semaines];
 
dexpr float coutStockage = sum (p in Produits, t in Semaines) produit[p].coutStockageUnitaire * (production[p,t] - ventes[p,t] + produit[p].quantiteInitiale);
dexpr float chiffreAffaire = sum (p in Produits, t in Semaines) produit[p].prixUnitaire * ventes[p,t];
dexpr float coutUtilisation = sum (t in Semaines, l in Lignes) ligne[l].coutFixe*ligneUtilisee[l][t] + sum (t in Semaines, l in Lignes, p in produitsAssocies[l]) (production[p,t] * ligne[l].coutUnitaire);
 
maximize chiffreAffaire - (coutStockage + coutUtilisation);
subject to {
  	 forall (t in Semaines){
  	   	ctTempsTravail : 
  	   		sum (p in Produits) (production[p,t] * produit[p].tempsDeTravail) <= tempsDeTravailMaxParSemaine;
  	   		
  	   	sum (p in produitsAssocies["A"]) production[p,t] <= ligne["A"].tempsdeTestMaxParSemaine - 20 * ligneAUtilisee[t];
	     
	    (production["alpha"][t] >= 1 && production["beta"][t] >= 1) == ligneAUtilisee[t];
  	   		
      }  	   		
  	  
  	  forall (t in Semaines, l in Lignes){ 	
  	    ctTempsTest:
  	    	sum (p in produitsAssocies[l]) production[p,t] <= ligne[l].tempsdeTestMaxParSemaine;
  	    	
	     (sum (p in produitsAssocies[l]) production[p,t] >= 1) == ligneUtilisee[l][t];
	     
	  forall (t in Semaines, p in Produits){
	    	ventes[p,t] >= 20;
	     	ventes[p,t] <= quantiteMax[p,t]; 
	      	ventes[p,t] <= production[p,t] + (produit[p].quantiteInitiale + sum (s in Semaines : s < t) ( production[p,s] - ventes[p,s] ));
   		}	  
   		
   	                
    }	  
 };
 
//Display the plan for each month and each raw material
//plan[m][j] = <Buy[j][m], Use[j][m], Store[j][m]>
execute DISPLAY {
   for (var t in Semaines)
      for (var p in Produits)
         writeln("Temps de travail semaine ",t,": ",production[p][t] * produit[p].tempsDeTravail);
}