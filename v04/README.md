# v04
Manually generated README for v04

Stand in `HLF25-2\v04` and type `dart run`

This creates a little sqlite db (`v04.db`) that contains a simple table `heroes` with the following structure:

  ```
  id TEXT PRIMARY KEY,
  version INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  locked BOOLEAN NOT NULL,
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
  height_m REAL NOT NULL,
  height_system_of_units TEXT NOT NULL,
  weight_kg REAL NOT NULL,
  weight_system_of_units TEXT NOT NULL,
  eye_colour TEXT NULL,
  hair_colour TEXT NULL,
  occupation TEXT NULL,
  base TEXT NULL,
  group_affiliation TEXT NULL,
  relatives TEXT NULL,
  image_url TEXT NULL
```

The `id` is a `Uuid`, `gender` and `alignment`, `height_system_of_units` and `weight_system_of_units` are mapped from enums (the system of units `imperial` or `metric` are saved for scalars to direct the preferred formatting to match the data source). `external_id` is mapped from the field `id` in the `Hero` dto / api spec in `superheroapi.com` that will be integrated in the next release. The column `aliases` stores an encoded JSON-array as I couldn't be bothered to create another table and pray to the SQL gods for forgiveness. `locked` indicates that the hero has been manually amended or created and should not be reconciled with the API until it's first explicitly unlocked.

NB: I don't know how to parse
```
"connections": {
    "group-affiliation": "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    "relatives": "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)"
  }
```
as these fields are neither CSV (RFC-4180) compliant (as `Martha Wayne (mother, deceased)` has an unescaped comma, obviously), nor are they an encoded JSON list so I gave up and store it as a raw `TEXT`.
One could relatively easy construct a grammar of a recursive comma separated format format without escaping of injected commas and recursion over parentheses, leading to a parse tree on the following form:
```
relation:
  name: Damian Wayne
  relation: Son
    qualifiers: []
relation:
  name: Martha Wayne
  relation: Mother
    qualifiers: [deceased]
```
But I simply don't trust the API to adhere to any parseable format for it to be worth the effort!

Secondly, in the following example:
```
  "biography": {
    "alter-egos": "No alter egos found.",
  },
```

The string literal `"No alter egos found."` is apparently used here as a special value representing `null` or the absence of data in the api and expected to be treated as such by consumers, but due to the lack of escaping (pun intended) any villain could present that exact string as their alter ego of choice and thereby evade detection systems that would treat is at as the villain not having any alter ago at all! I assume this loophole is planted here to test our attention.

Usage:

```
Welcome to the Hero Manager!
Enter a menu option (C, L, T, S, A, D, E, O or Q) and press enter:
[C]reate a new hero (will prompt for details)
[L]ist all heroes
List [T]op n heroes (will prompt for n)
[S]earch matching heroes (will prompt for a search string)
[A]mend a hero
[D]elete a hero
[E]rase database (delete all heroes)
Go [O]nline to download heroes
[Q]uit (exit the program)
```

To go online and download heroes press `O` and enter the search string as prompted:

```
O
Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


S
Enter a search string:
Batman
```

If no API key and / or API host are specified in a local `.env` file, enter the values as prompted and the `.env` file will be created or updated accordingly.

When prompted for `Save the following hero locally?` one can answer `y` to save, `no` to allow the hero to die, `a` to try to be a hero oneself or the most reasonably `q` to give up.

