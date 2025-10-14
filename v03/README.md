# v03
Manually generated README for v03

Stand in `HLF25-2\v03` and type `dart run`

This creates a little sqlite db (`v03.db`) that contains a simple table `heroes` with the following structure:

  ```id TEXT PRIMARY KEY,
     version INTEGER NOT NULL,
     server_id TEXT NOT NULL,
     name TEXT NOT NULL,
     intelligence INTEGER NULL,
     strength INTEGER NULL,
     speed INTEGER NULL,
     durability INTEGER NULL,
     power INTEGER NULL,
     combat INTEGER NULL,
     full_name TEXT NULL,
     alter_egos TEXT NULL,
     aliases TEXT NULL,
     place_of_birth TEXT NULL,
     first_appearance TEXT NULL,
     publisher TEXT NULL,
     alignment TEXT NOT NULL,
     gender TEXT NOT NULL,
     race TEXT NULL,
     height TEXT NULL,
     weight TEXT NULL,
     eye_color TEXT NULL,
     hair_color TEXT NULL,
     occupation TEXT NULL,
     base TEXT NULL,
     group_affiliation TEXT NULL,
     relatives TEXT NULL,
     image_url TEXT NULL
```

The `id` is a `Uuid`, `gender` and `alignment` are mapped from enums. `server_id` is mapped from the field `id` in the `Hero` dto. The column `aliases` stores an encoded JSON-array as I couldn't be bothered to create another table.

Usage (menu alternatives slightly rearranged since `v02`):

```
Welcome to the Hero Manager!
Enter a menu option (C, L, T, S, A, D, E or Q) and press enter:
[C]reate a new hero (will prompt for details)
[L]ist all heroes
List [T]op n heroes (will prompt for n)
[S]earch matching heroes (will prompt for a search string)
[A]mend a hero
[D]elete a hero
[E]rase database (delete all heroes)
[Q]uit (exit the program)
```

To add a new hero press `C` and enter values as prompted. An empty string is treated as abort.
User will be prompted if the new hero will be saved or not.

```
C
Enter server_id (Server assigned string ID), or enter to abort:
2
Enter name (Most commonly used name), or enter to abort:
Bamse

Populate powerstats? (y/n)
y
Enter powerstats.intelligence (IQ SD 15 (WAIS)), or enter to finish populating powerstats:
85
Enter powerstats.strength (newton), or enter to finish populating powerstats:
999
Enter powerstats.speed (km/h), or enter to finish populating powerstats:
30
Enter powerstats.durability (longevity), or enter to finish populating powerstats:
20
Enter powerstats.power (whatever), or enter to finish populating powerstats:
3
Enter powerstats.combat (fighting skills), or enter to finish populating powerstats:
2

Populate biography? (y/n)
y
Enter biography.full-name (Full), or enter to finish populating biography:
Bamse Björnsson
Enter biography.alter-egos (Such as Jekyll and Hyde), or enter to finish populating biography:
Vargen?            
Enter biography.aliases (Other names the character is known by as a single value ('Insider') without surrounding ' or a list in json format e.g. ["Insider", "Matches Malone"]), or enter to finish populating biography:
Världens Starkaste Björn
Enter biography.place-of-birth (Where the character was born), or enter to finish populating biography:
Hemma hos Farmor på Höga berget
Enter biography.first-appearance (When the character first appeared in print or in court), or enter to finish populating biography:
1966
Enter biography.publisher (The publisher of the character's stories or documentary evidence), or enter to finish populating biography:
Egmont Kärnan
Enter biography.alignment (unknown, neutral, mostlyGood, good, reasonable, notQuite, bad, ugly, evil, usingMobileSpeakerOnPublicTransport), or enter to finish populating biography:
mostlyGood

Populate appearance? (y/n)
y
Enter appearance.gender (unknown, ambiguous, male, female, nonBinary, wontSay), or enter to finish populating appearance:
m
Enter appearance.race (Species in Latin or English), or enter to finish populating appearance:
Ursus arctos
Enter appearance.height (Height in centimeters and / or feet and inches. For multiple representations, enter a list in json format e.g. ["6'2\"", "188 cm"] or a single value like '188 cm', '188' or '1.88' (meters) without surrounding '), or enter to finish populating appearance:
150
Enter appearance.weight (Weight in kilograms and / or pounds. For multiple representations, enter a list in json format e.g. ["210 lb", "95 kg"] or a single value like '95 kg' or '95' (kilograms) without surrounding '), or enter to finish populating appearance:
250
Enter appearance.eye-color (The character's eye color of the most recent appearance), or enter to finish populating appearance:
Brown
Enter appearance.hair-color (The character's hair color of the most recent appearance), or enter to finish populating appearance:
Brown

Populate work? (y/n)
y
Enter work.occupation (Occupation of the character), or enter to finish populating work:
Law enforcement
Enter work.base (A place where the character works or lives or hides rather frequently), or enter to finish populating work:
Tre kullar

Populate connections? (y/n)
y
Enter connections.group-affiliation (Groups the character is affiliated with wether currently or in the past and if addmittedly or not), or enter to finish populating connections:
Bamse, Lille Skutt och Skalman
Enter connections.relatives (A list of the character's relatives by blood, marriage, adoption, or pure association), or enter to finish populating connections:
Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer  

Populate image? (y/n)
n

Save new hero with the following details?
=============
id: 8da15dad-4ba6-44ec-966a-e0dd164af118
version: 1
server_id: 2
name: Bamse
powerstats.intelligence: 85
powerstats.strength: 999
powerstats.speed: 30
powerstats.durability: 20
powerstats.power: 3
powerstats.combat: 2
biography.full-name: Bamse BjÃ¶rnsson
biography.alter-egos: Vargen?
biography.aliases: [VÃ¤rldens Starkaste BjÃ¶rn]
biography.place-of-birth: Hemma hos Farmor pÃ¥ HÃ¶ga berget
biography.first-appearance: 1966
biography.publisher: Egmont KÃ¤rnan
biography.alignment: mostlyGood
appearance.gender: male
appearance.race: Ursus arctos
appearance.height: 150 cm
appearance.weight: 250 kg
appearance.eye-color: Brown
appearance.hair-color: Brown
work.occupation: Law enforcement
work.base: Tre kullar
connections.group-affiliation: Bamse, Lille Skutt och Skalman
connections.relatives: Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer
image.url: null
=============
 (y/n)
y
Created hero:

=============
id: 8da15dad-4ba6-44ec-966a-e0dd164af118
version: 1
server_id: 2
name: Bamse
powerstats.intelligence: 85
powerstats.strength: 999
powerstats.speed: 30
powerstats.durability: 20
powerstats.power: 3
powerstats.combat: 2
biography.full-name: Bamse BjÃ¶rnsson
biography.alter-egos: Vargen?
biography.aliases: [VÃ¤rldens Starkaste BjÃ¶rn]
biography.place-of-birth: Hemma hos Farmor pÃ¥ HÃ¶ga berget
biography.first-appearance: 1966
biography.publisher: Egmont KÃ¤rnan
biography.alignment: mostlyGood
appearance.gender: male
appearance.race: Ursus arctos
appearance.height: 150 cm
appearance.weight: 250 kg
appearance.eye-color: Brown
appearance.hair-color: Brown
work.occupation: Law enforcement
work.base: Tre kullar
connections.group-affiliation: Bamse, Lille Skutt och Skalman
connections.relatives: Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer
image.url: null
=============
```

