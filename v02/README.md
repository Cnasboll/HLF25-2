# v02
Manually generated README for v02

Stand in `HLF25-2\v02` and type `dart run`

This creates a little sqlite db (`v02.db`) that contains a simple table `heroes` with the following structure:

  ```id TEXT PRIMARY KEY,
	name TEXT NOT NULL,
	strength INTEGER NOT NULL,
	gender TEXT NOT NULL,
	race TEXT NOT NULL,
	alignment TEXT NULL
```

The `id` is a `Uuid`, `gender` and `alignment` are mapped from enums. Race is a `String`, but if I'd had more time that would be a FK to a different `race` table with more information!

This time I managed to map commands to lambdas (as I wanted to do with the mathematical functions in the previous project to avoid switches) so the menu is constructed as a map of command to the lambda that it executes and a hint.

Note that the menu below is fully constructed in function `generatePrompt()` that takes the `Map<String, (Function, String)>` and generates the rest of the text on the fly as the letters are the keys and the text is the second element of the value.

```
Enter a menu option (A, L, T, S, U, D, C or Q) and press enter:
[A]dd a new hero (will prompt for details)
[L]ist all heroes
List [T]op n heroes (will prompt for n)
[S]earch matching heroes (will prompt for a search string)
[U]pdate a hero
[D]elete a hero
[C]lean database (delete all heroes)
[Q]uit (exit the program)
```

To add a new hero press `A[dd]` and enter values as prompted. An empty string is treated as abort.
User will be prompted if the new hero will be saved or not.

```
A
Enter name (Full) or enter to abort:
Bamse
Enter strength (integer) or enter to abort:
99
Enter gender (unknown, ambiguous, male, female, nonBinary, wontSay) or enter to abort:
m
Enter race (species in Latin or English) or enter to abort:
Ursus arctos
Enter alignment (unknown, neutral, mostlyGood, good, reasonable, notQuite, bad, ugly, evil, usingMobileSpeakerOnPublicTransport) or enter to abort:
mostly

Save new hero with the following details?
=============
id: 0f23a850-1d2a-45ed-8772-1547438def31
name: Bamse
strength: 99
gender: male
race: Ursus arctos
alignment: mostlyGood
=============
 (y/n)
y
Created hero:
=============
id: 0f23a850-1d2a-45ed-8772-1547438def31
name: Bamse
strength: 99
gender: male
race: Ursus arctos
alignment: mostlyGood
=============
```

To update an existing hero, press `U[pdate]` and enter a search string. Candiates will be presented by descending order
of strenght. Press `y` to update a hero or `n` to review the next one or `c` to cancel.
Pressing `y` will give the user the chance of changing every value and keep current one with pressing enter.
Afterwards the changed fields will be reivewed and allow the user to accept them with `y` or abort them with `n`.

```
u
Enter a search string:
b
Found 4 heroes:

Update the following hero?
=============
id: 0f23a850-1d2a-45ed-8772-1547438def31
name: Bamse
strength: 99
gender: male
race: Ursus arctos
alignment: mostlyGood
=============
 (y = yes, n = next hero, c = cancel)
n

Update the following hero?
=============
id: 34356d65-5a12-4fc9-8e57-da77008ec40a
name: Robin
strength: 99
gender: male
race: human
alignment: usingMobileSpeakerOnPublicTransport
=============
 (y = yes, n = next hero, c = cancel)
y
Enter name (Full) or enter to keep current value (Robin):

Enter strength (integer) or enter to keep current value (99):
98
Enter gender (unknown, ambiguous, male, female, nonBinary, wontSay) or enter to keep current value (male):

Enter race (species in Latin or English) or enter to keep current value (human):

Enter alignment (unknown, neutral, mostlyGood, good, reasonable, notQuite, bad, ugly, evil, usingMobileSpeakerOnPublicTransport) or enter to keep current value (usingMobileSpeakerOnPublicTransport):


Save the following changes?
=============
strength: 99 => 98
=============
   (y/n)
y
Updated hero:

=============
id: 34356d65-5a12-4fc9-8e57-da77008ec40a
name: Robin
strength: 98
gender: male
race: human
alignment: usingMobileSpeakerOnPublicTransport
=============
```

To delete an existing hero, press `D[elete]` and enter a search string. Candiates will be presented by descending order
of strenght. Press `y` to delete the hero or `n` to review the next one or `c` to cancel.
Pressing `y` will give the user the chance of of revewing the hero to be deleted and confirm deletion with `y` or
abort the operation with `n`.

```
d
Enter a search string:
bat
Found 1 heroes:

Delete the following hero?
=============
id: ca0eef7f-dee2-4a8f-aee4-be604f64940f
name: Batman
strength: 2
gender: ambiguous
race: human
alignment: mostlyGood
=============
 (y = yes, n = next hero, c = cancel)
y

Do you really want to delete hero with the following details?
=============
id: ca0eef7f-dee2-4a8f-aee4-be604f64940f
name: Batman
strength: 2
gender: ambiguous
race: human
alignment: mostlyGood
=============
 (y/n)
y
Deleted hero:

=============
id: ca0eef7f-dee2-4a8f-aee4-be604f64940f
name: Batman
strength: 2
gender: ambiguous
race: human
alignment: mostlyGood
=============
```

The menu option `C[lean]` will prompt the user for deleting all the heroes and despite the popular notion, they don't live forever so be careful with this.
`L[ist]` displays all heroes unfiltered by descending order of strength, but `T[op]` filters out only the `n` best
and `S[earch]` filters by the given search term.