```
Enter your API key: 
extremely_secret_api_key
Enter API host or press enter to accept default ("www.superheroapi.com)": 


Online search started at 2025-10-21 06:06:25.667157Z



Found 3 heroes online:

Save the following hero locally?

=============
id: 25af2ebd-ddcb-4abc-ad53-8a29214253bb
Version: 1
Timestamp: 2025-10-21T06:06:25.667157Z
Locked: false
External ID: 69
Name: Batman
Powerstats: Intelligence: 81
Powerstats: Strength: 40
Powerstats: Speed: 29
Powerstats: Durability: 55
Powerstats: Power: 63
Powerstats: Combat: 90
Biography: Full Name: Terry McGinnis
Biography: Alter Egos: null
Biography: Aliases: [Batman II, The Tomorrow Knight, The second Dark Knight, The Dark Knight of Tomorrow, Batman Beyond]
Biography: Place of Birth: Gotham City, 25th Century
Biography: First Appearance: Batman Beyond #1
Biography: Publisher: DC Comics
Biography: Alignment: good
Appearance: Gender: male
Appearance: Race: Human
Appearance: Height: 5'10"
Appearance: Weight: 170 lb
Appearance: Eye Colour: Blue
Appearance: Hair Colour: Black
Work: Occupation: null
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============
 (y = yes, n = no, a = all, q = quit)
a
Saved hero 69 ("Batman") so it can save you:

=============
id: 25af2ebd-ddcb-4abc-ad53-8a29214253bb
Version: 1
Timestamp: 2025-10-21T06:06:25.667157Z
Locked: false
External ID: 69
Name: Batman
Powerstats: Intelligence: 81
Powerstats: Strength: 40
Powerstats: Speed: 29
Powerstats: Durability: 55
Powerstats: Power: 63
Powerstats: Combat: 90
Biography: Full Name: Terry McGinnis
Biography: Alter Egos: null
Biography: Aliases: [Batman II, The Tomorrow Knight, The second Dark Knight, The Dark Knight of Tomorrow, Batman Beyond]
Biography: Place of Birth: Gotham City, 25th Century
Biography: First Appearance: Batman Beyond #1
Biography: Publisher: DC Comics
Biography: Alignment: good
Appearance: Gender: male
Appearance: Race: Human
Appearance: Height: 5'10"
Appearance: Weight: 170 lb
Appearance: Eye Colour: Blue
Appearance: Hair Colour: Black
Work: Occupation: null
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============

Saved hero 70 ("Batman") so it can save you:

=============
id: cb2d1a59-3ebc-4a0b-9bf8-73e898f32213
Version: 1
Timestamp: 2025-10-21T06:06:25.667157Z
Locked: false
External ID: 70
Name: Batman
Powerstats: Intelligence: 100
Powerstats: Strength: 26
Powerstats: Speed: 27
Powerstats: Durability: 50
Powerstats: Power: 47
Powerstats: Combat: 100
Biography: Full Name: Bruce Wayne
Biography: Alter Egos: null
Biography: Aliases: [Insider, Matches Malone]
Biography: Place of Birth: Crest Hill, Bristol Township; Gotham County
Biography: First Appearance: Detective Comics #27
Biography: Publisher: DC Comics
Biography: Alignment: good
Appearance: Gender: male
Appearance: Race: Human
Appearance: Height: 6'2"
Appearance: Weight: 210 lb
Appearance: Eye Colour: blue
Appearance: Hair Colour: black
Work: Occupation: Businessman
Work: Base: Batcave, Stately Wayne Manor, Gotham City; Hall of Justice, Justice League Watchtower
Connections: Group Affiliation: Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps
Connections: Relatives: Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward) 
Martha Wayne (mother, deceased), Thomas Wayne (father, deceased), Alfred Pennyworth (former guardian), Roderick Kane (grandfather, deceased), Elizabeth Kane (grandmother, deceased), Nathan Kane (uncle, deceased), Simon Hurt (ancestor), Wayne Family
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/639.jpg
=============

Saved hero 71 ("Batman II") so it can save you:

=============
id: 6b711498-8fc5-45bb-8a34-de5d2d314755
Version: 1
Timestamp: 2025-10-21T06:06:25.667157Z
Locked: false
External ID: 71
Name: Batman II
Powerstats: Intelligence: 88
Powerstats: Strength: 11
Powerstats: Speed: 33
Powerstats: Durability: 28
Powerstats: Power: 36
Powerstats: Combat: 100
Biography: Full Name: Dick Grayson
Biography: Alter Egos: Nightwing, Robin
Biography: Aliases: [Dick Grayson]
Biography: Place of Birth: null
Biography: First Appearance: null
Biography: Publisher: Nightwing
Biography: Alignment: good
Appearance: Gender: male
Appearance: Race: Human
Appearance: Height: 5'10"
Appearance: Weight: 175 lb
Appearance: Eye Colour: Blue
Appearance: Hair Colour: Black
Work: Occupation: null
Work: Base: Gotham City; formerly Bludhaven, New York City
Connections: Group Affiliation: Justice League Of America, Batman Family
Connections: Relatives: John Grayson (father, deceased), Mary Grayson (mother, deceased), Bruce Wayne / Batman (adoptive father), Damian Wayne / Robin (foster brother), Jason Todd / Red Hood (adoptive brother), Tim Drake / Red Robin (adoptive brother), Cassandra Cain / Batgirl IV (adoptive sister)        
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/1496.jpg
=============


Download complete at 2025-10-21 06:06:31.447214Z: 3 heroes saved (so they can in turn save 90 people, or more, depending on their abilities).
```