To amend an existing hero, press `A` and enter a search string. Candiates will be presented by descending order
of strenght. Press `y` to amend the displayed hero or `n` to review the next one or `c` to cancel.
Pressing `y` will give the user the chance of changing every value and keep current one with pressing enter.
Afterwards the changed fields will be reivewed and allow the user to accept them with `y` or abort them with `n`.

```
A
Enter a search string:
bamse
Found 1 heroes:

Amend the following hero?
=============
id: 8da15dad-4ba6-44ec-966a-e0dd164af118
version: 1
server_id: 2
name: Bamse
powerstats.intelligence: 85
powerstats.strength: 999
powerstats.speed: 30
powerstats.durability: 20
powerstats.power: 3
powerstats.combat: 2
biography.full-name: Bamse BjÃ¶rnsson
biography.alter-egos: Vargen?
biography.aliases: [VÃ¤rldens Starkaste BjÃ¶rn]
biography.place-of-birth: Hemma hos Farmor pÃ¥ HÃ¶ga berget
biography.first-appearance: 1966
biography.publisher: Egmont KÃ¤rnan
biography.alignment: mostlyGood
appearance.gender: male
appearance.race: Ursus arctos
appearance.height: 150 cm
appearance.weight: 250 kg
appearance.eye-color: Brown
appearance.hair-color: Brown
work.occupation: Law enforcement
work.base: Tre kullar
connections.group-affiliation: Bamse, Lille Skutt och Skalman
connections.relatives: Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer
image.url: null
=============
 (y = yes, n = next, c = cancel)
y
Enter name (Most commonly used name), or enter to keep current value (Bamse):


Amend powerstats? (y/N)
y
Enter powerstats.intelligence (IQ SD 15 (WAIS)), or enter to keep current value (85):

Enter powerstats.strength (newton), or enter to keep current value (999):

Enter powerstats.speed (km/h), or enter to keep current value (30):
50
Enter powerstats.durability (longevity), or enter to keep current value (20):
30
Enter powerstats.power (whatever), or enter to keep current value (3):

Enter powerstats.combat (fighting skills), or enter to keep current value (2):


Amend biography? (y/N)


Amend appearance? (y/N)


Amend work? (y/N)


Amend connections? (y/N)


Amend image? (y/N)
n

Save the following amendments?

=============
powerstats.speed: 30 -> 50
powerstats.durability: 20 -> 30
=============
 (y/n)
y
Amended hero:

=============
id: 8da15dad-4ba6-44ec-966a-e0dd164af118
version: 2
server_id: 2
name: Bamse
powerstats.intelligence: 85
powerstats.strength: 999
powerstats.speed: 50
powerstats.durability: 30
powerstats.power: 3
powerstats.combat: 2
biography.full-name: Bamse BjÃ¶rnsson
biography.alter-egos: Vargen?
biography.aliases: [VÃ¤rldens Starkaste BjÃ¶rn]
biography.place-of-birth: Hemma hos Farmor pÃ¥ HÃ¶ga berget
biography.first-appearance: 1966
biography.publisher: Egmont KÃ¤rnan
biography.alignment: mostlyGood
appearance.gender: male
appearance.race: Ursus arctos
appearance.height: 150 cm
appearance.weight: 250 kg
appearance.eye-color: Brown
appearance.hair-color: Brown
work.occupation: Law enforcement
work.base: Tre kullar
connections.group-affiliation: Bamse, Lille Skutt och Skalman
connections.relatives: Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer
image.url: null
=============
```

