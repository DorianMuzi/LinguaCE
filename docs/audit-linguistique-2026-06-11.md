# Rapport d'audit linguistique — contenu tchétchène LinguaCE

> Audit réalisé le 2026-06-11 par l'agent `chechen-linguist` (lecture seule).
> Référence normative : la grammaire du system prompt de Noxçi
> (`lib/services/claude_service.dart`) et sa table de translittération.
> Aucun fichier n'a été modifié.

**Référence normative utilisée** : la grammaire du system prompt lui-même (`lib/services/claude_service.dart`, lignes 18–363) : 6 classes nominales, accord transitif=objet / intransitif=sujet, 4 formes de la copule, 11 cas, et la table de translittération « Muziŋ Dar » (lignes 183–203). Conformément aux limites du projet, l'audit n'a pas tenté de reconstituer les règles serveur de translittération ; il signale uniquement les contradictions entre les sorties latines en dur et la table affichée dans le prompt.

---

## 1. `lib/services/claude_service.dart` — le system prompt (grammaire de référence)

### 1.A — Orthographe de la palochka Ӏ : trois graphies concurrentes dans le même fichier

Le début du prompt (lignes 25–158) utilise correctement **Ӏ** (U+04C0) : `КӀант`, `ПхьагӀал`, `гӀо`, `ХӀара`, `ХӀокхуьнан`… Mais à partir de la ligne 213, le fichier bascule sur **I latin**, et trois lignes utilisent le **chiffre 1**. C'est une contradiction interne directe avec la propre règle du prompt (ligne 203) — et surtout, ce texte est envoyé au modèle comme référence orthographique.

| Ligne | Citation (extrait) | Graphie fautive |
|---|---|---|
| 173 | `ӀуьйреI = Matin` | I latin parasite en fin de mot → `Ӏуьйре` |
| 174 | `ДаймохкI = Patrie` | I latin parasite → `Даймохк` (aucune palochka dans ce mot) |
| 213, 217, 222, 233, 265, 274, 277, 279, 281, 287, 290, 291, 294, 301, 303–307, 314, 329, 331, 336, 337, 339 | `ХIара`, `тIе`, `кIант`, `йоI`, `цIа`, `ворхI`, `бIе`, `шолгIа`, `вогIийла`, `КIайн`, `ХIаъ`… | I latin au lieu de Ӏ |
| 312, 328 | `1уьйре дика хуьлда хьан!` / `1уьйре = matin` | chiffre **1** au lieu de Ӏ |
| 325 | `Б1аьрг = œil` | chiffre 1 → `БӀаьрг` |
| 335 | `Эх1!` | chiffre 1 → `ЭхӀ!` |
| 342, 344 | `Доттаг1 шираниг…` / `пхьан доттаг1 вацахь` | chiffre 1 → `ДоттагӀ` |
| 331 | `IаьржаI = noir` | I latin des deux côtés → `Ӏаьржа` (cf. graphie correcte dans `exercise_screen.dart:197`) |

**Confiance : erreur certaine** (incohérence interne massive ; le même mot « matin » apparaît sous 3 graphies : `ӀуьйреI` l.173, `1уьйре` l.312 et l.328).

### 1.B — Mots à scripts mélangés (homoglyphes cyrillique/latin)

Vérifié au niveau des points de code :

| Ligne | Citation | Problème | Correction |
|---|---|---|---|
| 30 | `ПхьагӀал (лièvre)` | `л` cyrillique dans le mot français | `lièvre` |
| 31 | `Наж (chêне)` | `не` cyrillique dans le mot français | `chêne` |
| 33 | `deза Ӏежаш` | `de` latin + `за` cyrillique | `деза Ӏежаш` |
| 33 | `ӀАж (pomme)` | majuscule incohérente | `Ӏаж` |
| 115 | `мала дāла` | `ā` latin (U+0101) dans un mot cyrillique | `мала дала` (ou notation de longueur à expliciter) |
| 157 | `Нoms propres` | `Н` cyrillique en tête du mot français | `Noms` |
| 179 | `компьютер→камputар` | mélange `кам`+`put`+`ар` | à réécrire entièrement (cf. point Discord) |
| 213 | `Déш ву` | `é` latin dans un mot cyrillique | `Деш ву` |
| 222 | `délahь → дацахь` | `déla` latin + `hь` cyrillique | `делахь → дацахь` |
| 241 | `Однократный (一fois)` | caractère chinois `一` | `(une fois)` |

