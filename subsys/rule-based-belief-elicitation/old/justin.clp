(defrule homeless
 "Homeless?"
 (is-homeless ?person)
 =>
 )

(defrule dental-and-medical-screening
 "Dental & Medical screening"
 =>
 )

(defrule housing-information
 "housing information"
 =>
 )

(defrule state-id-cards
 "state ID cards"
 (not (has-state-id-card ?person))
 =>
 (assert (should-have-goal ?person (str-cat "(has-state-id-card " ?person ")")))
 )

(defrule catered-lunch-and-soup-kitchen-and-food-bank
 "catered lunch & soup kitchen & food bank"
 (is-homeless ?person)
 =>
 (assert (should-have-goal ?person (str-cat "(know-location-of-nearest " ?person " soup-kitchen)")))
 (assert (should-have-goal ?person (str-cat "(know-location-of-nearest " ?person " food-bank)")))
 )

(defrule haircuts
 "haircuts"
 =>
 )

(defrule pet-care
 "pet care"
 (has-pet ?person)
 =>
 )

(defrule veteran-s-assistance
 "veteran's assistance"
 =>
 )

(defrule women-s-health
 "women's health"
 =>
 )

(defrule bus-cards
 "bus cards"
 =>
 )

(defrule gift-certificates
 "gift certificates"
 =>
 )

(defrule social-security-number
 "social security number"
 (is-citizen-of ?person USA)
 =>
 (has-social-security-number ?person)
 ;; (needs ?person (know ?person (social-security-number-of ?person ?number)))
 ;; person needs to know social-security-nubmer of person
 ;; (needs e1 x1 e2)
 ;; (person x1)
 ;; 
 )

(defrule proof-of-address
 "proof of address"
 =>
 )

(defrule ID-or-identifying-documents-or-drivers-license
 "ID or identifying documents or drivers license"
 =>
 )

(defrule benefits
 "benefits"
 =>
 )

(defrule proof-of-income
 "proof of income"
 =>
 )

(defrule bank-account-cards
 "bank account cards"
 =>
 )

(defrule savings-and-investments
 "savings and investments"
 =>
 )

(defrule education
 "education"
 =>
 )

(defrule certifications
 "certifications"
 =>
 )

(defrule resume-and-work-experience
 "resume and work experience"
 =>
 )

(defrule skill-sets
 "skill sets"
 =>
 )

(defrule interests
 "interests"
 =>
 )

(defrule emergency-contacts
 "emergency contacts"
 =>
 )

(defrule pager
 "pager"
 =>
 )

(defrule cell-phone
 "cell phone"
 =>
 )

(defrule telephone-number
 "telephone number"
 =>
 )

(defrule Internet-access
 "Internet access"
 =>
 )

(defrule computer-and-printer-and-peripherals
 "computer and printer and peripherals"
 =>
 )

(defrule calculator
 "calculator"
 =>
 )

(defrule pda-or-dayplanner-booklet
 "pda or dayplanner booklet"
 =>
 )

(defrule calendar-of-events
 "calendar of events"
 =>
 )

(defrule camera-or-digital-camera
 "camera or digital camera"
 =>
 )

(defrule music
 "music"
 =>
 )

(defrule emergency-kit
 "emergency kit"
 =>
 )

(defrule water-filter
 "water filter"
 =>
 )

(defrule water-desalination-and-filter-and-sterilization-equipment
 "water desalination and filter and sterilization equipment"
 =>
 )

(defrule medical-kit
 "medical kit"
 =>
 )

(defrule nearby-hospitals-and-clinics
 "nearby hospitals and clinics"
 =>
 )

(defrule psychological-therapy-and-psychiatry
 "psychological therapy and psychiatry"
 =>
 )

(defrule drug-addiction-and-rehabilitation-groups
 "drug addiction and rehabilitation groups"
 =>
 )

(defrule medical-information-group-therapy-and-participation-in-research-studies
 "medical information group therapy and participation in research studies"
 =>
 )

(defrule parole-officer-and-rehabilitation-from-past-law-enforcement-convictions-and-jail-and-prison-time
 "parole officer and rehabilitation from past law enforcement convictions and jail and prison time"
 =>
 )

(defrule personal-attorney-at-law-or-pro-bono-attorney-consoltation
 "personal attorney at law or pro-bono attorney consoltation"
 =>
 )