To amend a, hero exit the online meny by pressing `X` to go back to the main meny and enter `A` to search for a hero to amend. Any manual amendment sets the `lock` flag on the hero to true so that it cannot be automatically reconciled.

```
Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


X
Enter a menu option (C, L, T, S, A, D, E, O or Q) and press enter:
[C]reate a new hero (will prompt for details)
[L]ist all heroes
List [T]op n heroes (will prompt for n)
[S]earch matching heroes (will prompt for a search string)
[A]mend a hero
[D]elete a hero
[E]rase database (delete all heroes)
Go [O]nline to download heroes
[Q]uit (exit the program)


A
Enter a search string:
Batman
Found 3 heroes:

Amend the following hero?
=============
id: 6fff241c-44b0-43b9-a687-e0ad101f11a9
Version: 1
Timestamp: 2025-10-21T06:14:25.286886Z
Locked: false
External ID: 69
Name: Batman
Powerstats: Intelligence: 81
Powerstats: Strength: 40
Powerstats: Speed: 29
Powerstats: Durability: 55
Powerstats: Power: 63
Powerstats: Combat: 90
Biography: Full Name: Terry McGinnis
Biography: Alter Egos: null
Biography: Aliases: [Batman II, The Tomorrow Knight, The second Dark Knight, The Dark Knight of Tomorrow, Batman Beyond]
Biography: Place of Birth: Gotham City, 25th Century
Biography: First Appearance: Batman Beyond #1
Biography: Publisher: DC Comics
Biography: Alignment: good
Appearance: Gender: male
Appearance: Race: Human
Appearance: Height: 5'10"
Appearance: Weight: 170 lb
Appearance: Eye Colour: Blue
Appearance: Hair Colour: Black
Work: Occupation: null
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============
 (y = yes, n = next, c = cancel)
y
Enter Name (Most commonly used name), or enter to keep current value (Batman):


Amend Powerstats (Power statistics which is mostly misused)? (y/N)


Amend Biography (Hero's quite biased biography)? (y/N)
y
Enter Biography: Full Name (Also applies when hungry), or enter to keep current value (Terry McGinnis):

Enter Biography: Alter Egos (Alter egos of the character), or enter to keep current value (null):

Enter Biography: Aliases (Other names the character is known by as a single value ('Insider') without surrounding ' or a list in json format e.g. ["Insider", "Matches Malone"]), or enter to keep current value ([Batman II, The Tomorrow Knight, The second Dark Knight, The Dark Knight of Tomorrow, Batman Beyond]):

Enter Biography: Place of Birth (Where the character was born), or enter to keep current value (Gotham City, 25th Century):

Enter Biography: First Appearance (When the character first appeared in print or in court), or enter to keep current value (Batman Beyond #1):

Enter Biography: Publisher (The publisher of the character's stories or documentary evidence), or enter to keep current value (DC Comics):

Enter Biography: Alignment (The character's moral alignment (unknown, neutral, mostlyGood, good, reasonable, notQuite, bad, ugly, evil, usingMobileSpeakerOnPublicTransport)), or enter to keep current value (good):
bad

Amend Appearance (Hero's appearance)? (y/N)


Amend Work (Hero's work)? (y/N)


Amend Connections (Hero's connections)? (y/N)


Amend Image (Hero's image)? (y/N)


Save the following amendments?

=============
Biography: Alignment: good -> bad
=============
 (y/n)
y
Amended hero:

=============
id: 6fff241c-44b0-43b9-a687-e0ad101f11a9
Version: 2
Timestamp: 2025-10-21T06:15:20.854988Z
Locked: true
External ID: 69
Name: Batman
Powerstats: Intelligence: 81
Powerstats: Strength: 40
Powerstats: Speed: 29
Powerstats: Durability: 55
Powerstats: Power: 63
Powerstats: Combat: 90
Biography: Full Name: Terry McGinnis
Biography: Alter Egos: null
Biography: Aliases: [Batman II, The Tomorrow Knight, The second Dark Knight, The Dark Knight of Tomorrow, Batman Beyond]
Biography: Place of Birth: Gotham City, 25th Century
Biography: First Appearance: Batman Beyond #1
Biography: Publisher: DC Comics
Biography: Alignment: bad
Appearance: Gender: male
Appearance: Race: Human
Appearance: Height: 5'10"
Appearance: Weight: 170 lb
Appearance: Eye Colour: Blue
Appearance: Hair Colour: Black
Work: Occupation: null
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============
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
