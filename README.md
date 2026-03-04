# StudentSaver & Health (tijdelijke naam)
> De slimme budget-coach die studenten helpt gezond te eten zonder rood te staan.

## Projectomschrijving
Veel studenten vallen terug op ongezonde kant-en-klaarmaaltijden omdat ze denken dat gezond koken te duur of te tijdrovend is. **StudentSaver & Health** is een mobiele applicatie die dit probleem oplost. De app fungeert als een intelligente assistent die je voorraadkast beheert, je resterende weekbudget bewaakt en recepten voorstelt op basis van de laagste prijs en hoogste voedingswaarde.

Deze app onderscheid zich door data-intelligentie in plaats van passieve opslag:

* **Budget & Health Optimalisatie:** De app berekent een 'Value-for-Money' score. Het adviseert bijvoorbeeld om kip te vervangen door linzen als je proteïne nodig hebt maar je budget laag is.
* **Smart Inventory:** Door gebruik te maken van de **OpenFoodFacts API** wordt na invoer (via barcode of zoekopdracht) direct de Nutri-Score en houdbaarheid gekoppeld.
* **Simulated IoT/Hardware:** De app simuleert een koppeling met een slimme voorraadkast (via dummy data) die waarschuwt wanneer essentiële producten opraken.
* **Proactieve Notificaties:** Slimme herinneringen op basis van vervaldata om voedselverspilling (en dus geldverspilling) tegen te gaan.

## API Integraties & Technologie
Om de "Smart" functies te realiseren, maakt de app gebruik van de volgende krachtige API's:

### Spoonacular API (Het Brein)
De Spoonacular API wordt gebruikt als de centrale engine voor maaltijd- en prijslogica. De belangrijkste functies binnen deze app zijn:
* **Recipe by Ingredients:** Zoekt recepten op basis van wat de student nog in zijn pantry heeft liggen (`findByIngredients`) om extra uitgaven te minimaliseren.
* **Price Breakdown:** Haalt de geschatte kosten per ingrediënt en per totale maaltijd op om te controleren of het binnen het resterende weekbudget past.
* **Nutritional Analysis:** Geeft gedetailleerde info over macro-nutriënten (proteïnen, koolhydraten, vetten) voor het Health Dashboard.
* **Ingredient Substitutes:** Stelt goedkopere of gezondere alternatieven voor als een ingrediënt ontbreekt of te duur is.

### OpenFoodFacts API
* Wordt gebruikt voor het razendsnel ophalen van productinformatie, allergenen en de **Nutri-Score** bij het scannen of toevoegen van voorraad.

## Belangrijkste Functionaliteiten
1.  **Digital Pantry:** Houd bij wat je op voorraad hebt. Producten kunnen handmatig of via een (gesimuleerde) scan worden toegevoegd.
2.  **Live Budget Tracker:** Stel een weekbudget in. De app berekent je 'daily spendable' op basis van je uitgaven.
3.  **Smart Recipe Matcher:** Ontvang receptsuggesties voor maaltijden waarvoor je de meeste ingrediënten al in huis hebt.
4.  **Health Dashboard:** Krijg inzicht in de gemiddelde Nutri-Score van je huidige voorraad en je consumptie.