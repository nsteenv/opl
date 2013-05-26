/*********************************************
 * OPL 12.5 Model
 * Author: vansteen
 * Creation Date: 26 mai 2013 at 15:09:49
 *********************************************/

int nbSemaines = ...;
range Semaines = 1..nbSemaines;

{string} Produits = ...;
tuple ProduitData {
 	int price;
 	int coutStockage;
 	int tempsDeTravail;
 	int quantiteInitiale; 
}; 

ProduitData produit[Produits] = ...;

 float quantiteMax[Produits,Semaines] = ...;
 
 dvar int+ production[Produits,Semaines];
 dvar int+ ventes[Produits,Semaines];
 
 dexpr int coutStockage = sum (p in Produits, t in Semaines) produit[p].coutStockage * (production[p,t] - ventes[p,t] + produit[p].quantiteInitiale);
 dexpr int chiffreAffaire = sum (p in Produits, t in Semaines) (produit[p].price * ventes[p,t]);
 
 maximize chiffreAffaire - coutStockage;
 subject to {

  	 forall (t in Semaines){
  	   	sum (p in Produits) (production[p,t] * produit[p].tempsDeTravail) <= 2000;
     }
     
     forall (t in Semaines) {
       	production["alpha",t] + production ["beta",t] <= 120;
       	production["gamma",t] <= 48;
      }       	
      
     forall (p in Produits, t in Semaines) {
      	ventes[p,t] >= 20;
      	ventes[p,t] <= quantiteMax[p,t]; 
      	ventes[p,t] <= production[p,t] + (produit[p].quantiteInitiale + sum (s in Semaines : s < t) ( production[p,s] - ventes[p,s] ));
     }     
 };   