(defrule accountant-or-financial-payee
 "accountant or financial payee"
 =>
 )

(defrule schedule-of-nearby-town-meetings-and-interacting-with-local-and-state-and-federal-government-and-voting-information
 "schedule of nearby town meetings and interacting with local and state and federal government and voting information"
 =>
 )

(defrule postage-stamps-and-paper-and-envelopes-and-stationary-including-writing-utensils
 "postage stamps and paper and envelopes and stationary including writing utensils"
 =>
 )

(defrule Alcoholics-Anonymous-group
 "Alcoholics Anonymous group"
 =>
 )

(defrule list-of-supply-of-consumables
 "list of supply of consumables"
 =>
 )

(defrule hygene-and-shower-and-shave-and-toilet-and-toothbrush
 "hygene and shower and shave and toilet and toothbrush"
 =>
 )

(defrule laundry-facilities-or-nearby-laundromat
 "laundry facilities or nearby laundromat"
 =>
 )

(defrule night-life-&-entertainment
 "night life & entertainment"
 =>
 )

(defrule music-collection
 "music collection"
 =>
 )

(defrule video-collection
 "video collection"
 =>
 )

(defrule magazine-collections
 "magazine collections"
 =>
 )

(defrule misc-entertainment
 "misc entertainment"
 =>
 )

(defrule books-read
 "books read"
 =>
 )

(defrule books-wanted-to-read
 "books wanted to read"
 =>
 )

(defrule wishlist-of-potential-future-purchases-or-donations
 "wishlist of potential future purchases or donations"
 =>
 )

(defrule library-card
 "library card"
 =>
 )

(defrule online-memberships-and-email-addresses-and-shell-accounts-and-ebay-and-paypal-accounts
 "online memberships and email addresses and shell accounts and ebay and paypal accounts"
 =>
 )

(defrule small-business-information
 "small business information"
 =>
 )

(defrule tax-status-and-IRS-related-information
 "tax status and IRS related information"
 =>
 )

(defrule car-pooling
 "car-pooling"
 =>
 )

(defrule post-office-box
 "post office box"
 =>
 )

(defrule security-deposit-box
 "security deposit box"
 =>
 )

(defrule foreign-and-domestic-business-and-social-connections
 "foreign and domestic business and social connections"
 =>
 )

(defrule clubs-and-memberships
 "clubs and memberships"
 =>
 )

(defrule fitness-groups-or-team-sports-or-gym-membership
 "fitness groups or team sports or gym membership"
 =>
 )

(defrule food-stamps
 "food stamps"
 =>
 )

(defrule vitamins
 "vitamins"
 =>
 )

(defrule medication-and-prescriptions
 "medication and prescriptions"
 =>
 )

(defrule electricity-assistance
 "electricity assistance"
 =>
 )

(defrule telephone-bill-assistance
 "telephone bill assistance"
 =>
 )

(defrule nearby-thrift-shops
 "nearby thrift shops"
 =>
 )

(defrule clothing-and-shoes-and-socks-and-underwear-and-undershirts
 "clothing and shoes and socks and underwear and undershirts"
 =>
 )

(defrule backpack-or-briefcase-or-satchel
 "backpack or briefcase or satchel"
 =>
 )

(defrule storage-bin
 "storage bin"
 =>
 )

(defrule shelving
 "shelving"
 =>
 )

(defrule home-garden
 "home garden"
 =>
 )

(defrule lawnmower
 "lawnmower"
 =>
 )

(defrule snow-removal
 "snow removal"
 =>
 )

(defrule vehicles-such-as-bus-and-bike-and-skates-and-skateboard-and-automobile-and-skis-and-snowshoes
 "vehicles such as bus and bike and skates and skateboard and automobile and skis and snowshoes"
 =>
 )

(defrule marital-or-relationship-status-and-friend-and-family-contact-information-including-offspring-and-custody-status
 "marital or relationship status and friend and family contact information including offspring and custody status"
 =>
 )

(defrule life-goals
 "life goals"
 =>
 )

(defrule immediate-goals
 "immediate goals"
 =>
 )

(defrule financial-information-including-amount-of-spending-money-after-bills-and-monthly-expenses
 "financial information including amount of spending money after bills and monthly expenses"
 =>
 )