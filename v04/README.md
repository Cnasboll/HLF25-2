# v04
Manually generated README for v04

# Hero Manager

## Usage
Stand in `HLF25-2\v04` and type `dart run`

### DB structure
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
#### Fields

`id` is a `Uuid`.

 `gender`, `alignment`, `height_system_of_units` and `weight_system_of_units` are mapped from enums (the system of units `imperial` or `metric` are saved for scalars to direct the preferred formatting to match the data source).
 
 When synching with the external source, `external_id` is mapped from the field `id` in the `Hero` api spec in `superheroapi.com`.
 
 The column `aliases` stores an encoded JSON-array as author(s) couldn't be bothered to create another table and pray to the SQL gods for forgiveness.
 
 A `locked` field of nozero indicates that the _Hero_ has been manually _Created_ or _Amended_, and should therfore not be _Reconciled_ with the API until it's first explicitly _Unlocked_.

NB: We don't know how to parse
```
"connections": {
    "group-affiliation": "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    "relatives": "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)"
  }
```
as these fields are neither CSV (RFC-4180) compliant (as `Martha Wayne (mother, deceased)` has an unescaped comma, obviously), nor are they an encoded JSON list so author(s) gave up and store it as a raw `TEXT`.

One could relatively easy construct a grammar of a recursive comma separated format format without escaping of injected commas and recursion over parentheses, leading to a parse tree on the following form:
```yaml
relations:
  - name: Damian Wayne
    relation: Son
    qualifiers: []
  - name: Martha Wayne
    relation: Mother
    qualifiers: [deceased]
```
But we simply don't trust the API to consitently adhere to any parseable format for it to be worth that effort!

Secondly, in the following example:
```
  "biography": {
    "alter-egos": "No alter egos found.",
  },
```

The string literal `"No alter egos found."` is apparently used here as a special value representing `null` or the absence of data in the API, and expected to be treated as such by consumers.

Due to the lack of escaping (pun intended) any _Villain_ could present that exact string as their alter ego of choice and thereby evade detection systems that would treat is at as the _Villain_ not having any alter ago at all! I assume this loophole is planted here to test our attention.

### Basic usage
#### _Main_ menu

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

#### _Online Search_
To go _Online_ and _Search_ for _Heroes_ to download, type `O` and `S` and enter the _Search_ string as prompted:

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

If no API key and / or API host are specified in a local `.env` file, enter those values as prompted and the `.env` file will be created or updated accordingly.

When prompted for `Save the following hero locally?` one can answer `y` to save, `no` to allow the _Hero_ to die, or `a` to try to be a hero oneself, or -- the most reasonably, `q` to give up.

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

#### _Amendment_ of locally saved _Hero_
To _Amend_ an existing _Hero_, exit the _Online_ menu by pressing `X` to return to the _Main_ menu. Enter `A` to search string for the _Hero_ to _Amend_. 

The search string will be interpeted as _SHQL™_ if possible and otherwise be treated as a string to be matched against all fields.

Candiates will be presented by descending order of strenght. Press `y` to _Amend_ the displayed _Hero_ or `n` to review the next one, or `c` to cancel.

Pressing `y` will give the user the chance of _Amendning_ every value and keep current one with pressing enter.

Upon completion, the _Amended_ fields will be reivewed and allow the user to accept them with `y` or abort them with `n`.
Any manual _Amendment_ sets the _Lock_ flag on the _Hero_ to `true` to exclude it from any automated _Reconciliaton_ with it's _Online_ version that would otherwise undo the user's creative efforts.

```
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

#### _Reconiliation_ of locally saved heros against _Online_ source
To _Reconcile_ locally saved _heroes_ a gainst the _Online_ source, select `O` to enter the _Online_ menu and type `R`:


```
O
Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


R

Reconciliation started at at 2025-10-21 09:46:59.687391Z


Hero: 69 ("Batman") is locked by prior manual amendment, skipping reconciliation changes:

Biography: Alignment: bad -> good

Hero: 70 ("Batman") is already up to date
Hero: 71 ("Batman II") is already up to date

Reconciliation complete at 2025-10-21 09:47:01.497983Z: 0 heroes reconciled, 0 heroes deleted.


Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu
```

##### _Unlock_ to allow reconciliation
In this case no change occurred. _Hero_ `69` has a locally _Amended_ `Biograhy: alignment` field but is in _Locked_ status. To allow _Reconciliation_ of this _Hero_, type `U` to _Unlock_ it and then re-run _Reconciliation_:

```
U
Enter a search string:
Batman
Found 1 heroes:

