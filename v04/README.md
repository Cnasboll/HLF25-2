# v04
Manually generated README for v04

Stand in `HLF25-2\v04` and type `dart run`

This creates a little sqlite db (`v04.db`) that contains a simple table `heroes` with the following structure:

  ```
  id TEXT PRIMARY KEY,
  version INTEGER NOT NULL,
  external_id TEXT NOT NULL,
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
  height_m REAL NULL,
  height_system_of_units TEXT NULL,
  weight_kg REAL NULL,
  weight_system_of_units TEXT NULL,
  eye_colour TEXT NULL,
  hair_colour TEXT NULL,
  occupation TEXT NULL,
  base TEXT NULL,
  group_affiliation TEXT NULL,
  relatives TEXT NULL,
  image_url TEXT NULL
```

The `id` is a `Uuid`, `gender` and `alignment`, `height_system_of_units` and `weight_system_of_units` are mapped from enums (the system of units `imperial` or `metric` are saved for scalars to direct the preferred formatting to match the data source). `external_id` is mapped from the field `id` in the `Hero` dto / api spec in `superheroapi.com` that will be integrated in the next release. The column `aliases` stores an encoded JSON-array as I couldn't be bothered to create another table and pray to the SQL gods for forgiveness.

NB: I don't know how to parse
```
"connections": {
    "group-affiliation": "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    "relatives": "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)"
  }
```
as these fields are neither CSV (RFC-4180) compliant (as `Martha Wayne (mother, deceased)` has an unescaped comma, obviously), nor are they an encoded JSON list so I gave up and store it as a raw `TEXT`.

Secondly, in the following example:
```
  "biography": {
    "alter-egos": "No alter egos found.",
  },
```

The string literal `"No alter egos found."` is apparently used here as a special value representing `null` or the absence of data in the api and expected to be treated as such by consumers, but due to the lack of escaping (pun intended) any villain could present that exact string as their alter ego of choice and thereby evade detection systems that would treat is at as the villain not having any alter ago at all! I assume this loophole is planted here to test our attention.

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
Enter External ID (Server assigned string ID), or enter to abort:
this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Enter Name (Most commonly used name), or enter to abort:
Bamse 

Populate Powerstats (Power statistics which is mostly misused)? (y/n)
y
Enter Powerstats: Intelligence (IQ SD 15 (WAIS)), or enter to finish populating Powerstats:
85
Enter Powerstats: Strength (newton), or enter to finish populating Powerstats:
999
Enter Powerstats: Speed (km/h), or enter to finish populating Powerstats:
7 
Enter Powerstats: Durability (longevity), or enter to finish populating Powerstats:
30
Enter Powerstats: Power (whatever), or enter to finish populating Powerstats:
2
Enter Powerstats: Combat (fighting skills), or enter to finish populating Powerstats:
2

