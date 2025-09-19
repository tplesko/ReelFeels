# ReelFeels 🎬

ReelFeels je iOS aplikacija za praćenje filmova i serija kroz osobne dojmove i interakciju s prijateljima.  
Korisnici mogu dijeliti osjećaje nakon gledanja, pratiti vlastiti dnevnik gledanja, skupljati streakove i izazivati prijatelje na zajedničko gledanje.

## Funkcionalnosti
- Registracija i prijava korisnika (Firebase Auth)
- Objave: dodavanje javnih i privatnih postova s emocijama, opisom i TMDB posterom
- Reakcije: lajkovi i komentari na objave
- Dnevnik gledanja: unos sadržaja, praćenje dana gledanja i streakova
- Prijatelji: dodavanje prijatelja putem e-maila i pregled njihovih javnih objava
- Izazovi: izazovi između prijatelja (npr. zajedničko gledanje serije/filma) uz praćenje napretka
- TMDB integracija: pretraga filmova i serija uz autocomplete i postere

## Tehnologije
- SwiftUI
- MVVM arhitektura
- Firebase (Auth, Firestore, Storage)
- The Movie Database (TMDB) API za filmove i serije
- AsyncImage i Combine za rad s mrežnim podacima