**Confiance : erreur certaine** (corruption de script, indépendante de toute question de langue).

### 1.C — Contradictions internes avec la grammaire de référence elle-même

1. **l.9 vs l.14** — `noxçiyn mott` (l.9) vs `Noxçiyŋ mott` (l.14). La règle l.201 (« н final → ŋ dans les mots natifs ») impose `noxçiyŋ`. **Erreur certaine** (auto-contradiction).
2. **l.28** — `веза кӀант / veza k'ant` : la translittération `k'ant` viole la table officielle l.192 (`кӀ→k̇`). Correction : `veza k̇ant`. **Erreur certaine**.
3. **l.30** — `Classe Й-II (y-) : animaux domestiques — ПхьагӀал (lièvre)` : le lièvre n'est pas un animal domestique ; l'exemple contredit sa propre catégorie. Graphie `ПхьагӀал` (avec гӀ) douteuse (forme usuelle : `пхьагал`). **Erreur certaine** pour l'incohérence ; graphie **à valider par un natif**.
4. **l.118–119 vs l.104–105** — `яздигу` / `яздигира` : le paradigme l.104–105 (`Ди/Дийци`, `Дира/Дийцира`) impose `язди` (vu récent) et `яздира` (vu lointain). `яздигу` ne correspond à aucune forme du tableau. **Erreur certaine** ; forme exacte à confirmer par un natif.
5. **l.122** — `Ахьмад деш хиллера` glosé « Ahmed écrivait » : (a) le verbe est `деш` (faire), pas `яздеш` (écrire) ; (b) sujet d'un transitif → ergatif `Ахьмада`. **Erreur certaine**.
6. **l.125 vs liste l.126–131** — Titre « IMPÉRATIF — 5 FORMES » mais **6** formes listées. Idem l.209. **Erreur certaine**.
7. **l.167 vs l.314** — `Марша огӀийла = Bonjour (formel)` (l.167) vs `Марша вогIийла хьо/шу` (l.314). La forme l.314 porte le préfixe de classe в-, la forme l.167 en est dépourvue. Même incohérence dans `exercise_screen.dart` (§5). **Erreur certaine** côté incohérence ; forme de citation (`вогӀийла`/`йогӀийла`/`догӀийла`) **à valider par un natif**.
8. **l.190** — Table : `кь→q̇`. Le digraphe `кь` n'apparaît nulle part ailleurs ; le corpus utilise systématiquement **къ** (`юккъехь`, `ткъа`, `дуькъа`, `дакъа`) — et les chaînes CE utilisent bien `q̇` pour къ. La ligne devrait lire `къ→q̇`. **Erreur certaine**.
9. **l.217 vs l.31** — `цуьнан хазалла хуур яра` : accord en **я** (classe й) pour `хазалла`, alors que la règle l.31 classe les abstraits en **classe Д**. (En tchétchène réel, les abstraits en -алла sont de classe й ; c'est probablement la règle l.31 qui est trop large.) **Erreur certaine** (contradiction interne) ; découpage des classes **à valider par un natif**.
10. **l.219–220 vs l.226** — La même construction `луьйчур вара` est glosée « je me baignerai aussi » (futur, conditionnel réel) puis « Je me serais baigné (mais ce n'est pas arrivé) » (irréel). L'une des deux gloses est fausse. **Erreur certaine** ; arbitrage natif requis.
11. **l.236** — `la copule -елара/-велара/-елара/-белара` : `-елара` apparaît deux fois et la forme de classe д (`-делара`) manque. Attendu : `-велара/-елара(й)/-делара/-белара`. **Erreur certaine**.
12. **l.265** — `тIе маш лестадеш` : « ailes » = `тӀемаш` (pluriel de `тӀам`), écrit ici en deux mots dont le second (`маш`) n'existe pas. Correction : `тӀемаш`. **Erreur certaine** ; accord `лестадеш` **à valider**.
13. **l.272 vs l.58** — `Дика говр = bonne vitesse` : la section déclinaison définit `говр = cheval`. Correction : « bon cheval ». **Erreur certaine**.
14. **l.297** — Règle « Conjonction négative redoublée я...я » illustrée par un exemple à **un seul** `я`. **Erreur certaine** (exemple inadéquat).
15. **l.305 vs l.302** — `200 шийтта бIе` : `шийтта` = **12** (→ 1200, pas 200). Correction : `ши бӀе`. **Erreur certaine**.
16. **l.304** — `30 тIейткъа` : incohérent avec le système vigésimal de la même ligne (`50 шовзткъа итт` = 2×20+10). 30 attendu : `ткъе итт`. **Erreur certaine** ; forme exacte à confirmer.
17. **l.308** — `итт (×10 = иттазза)` : `итт` = 10, pas « ×10 » ; le multiplicatif est `иттазза` seul. **Erreur certaine** (formatage trompeur).
18. **l.331 vs l.163 et exercices** — `Цен = rouge` : palochka manquante. Le même fichier écrit `ЦIен байракх` (l.163) et les leçons enseignent `цӀен`. Correction : `ЦӀен`. **Erreur certaine**.
19. **l.332** — `Сийна = bleu/vert | Баьццара = vert | Сийна = bleu` : `Сийна` listé deux fois avec deux gloses différentes. **Erreur certaine** (doublon contradictoire) ; nuance bleu/vert **à valider par un natif**. `Сурх = rose` : douteux, **à valider**.
20. **l.344 vs l.75** — `пхьан доттаг1 вацахь` glosé « s'il n'est pas **ton** ami » : le génitif 2sg de la table est `Хьан`. Correction probable : `хьан`. **Erreur certaine** (contradiction avec la table) ; à confirmer (variante dialectale ?).
21. **l.187** — Table : `щ→ş` **et** `ш→ş` ; `и→i` **et** `ы→i` (mappings non injectifs). Peut-être voulu (système propriétaire) — **à confirmer par le mainteneur**.
22. **l.89–90 / l.219 vs l.77** — Les exemples utilisent `ахь` et `айхь` comme ergatif 2sg, la table donne `Ахьа`. **À harmoniser** ; validation native.

### 1.D — Points « à faire valider par un natif » (pas de contradiction interne)

- **l.138** : `Цхьа вац кхузахь` = « Personne n'est ici » — forme attendue : `Цхьа а вац` (particule `а`).
- **l.146** : `Цуьнан метта` — graphie `метта`/`меттана` à confirmer.
- **l.155** : `Сай → Сеш` (pluriel de « cerf »).
- **l.158** : `гӀоьмаш (menottes)` — lexème à vérifier.
- **l.170** : `Мичча = Où` — attendu plutôt `Мича` (direction) / `Мичахь` (localisation).
- **l.179** : `телевидение→телвидени` — forme de l'emprunt à confirmer.
- **l.254–256** : `Доьшучу кехат`, `Дешначу кехат`, `Дешначу стаг` — emploi de la forme oblique `-чу` devant un nom tête à l'absolutif ; on attendrait `доьшу кехат` / `дешна кехат`.
- **l.273–275** : degrés des adverbes `Диках` (mieux) et `Дико = pas très bien (atténuatif)` — sens à confirmer.
- **l.291** : `цIа йоьду я лаьттана = elle part ou reste` — `лаьттана` comme « (elle) reste » est douteux.
- **l.303** : `19 ткъайоьсна` — graphie à confirmer (`ткъаяьсна` ?).
- **l.306** : `цхьалгIа (1er)` — le premier ordinal est normalement supplétif (`хьалхара`).
- **l.315** : `Маршалла хаттар = Comment allez-vous?` — désigne plutôt l'acte de saluer, pas la question. (Repris dans `mock_data.dart:128`.)
- **l.317** : `Пиллакхехь ду иза = C'est poli` — mot attendu : `гӀиллакх` → `ГӀиллакхехь ду иза`. **Priorité haute pour validation**.
- **l.339** : `Ватталхьан = Je vais te montrer!` — interjection à confirmer.
- **l.348** : `Нехан говро ирхе дика йоккху` — accord `й` cohérent ; glose « monte bien la côte » à valider.

---

## 2. `supabase/migrations/*.sql` — **propre**

`20260604120000_init_schema.sql` et `20260604130000_more_lessons.sql` ne contiennent **aucun contenu en tchétchène** (uniquement des titres de leçons en français et du SQL). ⚠️ Conséquence : le contenu pédagogique réel des leçons vit côté client dans `lib/screens/exercise_screen.dart` — audité au §5.

---

## 3. `lib/data/mock_data.dart`

| Ligne | Citation | Règle violée | Correction | Confiance |
|---|---|---|---|---|
| 128 | `"Маршалла хаттар" (Marshalla khattar)` | `ш→ş`, `х→x` ; `kh`/`sh` n'existent pas dans le système | `Marşalla xattar` | **Erreur certaine** |
| 129 | `"доттагӀалла" (dottag'alla)` | `гӀ→ġ` ; l'apostrophe n'existe pas | `dottaġalla` | **Erreur certaine** |
| 132 | `"хаа" (khaa)` | `х→x` | `xaa` | **Erreur certaine** |
| 128 | « on dit "Маршалла хаттар" pour "Comment vas-tu ?" » | sémantique douteuse (cf. §1.D) | — | **À valider par un natif** |
| 115 | `Marşalla du!` | accord/classe de `маршалла` en formule d'accueil | — | **À valider par un natif** |

---

## 4. `lib/i18n/app_strings.dart` (chaînes CE)

Le fichier annonce lui-même (l.8–9) que le CE est « best-effort ».

### Erreurs certaines (contradictions avec la table du projet ou incohérences internes)

1. **l.53** — `'Sihha xir du!'` : `сихха` contient **х** simple → `x` ; `h` est réservé à `хӀ`. Le fichier écrit d'ailleurs `Sixa` (l.90). → `Sixxa xir du!` (sens « bientôt » = plutôt `kesta` : à valider).
2. **l.101, 107** — `'Tahanlera deşar'` / `'Tahanlera doş'` : `тахана` → `taxana` (correct l.329). → `Taxanlera`.
3. **l.113** — `'"Barkalla" — bart boçu doş noxçiyn matte.'` : (a) `noxçiyn` → `noxçiyŋ` ; (b) `boçu` → `bocu` si `боцу` ; (c) sémantique douteuse → **phrase à refaire valider par un natif**.
4. **l.128** — `'Jamaraŋ neq'` : `некъ` contient **къ** → `q̇`. → `neq̇`.
5. **l.141, 145, 407, 454** — `çekxdäxna`, `Çekxdälla`, `çekxdaqqa`, `çekxdälla` : `кх` doit donner `q`. La chaîne l.407 est incohérente en interne (`kx` dans `çekx-`, `q` dans `-daqqa`). → `çeqdälla`, `çeqdaqqa`, etc.
6. **l.360** — `'Juxa kxolla'` : (a) `юха` → `yuxa` (correct l.157, 218) ; (b) `кхолла` → `qolla` (cf. `qöllina` l.329). → `Yuxa qolla`. Idem **l.478, 496, 508** : `juxa-` → `yuxa-` (`j` = Ӏ dans ce système : la confusion change la lecture).
7. **l.524** — `'Kxin adres lela'` : `кхин` → `Qin`. **Erreur certaine**.
8. **l.432 vs 435 vs 536** — `Niysa ƶop` / `Nisa!` / `nisa yac` : même mot `нийса` sous deux graphies. `й→y` → `niysa` partout. **Erreur certaine**.
9. **l.440** — `'Dац iştta…'` : scripts mélangés (`D` latin + `ац` cyrillique). → `Dac iştta…`. **Erreur certaine**.
10. **l.46 vs 407 vs 518 vs 457** — `Djadakqa` / `daqqa` / `ṫaqqa` / `Däkqina` : `ккх` rendu tantôt `kq`, tantôt `qq`, y compris pour le même mot `даккха`. **Erreur certaine** (au moins une graphie fausse) ; règle à trancher côté système propriétaire.
11. **l.341** — `'Istori djadakqa yur yu.'` : (a) transitif → accord avec l'objet (`истори`, classe й) → `djayakqa`, pas `djadakqa` ; (b) futur classe й = `йийр ю` → `yiyr yu`, pas `yur yu`. **Erreur certaine** ; formulation finale à valider.
12. **l.58, 63 vs prompt l.312** — greeting matin en CE = `De dika`, identique à l'après-midi, alors que le prompt enseigne `Ӏуьйре дика хуьлда` pour le matin. → matin : `Jüyre dika (xülda)`. **Erreur certaine** (incohérence inter-fichiers) ; formes courtes à valider.
13. **l.274** — `'Bjärƶ tema'` (thème sombre) : « noir » = `Ӏаьржа` → `järƶa` (cf. `exercise_screen.dart:197` `Järƶa`). → `Järƶa tema`. **Quasi certaine** ; à confirmer.
14. **l.298 vs l.257** — `'AI ġonica'` vs `'Ġönna'` : si `гӀоьнца` (instrumental de `гӀо`), `оь→ö` → `ġönca`. **Quasi certaine** ; à confirmer.

### À faire valider par un natif (registre/lexique/syntaxe)

- l.22/267 `Ċa` (= maison) pour « Accueil » — choix sémantique acceptable ?
- l.40 `Voça` (Annuler), l.201/355 `Ẋaşdo` (Modifier — `хийца` attendu ?), l.380 `Yuxa ġort.`, l.83 `Djadolade!`, l.218 `Profile da hotta yuxa çuvala deza ẋuna.` (syntaxe douteuse), l.388 `Kart yuxaerzo ṫetajae`, l.394 `Goçe gayta ṫetajae`.
- l.71 `'{n} de Roġ'` — ordre des mots et majuscule interne.
- l.152/461 `bolx` / `Bolxaş` — pluriel attendu de `болх` : `белхаш` (`belxaş`), pluriel irrégulier.
- l.186 `Hinca classement yac.` — mot français `classement` non traduit.
- l.329 `ċe yolaş` — si `йолуш` : `у→u` → `yoluş` (quasi certaine).

---

## 5. Hors périmètre strict mais nécessaire à la cohérence inter-fichiers

### `lib/screens/exercise_screen.dart` (contenu réel des leçons)

1. **l.77, 84, 99, 107** — `'Марша огӀийла' / 'Marşa oġiyla'` : forme **sans préfixe de classe**, en contradiction avec le prompt l.314 (`Марша вогIийла`). Enseigné tel quel aux débutants en leçon 2, y compris comme bonne réponse de QCM. **Erreur certaine** (incohérence) ; forme de citation à trancher avec un natif.
2. **l.119, 126 vs prompt l.300** — leçon 3 : `кхо / qo` (3) et `пхи / pxi` (5) vs prompt : `кхоъ` et `пхиъ`. Les deux fichiers doivent enseigner la même forme. **Erreur certaine** (incohérence) ; choix pédagogique à valider.
3. **l.70** — `'Баркалла дукха' = Merci beaucoup` : ordre des mots suspect (left-branching : les modificateurs précèdent) ; attendu `Доккха баркалла` ou `Дукха баркалла`. **À valider par un natif**.
4. Points positifs : `Voŋ` (l.51), `cẋa`/`şiə` (l.114–116), `ċeŋ`/`K̇ayŋ`/`Järƶa` (l.178–204), `Dela reza xülda` (l.80), `Süyre`/`Jüyre` (l.92–94) sont conformes à la table officielle — partie la plus propre du corpus latin.

### `lib/screens/register_screen.dart` — homoglyphes cyrilliques dans des chaînes latines

Vérifié aux points de code (le `е` est U+0435 cyrillique) :
- **l.40** : `'Djaxotta LinguaCE-na ṫе, …'` → `ṫe`
- **l.46** : `'Deq̇aşxoçuŋ ċе'` → `ċe` (la version `app_strings.dart:206` est correcte)
- **l.64** : `'6-l k̇еzig ca xila dеza elp/surt'` → `k̇ezig`, `deza`

**Erreur certaine** (corruption invisible à l'œil, casse les recherches de chaînes). La syntaxe de l.40 (`vola a lo`) et de l.64 est par ailleurs **à valider par un natif**.

### `lib/screens/home_screen.dart`, `CONTRIBUTING.md`, `design_showcase_screen.dart`

`barkalla`/`баркалла` (home l.281/287), `Баркалла` (CONTRIBUTING l.91), `НОХЧИЙН МОТТ` (showcase l.192) : **propres et cohérents**.

---

## 6. Liste consolidée pour le canal #chechen-linguistics (Discord)

**Priorité haute (enseigné aux débutants ou affiché dans l'UI) :**
1. Forme de salutation à enseigner : `Марша вогӀийла` (h.) / `йогӀийла` (f.) / `догӀийла` (pl.) — la forme nue `огӀийла` est-elle acceptable comme forme de citation ?
2. « Merci beaucoup » : `Баркалла дукха` (leçon 1) ou `Доккха баркалла` / autre formule idiomatique ?
3. Chiffres à enseigner : formes absolues `кхоъ`, `пхиъ` ou formes courtes `кхо`, `пхи` ?
4. Salutation du matin courte pour l'UI : `Jüyre dika` naturel sans `xülda` ? « Bon après-midi » distinct de « bonjour » existe-t-il ?
5. Confirmer `гӀиллакх` à la place de `Пиллакх` dans `Пиллакхехь ду иза` (prompt l.317).
6. Mot du jour : la glose `bart boçu doş noxçiyn matte` pour « expression de gratitude » est-elle correcte ? Reformulation native souhaitée.
7. `Маршалла хаттар` : formule pour « comment vas-tu ? » ou simple nom de l'acte de saluer ?
8. Pluriel de `болх` : `белхаш` (belxaş) ou `болхаш` (bolxaş) ?

**Grammaire de référence (system prompt) :**
9. Classe des abstraits en `-алла` : й ou д ? (règle l.31 vs exemple l.217 `хазалла … яра`).
10. Classe Й-II « animaux domestiques » : périmètre exact, et exemple à remplacer (`пхьагӀал`/`пхьагал` — graphie et classe ?).
11. Évidentialité de `яздан` : formes correctes du vu récent/lointain (`язди`/`яздира` ?) à la place de `яздигу`/`яздигира`.
12. Conditionnel réel futur : `Хьо луьйчур велахь, со а луьйчур вара` — `вара` futur dans l'apodose, ou phrase à corriger ?
13. `Цхьа (а) вац кхузахь` : la particule `а` est-elle obligatoire ?
14. Numéraux : 19 (`ткъайоьсна` ?), 30 (`ткъе итт` vs `тIейткъа`), 1er ordinal (`хьалхара` vs `цхьалгӀа`), 200 = `ши бӀе`.
15. Participes relatifs : `доьшу кехат` vs `доьшучу кехат` — distribution forme directe/oblique.
16. Couleurs : `сийна` = bleu, vert, ou bleu-vert ? `сурх` = rose ? Mot recommandé pour chaque couleur de la leçon 5.
17. `Мичча`/`Мича`/`Мичахь`, `Сай→Сеш`, `гӀоьмаш`, `Ватталхьан`, `телвидени`, `Дико` (atténuatif), `я лаьттана` (= reste ?), proverbe l.344 (`пхьан` → `хьан` ?).
18. Ergatif 2sg dans les exemples : `ахь`/`айхь` vs `Ахьа` — quelle forme normaliser ?

**Chaînes UI (CE) à relire en bloc :**
19. `Voça`, `Ẋaşdo`, `Yuxa ġort`, `Djadolade!`, `{n} de Roġ`, `Profile da hotta yuxa çuvala deza ẋuna`, `Kart yuxaerzo ṫetajae`, `Goçe gayta ṫetajae`, `Sihha→Sixxa/kesta`, `Istori djadakqa yur yu` (accord de classe + futur), `vola a lo` et la chaîne « minimum 6 caractères » de l'inscription.

**Question pour le mainteneur du système de translittération (pas un natif) :**
20. Confirmer `къ→q̇` (coquille `кь` l.190), la règle pour `ккх` (`kq` vs `qq`), et le caractère voulu des mappings non injectifs `щ/ш→ş`, `и/ы→i`.

---

## Fichiers concernés

- `lib/services/claude_service.dart` — concentration la plus forte d'erreurs (palochka, homoglyphes, contradictions internes)
- `lib/i18n/app_strings.dart` — translittérations incohérentes, 1 homoglyphe
- `lib/data/mock_data.dart` — 3 translittérations hors système
- `supabase/migrations/*.sql` — **propres** (aucun contenu tchétchène)
- `lib/screens/exercise_screen.dart` — contenu réel des leçons (3 incohérences inter-fichiers)
- `lib/screens/register_screen.dart` — 4 homoglyphes cyrilliques (`е` U+0435) dans des chaînes latines
