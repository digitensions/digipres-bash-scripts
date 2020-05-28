#!/usr/bin/env python3

'''
Fun script that references a dictionary of films and ranks, to see if you favourite film made it to the BFI's top 50 list.
Asks you to enter a film you'd like to check
Lists the item and it's rank if successful
If not, asks if you'd like to see the complete list (this needs an exit)
Asks finally if you'd like to restart the process by checking another title.
'''

films = {
    "The Mule": [50],
    "The Favourite": [49],
    "Just Don't Think I'll Scream": [48],
    "If Beale Street Could Talk": [47],
    "If Rose Plays Julie": [46],
    "Rocks": [45],
    "Honeyland": [44],
    "Holiday": [43],
    "I Lost My Body": [42],
    "Hale County This Morning, This Evening": [41],
    "Ray and Liz": [40],
    "Joker": [39],
    "Eigth Grade": [38],
    "No Data Plan": [37],
    "America": [36],
    "Zombi Child": [35],
    "Synonyms": [34],
    "Ash Is Purest White": [33],
    "Booksmart": [32],
    "Knives Out": [31],
    "In Fabric": [30],
    "I Was at Home, But...": [29],
    "Varda by Agnès": [28],
    "Ad Astra": [27],
    "The Hottest August": [26],
    "The Farewell": [25],
    "A Hidden Life": [24],
    "Transit": [23],
    "Border": [22],
    "Beanpole": [21],
    "Martin Eden": [20],
    "Hustlers": [19],
    "Happy as Lazzaro": [18],
    "The Lighthouse": [17],
    "Midsommar": [16],
    "For Sama": [15],
    "Marriage Story": [14],
    "Monos": [13],
    "Uncut Gems": [12],
    "High Life": [11],
    "Vitalina Varela": [10],
    "Us": [9],
    "Bait": [8],
    "Atlantics": [7],
    "Pain and Glory": [6],
    "Portrait of a Lady on Fire": [5],
    "Once Upon a Time... in Hollywood": [4],
    "The Irishman": [3],
    "Parasite": [2],
    "The Souvenir": [1]
}

def main():
    while True:
        print("Hello! welcome to the BFI 'Films of 2019' checker")
        print("You can use this script to check whether your favourite film of 2019")
        print("made it to their top 50 and which position the BFI gave it.")
        choice = str(input("Which film do you want to check?: ")).strip().title()
        if choice in films:
            print("The film",choice,"is in the top 50, positioned at number",films[choice][0])
        else:
            print("Your film choice doesn't appear in the list, what a shame :(")

    answer = str(input("Would you like to see the complete list of films? [yes/no]: ")).strip().lower()
    # This doesn't work as the list repeats infinitely, need to fix
    while answer is "yes":
        print("The BFI's top 50 films for 2019:")
        for key, value in films.items():
            print(key, ' : ',value)
        
    try_again = str(input("Would you like to try checking another film title? [yes/no]: ")).strip().lower()
    if try_again[0] == "yes":
        # A return to beginning solution needs finding for here
        main()
    else:
        print("Thank you for trying out this script! Have a lovely day :)")
        exit

# Is this needed?
main()