Unlock to enable reconciliation the following hero?
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
Work: Occupation:
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============
 (y = yes, n = next, c = cancel)
y
Hero was unlocked:

=============
id: 6fff241c-44b0-43b9-a687-e0ad101f11a9
Version: 3
Timestamp: 2025-10-21T09:50:10.116765Z
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
Biography: Alignment: bad
Appearance: Gender: male
Appearance: Race: Human
Appearance: Height: 5'10"
Appearance: Weight: 170 lb
Appearance: Eye Colour: Blue
Appearance: Hair Colour: Black
Work: Occupation:
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============

Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


R

Reconciliation started at at 2025-10-21 09:50:14.778669Z



Reconcile hero: 69 ("Batman") with the following online changes?
  Biography: Alignment: bad -> good
 (y = yes, n = no, a = all, q = quit)
a
Reconciled hero: 69 ("Batman") with the following online changes:
Biography: Alignment: bad -> good

Hero: 70 ("Batman") is already up to date
Hero: 71 ("Batman II") is already up to date

Reconciliation complete at 2025-10-21 09:50:17.918565Z: 1 heroes reconciled, 0 heroes deleted.


Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu
```

#### _Create_ a local _Hero_
To manally _Create_ a new local _Hero_ (mainly _known_, but not necesarily _recongnised_ around their immediate neighbourhood), press `C` in the _Main_ menu and enter values as prompted. An empty string is treated as abort.
User will be prompted if the new _Hero_ will be saved or not.

```
C
Enter External ID (Server assigned string ID), or enter to abort:
this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Enter Name (Most commonly used name), or enter to abort:
Bamse

Populate Powerstats (Power statistics which is mostly misused)? (y/n)
y
Enter Powerstats: Intelligence (%), or enter to finish populating Powerstats:
30
Enter Powerstats: Strength (%), or enter to finish populating Powerstats:
99
Enter Powerstats: Speed (%), or enter to finish populating Powerstats:
7
Enter Powerstats: Durability (%), or enter to finish populating Powerstats:
30
Enter Powerstats: Power (%), or enter to finish populating Powerstats:
2
Enter Powerstats: Combat (%), or enter to finish populating Powerstats:
2