To delete an existing hero, press `D` and enter a search string. Candiates will be presented by descending order
of strenght. Press `y` to delete the hero or `n` to review the next one or `c` to cancel.
Pressing `y` will give the user the chance of of revewing the hero to be deleted and confirm deletion with `y` or
abort the operation with `n`.

```
D
Enter a search string:
b
Found 1 heroes:

Delete the following hero?
=============
id: 8da15dad-4ba6-44ec-966a-e0dd164af118
version: 2
server_id: 2
name: Bamse
powerstats.intelligence: 85
powerstats.strength: 999
powerstats.speed: 50
powerstats.durability: 30
powerstats.power: 3
powerstats.combat: 2
biography.full-name: Bamse BjÃ¶rnsson
biography.alter-egos: Vargen?
biography.aliases: [VÃ¤rldens Starkaste BjÃ¶rn]
biography.place-of-birth: Hemma hos Farmor pÃ¥ HÃ¶ga berget
biography.first-appearance: 1966
biography.publisher: Egmont KÃ¤rnan
biography.alignment: mostlyGood
appearance.gender: male
appearance.race: Ursus arctos
appearance.height: 150 cm
appearance.weight: 250 kg
appearance.eye-color: Brown
appearance.hair-color: Brown
work.occupation: Law enforcement
work.base: Tre kullar
connections.group-affiliation: Bamse, Lille Skutt och Skalman
connections.relatives: Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer
image.url: null
=============
 (y = yes, n = next, c = cancel)
y

Do you really want to delete hero with the following details?
=============
id: 8da15dad-4ba6-44ec-966a-e0dd164af118
version: 2
server_id: 2
name: Bamse
powerstats.intelligence: 85
powerstats.strength: 999
powerstats.speed: 50
powerstats.durability: 30
powerstats.power: 3
powerstats.combat: 2
biography.full-name: Bamse BjÃ¶rnsson
biography.alter-egos: Vargen?
biography.aliases: [VÃ¤rldens Starkaste BjÃ¶rn]
biography.place-of-birth: Hemma hos Farmor pÃ¥ HÃ¶ga berget
biography.first-appearance: 1966
biography.publisher: Egmont KÃ¤rnan
biography.alignment: mostlyGood
appearance.gender: male
appearance.race: Ursus arctos
appearance.height: 150 cm
appearance.weight: 250 kg
appearance.eye-color: Brown
appearance.hair-color: Brown
work.occupation: Law enforcement
work.base: Tre kullar
connections.group-affiliation: Bamse, Lille Skutt och Skalman
connections.relatives: Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer
image.url: null
=============
 (y/n)
y
Deleted hero:

=============
id: 8da15dad-4ba6-44ec-966a-e0dd164af118
version: 2
server_id: 2
name: Bamse
powerstats.intelligence: 85
powerstats.strength: 999
powerstats.speed: 50
powerstats.durability: 30
powerstats.power: 3
powerstats.combat: 2
biography.full-name: Bamse BjÃ¶rnsson
biography.alter-egos: Vargen?
biography.aliases: [VÃ¤rldens Starkaste BjÃ¶rn]
biography.place-of-birth: Hemma hos Farmor pÃ¥ HÃ¶ga berget
biography.first-appearance: 1966
biography.publisher: Egmont KÃ¤rnan
biography.alignment: mostlyGood
appearance.gender: male
appearance.race: Ursus arctos
appearance.height: 150 cm
appearance.weight: 250 kg
appearance.eye-color: Brown
appearance.hair-color: Brown
work.occupation: Law enforcement
work.base: Tre kullar
connections.group-affiliation: Bamse, Lille Skutt och Skalman
connections.relatives: Brummelisa, Brum, Teddy, Nalle-Maja, Brumma, Farmor, Johan "Nalle" Hilmer
image.url: null
=============
```

The menu option `E` (for "erase") will prompt the user for deleting all the heroes and despite the popular notion, they don't live forever so be careful with this.
`L` (for "list") displays all heroes unfiltered by descending order of strength, but `T` (for "top") filters out only the `n` best and `S` (for "search") filters by the given search term.