Populate Biography (Hero's quite biased biography)? (y/n)
y
Enter Biography: Full Name (Full), or enter to finish populating Biography:
Banse Brunberg 
Enter Biography: Alter Egos (Alter egos of the character), or enter to finish populating Biography:
Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Enter Biography: Aliases (Other names the character is known by as a single value ('Insider') without surrounding ' or a list in json format e.g. ["Insider", "Matches Malone"]), or enter to finish populating Biography:
Världens starkaste björn
Enter Biography: Place of Birth (Where the character was born), or enter to finish populating Biography:
Vargön
Enter Biography: First Appearance (When the character first appeared in print or in court), or enter to finish populating Biography:
Allers, 1966-1970, egen serietidning från 1973
Enter Biography: Publisher (The publisher of the character's stories or documentary evidence), or enter to finish populating Biography:
Egmont Publishing
Enter Biography: Alignment (The character's moral alignment (unknown, neutral, mostlyGood, good, reasonable, notQuite, bad, ugly, evil, usingMobileSpeakerOnPublicTransport)), or enter to finish populating Biography:
mostlyGood

Populate Appearance (Hero's appearance)? (y/n)
y
Enter Appearance: Gender (unknown, ambiguous, male, female, nonBinary, wontSay), or enter to finish populating Appearance:
m
Enter Appearance: Race (Species in Latin or English), or enter to finish populating Appearance:
Usrus arctos
Enter Appearance: Height (Height in centimeters and / or feet and inches. For multiple representations, enter a list in json format e.g. ["6'2\"", "188 cm"] or a single value like '188 cm', '188' or '1.88' (meters) without surrounding '), or enter to finish populating Appearance:      
150 cm
Enter Appearance: Weight (Weight in kilograms and / or pounds. For multiple representations, enter a list in json format e.g. ["210 lb", "95 kg"] or a single value like '95 kg' or '95' (kilograms) without surrounding '), or enter to finish populating Appearance:
250 kg
Enter Appearance: Eye Colour (The character's eye color of the most recent appearance), or enter to finish populating Appearance:
brown
Enter Appearance: Hair Colour (The character's hair color of the most recent appearance), or enter to finish populating Appearance:
brown

Populate Work (Hero's work)? (y/n)
y     
Enter Work: occupation (Occupation of the character), or enter to finish populating Work:
Law enforcement
Enter Work: base (A place where the character works or lives or hides rather frequently), or enter to finish populating Work:
Kullarna 

Populate Connections (Hero's connections)? (y/n)
y
Enter Connections: Group Affiliation (Groups the character is affiliated with wether currently or in the past and if addmittedly or not), or enter to finish populating Connections:
Bamse, Lille Skutt och Skalman (tm)
Enter Connections: Relatives (A list of the character's relatives by blood, marriage, adoption, or pure association), or enter to finish populating Connections:
Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma                

Populate Image (Hero's image)? (y/n)
n

Save new hero with the following details?
=============
id: ad31d12c-c5d4-41dc-9aef-1a1a6cdb121e
Version: 1
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 85
Powerstats: Strength: 999
Powerstats: Speed: 7
Powerstats: Durability: 30
Powerstats: Power: 2
Powerstats: Combat: 2
Biography: Full Name: Banse Brunberg
Biography: Alter Egos: Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Biography: Aliases: [Världens starkaste björn]
Biography: Place of Birth: Vargön
Biography: First Appearance: Allers, 1966-1970, egen serietidning från 1973
Biography: Publisher: Egmont Publishing
Biography: Alignment: mostlyGood
Appearance: Gender: male
Appearance: Race: Usrus arctos
Appearance: Height: 150 cm
Appearance: Weight: 250 kg
Appearance: Eye Colour: brown
Appearance: Hair Colour: brown
Work: occupation: Law enforcement
Work: base: Kullarna
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
 (y/n)
y
Created hero:

=============
id: ad31d12c-c5d4-41dc-9aef-1a1a6cdb121e
Version: 1
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 85
Powerstats: Strength: 999
Powerstats: Speed: 7
Powerstats: Durability: 30
Powerstats: Power: 2
Powerstats: Combat: 2
Biography: Full Name: Banse Brunberg
Biography: Alter Egos: Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Biography: Aliases: [Världens starkaste björn]
Biography: Place of Birth: Vargön
Biography: First Appearance: Allers, 1966-1970, egen serietidning från 1973
Biography: Publisher: Egmont Publishing
Biography: Alignment: mostlyGood
Appearance: Gender: male
Appearance: Race: Usrus arctos
Appearance: Height: 150 cm
Appearance: Weight: 250 kg
Appearance: Eye Colour: brown
Appearance: Hair Colour: brown
Work: occupation: Law enforcement
Work: base: Kullarna
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
```

To amend an existing hero, press `A` and enter a search string. Candiates will be presented by descending order
of strenght. Press `y` to amend the displayed hero or `n` to review the next one or `c` to cancel.
Pressing `y` will give the user the chance of amendning every value and keep current one with pressing enter.
Afterwards the amended fields will be reivewed and allow the user to accept them with `y` or abort them with `n`.

```
A
Enter a search string:
ba
Found 1 heroes:

Amend the following hero?
=============
id: ad31d12c-c5d4-41dc-9aef-1a1a6cdb121e
Version: 1
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 85
Powerstats: Strength: 999
Powerstats: Speed: 7
Powerstats: Durability: 30
Powerstats: Power: 2
Powerstats: Combat: 2
Biography: Full Name: Banse Brunberg
Biography: Alter Egos: Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Biography: Aliases: [Världens starkaste björn]
Biography: Place of Birth: Vargön
Biography: First Appearance: Allers, 1966-1970, egen serietidning från 1973
Biography: Publisher: Egmont Publishing
Biography: Alignment: mostlyGood
Appearance: Gender: male
Appearance: Race: Usrus arctos
Appearance: Height: 150 cm
Appearance: Weight: 250 kg
Appearance: Eye Colour: brown
Appearance: Hair Colour: brown
Work: occupation: Law enforcement
Work: base: Kullarna
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
 (y = yes, n = next, c = cancel)
y
Enter Name (Most commonly used name), or enter to keep current value (Bamse):


Amend Powerstats (Power statistics which is mostly misused)? (y/N)


Amend Biography (Hero's quite biased biography)? (y/N)
y
Enter Biography: Full Name (Full), or enter to keep current value (Banse Brunberg):
Bamse Brunberg
Enter Biography: Alter Egos (Alter egos of the character), or enter to keep current value (Kapten Buster. Ingen har sett honom och Bamse samtidigt.):

Enter Biography: Aliases (Other names the character is known by as a single value ('Insider') without surrounding ' or a list in json format e.g. ["Insider", "Matches Malone"]), or enter to keep current value ([Världens starkaste björn]):

Enter Biography: Place of Birth (Where the character was born), or enter to keep current value (Vargön):

Enter Biography: First Appearance (When the character first appeared in print or in court), or enter to keep current value (Allers, 1966-1970, egen serietidning från 1973):

Enter Biography: Publisher (The publisher of the character's stories or documentary evidence), or enter to keep current value (Egmont Publishing):

Enter Biography: Alignment (The character's moral alignment (unknown, neutral, mostlyGood, good, reasonable, notQuite, bad, ugly, evil, usingMobileSpeakerOnPublicTransport)), or enter to keep current value (mostlyGood):


Amend Appearance (Hero's appearance)? (y/N)


Amend Work (Hero's work)? (y/N)


Amend Connections (Hero's connections)? (y/N)


Amend Image (Hero's image)? (y/N)


Save the following amendments?

=============
Biography: Full Name: Banse Brunberg -> Bamse Brunberg
=============
 (y/n)
y
Amended hero:

=============
id: ad31d12c-c5d4-41dc-9aef-1a1a6cdb121e
Version: 2
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 85
Powerstats: Strength: 999
Powerstats: Speed: 7
Powerstats: Durability: 30
Powerstats: Power: 2
Powerstats: Combat: 2
Biography: Full Name: Bamse Brunberg
Biography: Alter Egos: Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Biography: Aliases: [Världens starkaste björn]
Biography: Place of Birth: Vargön
Biography: First Appearance: Allers, 1966-1970, egen serietidning från 1973
Biography: Publisher: Egmont Publishing
Biography: Alignment: mostlyGood
Appearance: Gender: male
Appearance: Race: Usrus arctos
Appearance: Height: 150 cm
Appearance: Weight: 250 kg
Appearance: Eye Colour: brown
Appearance: Hair Colour: brown
Work: occupation: Law enforcement
Work: base: Kullarna
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
```

To delete an existing hero, press `D` and enter a search string. Candiates will be presented by descending order
of strenght. Press `y` to delete the hero or `n` to review the next one or `c` to cancel.
Pressing `y` will give the user the chance of of revewing the hero to be deleted and confirm deletion with `y` or
abort the operation with `n`.

```
D
Enter a search string:
ba
Found 1 heroes:

Delete the following hero?
=============
id: ad31d12c-c5d4-41dc-9aef-1a1a6cdb121e
Version: 2
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 85
Powerstats: Strength: 999
Powerstats: Speed: 7
Powerstats: Durability: 30
Powerstats: Power: 2
Powerstats: Combat: 2
Biography: Full Name: Bamse Brunberg
Biography: Alter Egos: Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Biography: Aliases: [Världens starkaste björn]
Biography: Place of Birth: Vargön
Biography: First Appearance: Allers, 1966-1970, egen serietidning från 1973
Biography: Publisher: Egmont Publishing
Biography: Alignment: mostlyGood
Appearance: Gender: male
Appearance: Race: Usrus arctos
Appearance: Height: 150 cm
Appearance: Weight: 250 kg
Appearance: Eye Colour: brown
Appearance: Hair Colour: brown
Work: occupation: Law enforcement
Work: base: Kullarna
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
 (y = yes, n = next, c = cancel)
y

Do you really want to delete hero with the following details?
=============
id: ad31d12c-c5d4-41dc-9aef-1a1a6cdb121e
Version: 2
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 85
Powerstats: Strength: 999
Powerstats: Speed: 7
Powerstats: Durability: 30
Powerstats: Power: 2
Powerstats: Combat: 2
Biography: Full Name: Bamse Brunberg
Biography: Alter Egos: Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Biography: Aliases: [Världens starkaste björn]
Biography: Place of Birth: Vargön
Biography: First Appearance: Allers, 1966-1970, egen serietidning från 1973
Biography: Publisher: Egmont Publishing
Biography: Alignment: mostlyGood
Appearance: Gender: male
Appearance: Race: Usrus arctos
Appearance: Height: 150 cm
Appearance: Weight: 250 kg
Appearance: Eye Colour: brown
Appearance: Hair Colour: brown
Work: occupation: Law enforcement
Work: base: Kullarna
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
 (y/n)
y
Deleted hero:

=============
id: ad31d12c-c5d4-41dc-9aef-1a1a6cdb121e
Version: 2
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 85
Powerstats: Strength: 999
Powerstats: Speed: 7
Powerstats: Durability: 30
Powerstats: Power: 2
Powerstats: Combat: 2
Biography: Full Name: Bamse Brunberg
Biography: Alter Egos: Kapten Buster. Ingen har sett honom och Bamse samtidigt.
Biography: Aliases: [Världens starkaste björn]
Biography: Place of Birth: Vargön
Biography: First Appearance: Allers, 1966-1970, egen serietidning från 1973
Biography: Publisher: Egmont Publishing
Biography: Alignment: mostlyGood
Appearance: Gender: male
Appearance: Race: Usrus arctos
Appearance: Height: 150 cm
Appearance: Weight: 250 kg
Appearance: Eye Colour: brown
Appearance: Hair Colour: brown
Work: occupation: Law enforcement
Work: base: Kullarna
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
```

The menu option `E` (for "erase") will prompt the user for deleting all the heroes and despite the popular notion, they don't live forever so be careful with this.
`L` (for "list") displays all heroes unfiltered by descending order of strength, but `T` (for "top") filters out only the `n` best and `S` (for "search") filters by the given search term.

There are plenty of unit tests. `v04\tests\json_mapping_test.dart` shows how the entire example json blob is parsed to a `HeroModel`. The editing done by the CLI is in fact using json as an intermediate format so that the app is ready to be connected to the API without further modifications. `v04\tests\sql_generation_test.dart` shows expected SQL that is generated, but the reason I don't type it directly but generate it from metadata in the `Field<T,V>`-definitions is simply to be able to prevent bugs when changing something in the structure. Code generation *always* saves time in the end.

Also note that the parser will throw if given conflicting height or weight information, see  `v04\tests\weight_test.dart` and `v04\tests\height_test.dart`, respectively and in particular the consistency checking in `v04\value_types\value_type.dart` :

```
static (T?, String?) tryParseList<T>(
    List<String>? valueInVariousUnits,
    String valueTypeName,
    (T?, String?) Function(String) tryParse,
  )
``` 
which really was the main focus of this assigment for me, roughly 95%.