Populate Biography (Hero's quite biased biography)? (y/n)
y
Enter Biography: Full Name (Also applies when hungry), or enter to finish populating Biography:
Bamse Brunberg
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
Brown
Enter Appearance: Hair Colour (The character's hair color of the most recent appearance), or enter to finish populating Appearance:
Brown

Populate Work (Hero's work)? (y/n)
y
Enter Work: Occupation (Occupation of the character), or enter to finish populating Work:
Law enforcement
Enter Work: Base (A place where the character works or lives or hides rather frequently), or enter to finish populating Work:
Tre Kullar

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
id: 96531606-192c-4931-b57b-0d78e53c8b7a
Version: 1
Timestamp: 2025-10-21T10:56:40.570738Z
Locked: true
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 30
Powerstats: Strength: 99
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
Appearance: Eye Colour: Brown
Appearance: Hair Colour: Brown
Work: Occupation: Law enforcement
Work: Base: Tre Kullar
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
 (y/n)
y
Created hero:

=============
id: 96531606-192c-4931-b57b-0d78e53c8b7a
Version: 1
Timestamp: 2025-10-21T10:56:40.570738Z
Locked: true
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 30
Powerstats: Strength: 99
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
Appearance: Eye Colour: Brown
Appearance: Hair Colour: Brown
Work: Occupation: Law enforcement
Work: Base: Tre Kullar
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
```

#### _Auto-delete_ a local _Hero_
As the new _Hero_ only exists locally and is created in _Locked_ state, the _Reconciliation_ job will not consider it for _Deletion_:


```
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


O
Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


R

Reconciliation started at at 2025-10-21 10:58:24.409875Z


Hero: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide ("Bamse") does not exist online: "invalid id" but is locked by prior manual amendment - skipping deletion
Hero: 69 ("Batman") is already up to date
Hero: 70 ("Batman") is already up to date
Hero: 71 ("Batman II") is already up to date

Reconciliation complete at 2025-10-21 10:58:32.802370Z: 0 heroes reconciled, 0 heroes deleted.
```

To auto-_Delete_ it, first _Unlock_ the _Hero_ and run the _Reconciliation_ job again:
```
Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


U
Enter a search string:
Bamse
Found 1 heroes:

Unlock to enable reconciliation the following hero?
=============
id: 96531606-192c-4931-b57b-0d78e53c8b7a
Version: 1
Timestamp: 2025-10-21T10:56:40.570738Z
Locked: true
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 30
Powerstats: Strength: 99
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
Appearance: Eye Colour: Brown
Appearance: Hair Colour: Brown
Work: Occupation: Law enforcement
Work: Base: Tre Kullar
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============
 (y = yes, n = next, c = cancel)
y
Hero was unlocked:

=============
id: 96531606-192c-4931-b57b-0d78e53c8b7a
Version: 2
Timestamp: 2025-10-21T11:04:04.568021Z
Locked: false
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 30
Powerstats: Strength: 99
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
Appearance: Eye Colour: Brown
Appearance: Hair Colour: Brown
Work: Occupation: Law enforcement
Work: Base: Tre Kullar
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============

Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


R

Reconciliation started at at 2025-10-21 11:04:09.880651Z



Hero: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide ("Bamse") does not exist online: invalid id - delete it from local database? (y = yes, n = no, a = all, q = quit)
a
Deleted hero:

=============
id: 96531606-192c-4931-b57b-0d78e53c8b7a
Version: 2
Timestamp: 2025-10-21T11:04:04.568021Z
Locked: false
External ID: this-is-internally-a-string-that-happens-to-be-integers-in-the-api-so-hopefully-this-wont-collide
Name: Bamse
Powerstats: Intelligence: 30
Powerstats: Strength: 99
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
Appearance: Eye Colour: Brown
Appearance: Hair Colour: Brown
Work: Occupation: Law enforcement
Work: Base: Tre Kullar
Connections: Group Affiliation: Bamse, Lille Skutt och Skalman (tm)
Connections: Relatives: Brummelisa (primär partner), Nalle-Maja, Teddy, Brum, Brumma
Image: Url: null
=============

Hero: 69 ("Batman") is already up to date
Hero: 70 ("Batman") is already up to date
Hero: 71 ("Batman II") is already up to date

Reconciliation complete at 2025-10-21 11:04:20.459330Z: 0 heroes reconciled, 1 heroes deleted.
```

#### _Manually delete_ a local _Hero_
To (manually) _Delete_ a locally saved _Hero_, return to the _Main_ menu and press `D` and enter a search string.

The search string will be interpeted as _SHQL™_ if possible and otherwise be treated as a string to be matched against all fields.

Candiates will be presented by descending order of strenght. Type `y` to _Delete_ the _Hero_ or `n` to review the next one or `c` to cancel.

Typing `y` will give the user the chance of of revewing the _Hero_ to be _Deleted_ and confirm _Deletion_ with `y` or
abort the operation with `n`.

```
D
Enter a search string:
Batman II
Found 2 heroes:

Delete the following hero?
=============
id: 69287f96-87fe-4f37-b050-5b650b3cfdf7
Version: 1
Timestamp: 2025-10-21T10:45:06.300227Z
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
Work: Occupation:
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============
 (y = yes, n = next, c = cancel)
y

Do you really want to delete hero with the following details?
=============
id: 69287f96-87fe-4f37-b050-5b650b3cfdf7
Version: 1
Timestamp: 2025-10-21T10:45:06.300227Z
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
Work: Occupation:
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============
 (y/n)
y
Deleted hero:

=============
id: 69287f96-87fe-4f37-b050-5b650b3cfdf7
Version: 1
Timestamp: 2025-10-21T10:45:06.300227Z
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
Work: Occupation:
Work: Base: 21st Century Gotham City
Connections: Group Affiliation: Batman Family, Justice League Unlimited
Connections: Relatives: Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)
Image: Url: https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg
=============

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

#### _Erase_ entire database
The menu option `E` (for "erase") will prompt the user for _Deleting_ all the _Heroes_ and despite the popular notion, they don't live forever so be careful with this.
`L` (for "list") displays all heroes unfiltered by descending order of strength, but `T` (for "top") filters out only the `n` best and `S` (for "search") filters by the given search term.

### Unit tests
There are plenty of unit tests. `v04\tests\json_mapping_test.dart` shows how the entire example json blob is parsed to a `HeroModel`.

The editing done by the CLI was in fact using json as an intermediate format  already in `v03` so the app was readily connected to the API with few adaptations.

`v04\tests\sql_generation_test.dart` shows the expected SQL that is generated, but the reason author(s) don't type it directly but generate it from metadata in the `Field<T,V>`-definitions is simply to be able to prevent bugs when changing something in the structure. Code generation *always* saves time in the end.

### Conflict resolution
Also note that the parser will try to handle conflicting _Height_ or _Weight_ information, see  `v04\tests\weight_test.dart` and `v04\tests\height_test.dart` respecively, and `test('Can parse most heros')` in `v04\tests\hero_service_test.dart`, and in particular the consistency checking logic in `v04\value_types\value_type.dart`:

```
  static (T?, String?) checkConsistency<T extends ValueType<T>>(
    String valueTypeName,
    ValueType<T> value,
    String valueSource,
    ValueType<T> parsedValue,
    String input,
    ParsingContext? parsingContext,
    ConflictResolver<T>? conflictResolver,
  )
``` 
which really was the main focus of this assigment for me, roughly 95% of the time spent.

Whenever the _Online_ _Search_ encounters _Heroes_ with conflicting _Height_ or _Weight_ information, the user is given the choice of which system of units to use:

```
Enter a menu option (R, S, U or X) and press enter:
[R]econcile local heroes with online updates
[S]earch online for new heroes to save
[U]nlock manually amended heroes to enable reconciliation
E[X]it and return to main menu


S
Enter a search string:
Q

Online search started at 2025-10-21 21:50:50.682706Z


When parsing Appearance -> Weight for new hero with externalId: "38" and name: "Aquaman": Conflicting weight information: metric '146 kg' (parsed from '146 kg') corresponds to '322 lb' after converting back to imperial -- expecting '147 kg' in order to match first value of '325 lb' (parsed from '325 lb').
Type 'i' to use the imperial weight '325 lb' or 'm' to use the metric weight '146 kg' value to resolve this conflict or enter to abort:
m

Resolve further weight conflicts by selecting the metric value for weight? (Y/n)
y
When parsing Appearance -> Weight for new hero with externalId: "38" and name: "Aquaman": Conflicting weight information: metric '146 kg' (parsed from '146 kg') corresponds to '322 lb' after converting back to imperial -- expecting '147 kg' in order to match first value of '325 lb' (parsed from '325 lb'). Resolving by using value in previously decided system of units (metric) for weight: '146 kg'.

Found 18 heroes online:

Save the following hero locally?

y
(...)
```

When _Reconciling_ an already saved _Hero_ with the API, any conflicting _Weight_ or _Height_ information is resolved to the _current_ system of units for the _Hero_, i.e. the system initally selected when _Searching_ for the _Hero_ _Online_:


```
R

Reconciliation started at at 2025-10-21 22:15:13.530387Z


When parsing Appearance -> Weight for hero with id: 58f3b09e-de42-4380-a275-53f9f47a8eaa, externalId: "38" and name: "Aquaman": Conflicting weight information: metric '146 kg' (parsed from '146 kg') corresponds to '322 lb' after converting back to imperial -- expecting '147 kg' in order to match first value of '325 lb' (parsed from '325 lb'). Resolving by using value in current system of units (metric) for weight: '146 kg'.
Hero: 38 ("Aquaman") is already up to date
When parsing Appearance -> Weight for hero with id: c96e2e01-72ec-40d3-9d84-299c137f3152, externalId: "573" and name: "Sasquatch": Conflicting weight information: metric '900 kg' (parsed from '900 kg') corresponds to '1984 lb' after converting back to imperial -- expecting '907 kg' in order to match first value of '2000 lb' (parsed from '2000 lb'). Resolving by using value in current system of units (metric) for weight: '900 kg'.
Hero: 573 ("Sasquatch") is already up to date
Hero: 129 ("Bomb Queen") is already up to date
Hero: 37 ("Aqualad") is already up to date
Hero: 359 ("Jesse Quick") is already up to date
Hero: 536 ("Quicksilver") is already up to date
Hero: 70 ("Batman") is already up to date
Hero: 36 ("Aquababy") is already up to date
Hero: 535 ("Question") is already up to date
Hero: 533 ("Q") is already up to date
Hero: 309 ("Harley Quinn") is already up to date
Hero: 480 ("Mystique") is already up to date
Hero: 71 ("Batman II") is already up to date
Hero: 286 ("Goblin Queen") is already up to date
Hero: 521 ("Plastique") is already up to date
Hero: 537 ("Quill") is already up to date
Hero: 712 ("White Queen") is already up to date
Hero: 113 ("Blaquesmith") is already up to date
Hero: 534 ("Quantum") is already up to date
Hero: 19 ("Allan Quatermain") is already up to date

Reconciliation complete at 2025-10-21 22:15:23.644413Z: 0 heroes reconciled, 0 heroes deleted.
```

## SHQL - Super Hero Query Language ™
Finally but not least, local searches uses the _SHQL™_, short for _Super Hero Query Language™_ that is adapted from the calculator developed in project in `v01` but extended to be useful as a predicate for `HeroModel`-instances.

## Economical fallback example without utilizing SHQL™
To match Batman, type:

`Batman`

This locates all _Heroes_ where any field contains the string `Batman` in any letter-case whitout involving the _SHQL™_ engine to keep the instance pricing at a minimal level.

_Note that the parser assumes that usage of SHQL™ is intentional if a search term is a valid _SHQL™_ expression. The author(s) of this project will not claim responsibiliy for any costs incurred due to unintentional _SHQL™_ engine utilization._

## Basic examples *with* SHQL™

### Name-search and match
To actually enjoy the capapabilites of _SHQL™_, type:

`name ~ "Batman"`

which finds all _Heroes_ where only the `name` field contains the string `"Batman"` in any letter-case.

Type:

`name = "Batman"`

to find all the _Heroes_ where the `name` field is exactly `"Batman"` with an upper-case `B` and lower-case `atman`.

Type

`name in ["Batman", "Robin"]`

to find all _Heroes_ where the `name` field is exactly `"Batman"` with an upper-case `B` and lower-case `atman` or `"Robin"` with an upper-case `R`and lower-case `robin`.

Type: `lowercase(name) in ["batman", "robin"]` to find all _Heroes_ where the name in any letter case is either `"batman`" or `"robin"`.

### Villian (*Biography.Alignment*) search
As the `Alignment` enum in the `Biography` section are mapped to _SHQL™_ as the constants `UNKNOWN` = `0`, `NEUTRAL` = `1`, `MOSTLY_GOOD` = `2`, `GOOD` = `3`, `REASONABLE` = `4`, `NOT_QUITE` = `5`, `BAD` = `6`, `UGLY` = `7`, `EVIL` = `8`, `USING_MOBILE_SPEAKER_ON_PUBLIC_TRANSPORT` = `9`, respectively, one can type:

`biography.alignment = bad`

or:

`alignment > good`

or whatever criterion meets the user's personal villain definition to filter on _Villains_.

To find _Villians_ that are significantly (10%) _stronger_ than they are _smart_, try:

`biography.alignment > reasonable AND powerstats.strength >= powerstats.intelligence*1.1`.

To find dumb _Villians_ with the letter `x` in their name, try out:

`name ~ 'x' AND biography.alignment >= bad AND powerstats.intelligence < 50`, assuming these adhere to well-defined standard criteria.

### Gender (*Appearance.Gender*) search
As the `Gender` enum in the `Appearance` section are mapped to _SHQL™_ as the constants `UNKNOWN` = `0`, `AMBIGUOUS` = `1`, `MALE` = `2`, `FEMALE` = `3`, `NON_BINARY` = `4`, `WONT_SAY` = `5`, respectively, one can type:

`biography.gender != male` or `biography.gender in [female, non_binary]` to find female and / or non-binary _Heroes_.

### BMI (body-mass index) search:
As `Appearance.Weight`and `Appearance.Height` are normalised in SI-units one can easily use them in comparisons.

To find _Heroes_ meeting WHOs definition of _obesity_ who sport a BMI (body-mass-index) at or aboove the magic cutoff of 25 kg per m<sup>2</sup>, type:

`appearance.weight.kg / pow(appearance.height.m, 2) >= 25`

_NB: This actually reveals a flaw both in the WHO model, and the underlying data as no distinction is done between body fat and lean mass such as pure rock for certain giants._

## Base search:
To find _troglodytes_, try:

`work.base ~ "cave"`

## General
The following enums are mapped to integer constants:
From the `Gender` enum in `Appearance`:  `UNKNOWN` = `0`, `AMBIGUOUS` = `1`, `MALE` = `2`, `FEMALE` = `3`, `NON_BINARY` = `4`, `WONT_SAY` = `5`

From the `Alignment` enum in `Biography`: `UNKNOWN` = `0`, `NEUTRAL` = `1`, `MOSTLY_GOOD` = `2`, `GOOD` = `3`, `REASONABLE` = `4`, `NOT_QUITE` = `5`, `BAD` = `6`, `UGLY` = `7`, `EVIL` = `8`, `USING_MOBILE_SPEAKER_ON_PUBLIC_TRANSPORT` = `9`

From the `SystemOfUnits` enum in `value_types\value_type.dart`: `METRIC` = `0`, `IMPERIAL` = `1`

Four (4) string literals are accpted:

Ordinary (_garden variety_) double quoted string literal enclosed in `"` e.g. `"hello world"`. This uses `\` (backslash) as an unsurprising escape  character i.e. `"hello \"world\""` to enclose `world` in double quotes if one is not sure what the `world` is or where it's heading.

Ordinary (_garden variety_) single quoted string literal enclosed in `'`, e.g. `'hello world'`. This also uses `\` (backslash) as an unsurprising escape character i.e. `'hello \'world\''` to enclose `world` in single quotes if none is almost but not *quite* shre what the `world` is or where it's heading.

To work with regular expressions in matching, raw double- and single-quoted strings are also supported, i.e. `r"hello\s+world"` and `r'hello\s+world'`, respectively to allow any amount of wordly space.

As relational operators work as expected, an expression like `good < reasonable` evaluates to `3 < 4` which is `TRUE` (`1`).
`~` and `!~` stands for matches and doesn't match, respectively, so `"Super Man" ~ r"Super.*Man"` evaluates to  `TRUE` (`1`)

### All fields (_pseudoconstants_)
The fields on the actual `HeroModel` object being evaluated with a predicate are mapped to the following _pseudo-constants_ in the _SHQL™_ language, given the actual values for the current `HeroModel`.

(They are not _variables_ as the _SHQL™_ has no means of _changing_ them):

- `id`  - a `string` representing the local `Uuid`.
- `external_id` - as a `string`, corresponding to the `id` field in the API,
- `version` - `integer`
- `timestamp` - as a Iso8601 `string`
- `locked` - as `0` or `1` (`TRUE` or `FALSE`)
- `name` - `string`
- `powerstats.intelligence` - `integer`
- `powerstats.strength` - `integer`
- `powerstats.speed` - `integer`
- `powerstats.durability` - `integer`
- `powerstats.power` - `integer`
- `powerstats.combat` - `integer`
- `biography.full_name` - `string`
- `biography.alter_egos` - `string`
- `biography.aliases` - `string` representation of the aliases list.
- `biography.place_of_birth` - `string`
- `biography.first_appearance` - `string`
- `biography.publisher` - `string`
- `biography.alignment` - `integer` (see the `Alignment` enum above)
- `appearance.gender` - `integer` (see the `Gender` enum above)
- `appearance.race` - `string`
- `appearance.height.m` - `double`
- `appearance.height.system_of_units` - `integer` (see the `SystemOfUnits` enum above)
- `appearance.weight.kg` - `double`
- `appearance.weight.system_of_units` - `integer` (see the `SystemOfUnits` enum above)
- `appearance.eye_colour` - `string`
- `appearance.hair_colour` - `string`
- `work.occupation` - `string`
- `work.base` - `string`
- `connections.group_affiliation` - `string`
- `connections.relatives` - `string`
- `image.url` - `string`

### Mathematical constants
Inherited from the calculator project, the following constants are still defined and in most cases mapped directly to constants in `math.dart`:

`E`, `LN10`, `LN2`, `LOG2E`, `LOG10E`, `PI`, `SQRT1_2`, `SQRT2`, `AVOGADRO`, `ANSWER`, `TRUE`, `FALSE`

### Mathematical functions
Inherited from the calculator project, the following functions(arities), are still defined and mapped directly to functions in `math.dart` to be used in `HeroModel` searches (see the BMI-example above for a practical application using `POW(2)` so the author(s) remain conviced the rest will come in handy):

`MIN(2)`, `MAX(2)`, `ATAN2(2)`, `POW(2)`, `SIN(1)`, `COS(1)`, `TAN(1)`, `ACOS(1)`, `ASIN(1)`, `ATAN(1)`, `SQRT(1)`, `EXP(1)`, `LOG(1)`

### String functions
The language has been extended with the following string functions:

`LOWERCASE(1)`, `UPPERCASE(1)`

### Operators
#### Unary
##### Boolean
 `NOT` (alias `!`)
##### Arithmentic
 `-`, `+`
#### Binary
#### Boolean
`AND`, `OR`, `XOR`
##### Relational
`=`, `<>` (alias `!=`), `>`, `<`, `<=`, `>=`
##### Matching
`IN` (works for string or lists),  `~`, `!~`
##### Arithmetic
`*`, `/`, `%`, `+`, `-`
